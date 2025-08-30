#!/bin/bash

# ==========================================
# Allure报告生成脚本
# ==========================================
# 功能: 将JMeter JTL结果文件转换为Allure报告
# 使用方法: ./generate-allure-report.sh [jtl_file_path] [optional_report_name]
# ==========================================

WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
ALLURE_HOME="/Users/onion/Desktop/automation/allure-2.34.0"
ALLURE_RESULTS_DIR="$WORKSPACE_DIR/allure-results"
ALLURE_REPORTS_DIR="$WORKSPACE_DIR/allure-reports"

# 设置默认参数
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
JTL_FILE="${1:-}"
REPORT_NAME="${2:-JMeter_Allure_Report_$TIMESTAMP}"

# 检查必要文件和目录
if [ ! -d "$ALLURE_HOME" ]; then
    echo "❌ 错误: Allure未安装或路径不正确: $ALLURE_HOME"
    exit 1
fi

if [ ! -x "$ALLURE_HOME/bin/allure" ]; then
    echo "❌ 错误: Allure可执行文件不存在: $ALLURE_HOME/bin/allure"
    exit 1
fi

# 创建必要目录
mkdir -p "$ALLURE_RESULTS_DIR"
mkdir -p "$ALLURE_REPORTS_DIR"

echo "🚀 开始生成Allure报告 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "📁 工作目录: $WORKSPACE_DIR"
echo "📊 Allure路径: $ALLURE_HOME"
echo "📋 结果目录: $ALLURE_RESULTS_DIR"
echo "📄 报告目录: $ALLURE_REPORTS_DIR"

# 如果没有指定JTL文件，查找最新的
if [ -z "$JTL_FILE" ]; then
    echo "🔍 查找最新的JTL文件..."
    JTL_FILE=$(find "$WORKSPACE_DIR/jmeter-results/jtl" -name "*.jtl" -type f -exec ls -t {} + 2>/dev/null | head -1)
fi

if [ -z "$JTL_FILE" ] || [ ! -f "$JTL_FILE" ]; then
    echo "❌ 错误: 找不到JTL结果文件: $JTL_FILE"
    echo "请确保已经运行过JMeter测试，或者手动指定JTL文件路径"
    exit 1
fi

echo "📊 使用JTL文件: $JTL_FILE"

# 清理旧的allure-results
echo "🧹 清理旧的Allure结果文件..."
rm -rf "$ALLURE_RESULTS_DIR"/*

# 将JTL转换为Allure兼容格式
echo "🔄 转换JTL文件为Allure格式..."

# 创建Allure测试结果文件
python3 - << EOF
import json
import xml.etree.ElementTree as ET
import os
import uuid
from datetime import datetime
import hashlib

def parse_jtl_to_allure(jtl_file, allure_results_dir):
    """将JMeter JTL文件转换为Allure结果格式"""
    
    # 解析JTL文件
    try:
        tree = ET.parse(jtl_file)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"❌ 解析JTL文件失败: {e}")
        return False
    except Exception as e:
        print(f"❌ 读取JTL文件失败: {e}")
        return False
    
    # 提取测试结果
    test_results = []
    suite_start_time = None
    suite_stop_time = None
    
    for sample in root.findall('.//httpSample') + root.findall('.//sample'):
        # 获取基本属性
        label = sample.get('lb', 'Unknown Test')
        success = sample.get('s', 'false').lower() == 'true'
        response_time = int(sample.get('t', '0'))
        timestamp = int(sample.get('ts', '0'))
        response_code = sample.get('rc', '0')
        response_message = sample.get('rm', '')
        
        # 计算时间范围
        if suite_start_time is None or timestamp < suite_start_time:
            suite_start_time = timestamp
        stop_time = timestamp + response_time
        if suite_stop_time is None or stop_time > suite_stop_time:
            suite_stop_time = stop_time
        
        # 生成唯一ID
        test_uuid = str(uuid.uuid4())
        container_uuid = str(uuid.uuid4())
        
        # 创建Allure测试结果
        allure_result = {
            "uuid": test_uuid,
            "historyId": hashlib.md5(label.encode()).hexdigest(),
            "name": label,
            "fullName": f"JMeter.{label}",
            "status": "passed" if success else "failed",
            "statusDetails": {
                "message": response_message if not success else "Test passed",
                "trace": f"Response Code: {response_code}"
            } if not success else {},
            "stage": "finished",
            "start": timestamp,
            "stop": timestamp + response_time,
            "labels": [
                {"name": "suite", "value": "JMeter Tests"},
                {"name": "testClass", "value": "JMeter"},
                {"name": "testMethod", "value": label},
                {"name": "package", "value": "jmeter.tests"},
                {"name": "framework", "value": "jmeter"}
            ],
            "parameters": [],
            "links": [],
            "attachments": []
        }
        
        # 添加步骤信息
        allure_result["steps"] = [{
            "name": f"HTTP Request: {label}",
            "status": "passed" if success else "failed",
            "stage": "finished",
            "start": timestamp,
            "stop": timestamp + response_time,
            "parameters": [
                {"name": "Response Code", "value": response_code},
                {"name": "Response Time", "value": f"{response_time}ms"},
                {"name": "Response Message", "value": response_message}
            ]
        }]
        
        test_results.append((test_uuid, allure_result))
    
    # 写入Allure结果文件
    for test_uuid, result in test_results:
        result_file = os.path.join(allure_results_dir, f"{test_uuid}-result.json")
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
    
    # 创建测试套件容器
    suite_uuid = str(uuid.uuid4())
    container = {
        "uuid": suite_uuid,
        "name": "JMeter Test Suite",
        "children": [result[0] for result in test_results],
        "befores": [],
        "afters": [],
        "start": suite_start_time or 0,
        "stop": suite_stop_time or 0
    }
    
    container_file = os.path.join(allure_results_dir, f"{suite_uuid}-container.json")
    with open(container_file, 'w', encoding='utf-8') as f:
        json.dump(container, f, indent=2, ensure_ascii=False)
    
    print(f"✅ 成功转换 {len(test_results)} 个测试结果")
    return True

# 执行转换
if parse_jtl_to_allure("$JTL_FILE", "$ALLURE_RESULTS_DIR"):
    print("🎉 JTL转Allure格式转换完成")
else:
    print("❌ JTL转Allure格式转换失败")
    exit(1)
EOF

# 检查转换结果
if [ $? -ne 0 ]; then
    echo "❌ JTL转换失败"
    exit 1
fi

# 检查是否有转换的结果文件
RESULT_COUNT=$(ls -1 "$ALLURE_RESULTS_DIR"/*.json 2>/dev/null | wc -l)
if [ "$RESULT_COUNT" -eq 0 ]; then
    echo "❌ 没有生成Allure结果文件"
    exit 1
fi

echo "📊 发现 $RESULT_COUNT 个Allure结果文件"

# 生成Allure报告
echo "📋 生成Allure HTML报告..."
REPORT_PATH="$ALLURE_REPORTS_DIR/$REPORT_NAME"

# 清理旧报告
if [ -d "$REPORT_PATH" ]; then
    rm -rf "$REPORT_PATH"
fi

# 生成报告
"$ALLURE_HOME/bin/allure" generate "$ALLURE_RESULTS_DIR" -o "$REPORT_PATH" --clean

if [ $? -eq 0 ]; then
    echo "✅ Allure报告生成成功！"
    echo "📄 报告位置: $REPORT_PATH"
    echo "🌐 查看报告: open $REPORT_PATH/index.html"
    
    # 打包报告
    echo "📦 打包Allure报告..."
    cd "$ALLURE_REPORTS_DIR"
    REPORT_ZIP="$REPORT_NAME.zip"
    zip -r "$REPORT_ZIP" "$REPORT_NAME" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ 报告打包完成: $ALLURE_REPORTS_DIR/$REPORT_ZIP"
        
        # 复制到/tmp以便邮件发送
        cp "$ALLURE_REPORTS_DIR/$REPORT_ZIP" "/tmp/"
        echo "📧 报告已复制到/tmp/$REPORT_ZIP，可用于邮件发送"
    else
        echo "⚠️ 报告打包失败"
    fi
    
    # 可选：自动打开报告
    if command -v open >/dev/null 2>&1; then
        echo "🚀 正在打开Allure报告..."
        open "$REPORT_PATH/index.html"
    fi
    
else
    echo "❌ Allure报告生成失败"
    exit 1
fi

echo "========================================="
echo "🎉 Allure报告生成完成！"
echo "📊 JTL文件: $JTL_FILE"
echo "📋 结果目录: $ALLURE_RESULTS_DIR"
echo "📄 报告目录: $REPORT_PATH"
echo "📦 压缩包: $ALLURE_REPORTS_DIR/$REPORT_ZIP"
echo "========================================="