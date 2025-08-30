#!/bin/bash

# ==========================================
# Ford Smart Badge 测试并生成Allure报告脚本
# ==========================================
# 功能: 执行JMeter测试并生成Allure报告
# 使用方法: ./start-test-with-allure.sh
# ==========================================

WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

LOG_FILE="$WORKSPACE_DIR/test-with-allure.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🚀 开始JMeter测试与Allure报告生成 - $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

echo "========================================="
echo "🚀 Ford Smart Badge - JMeter测试与Allure报告生成"
echo "========================================="
echo "📁 工作目录: $WORKSPACE_DIR"
echo "📅 开始时间: $TIMESTAMP"
echo "========================================="

# 1. 执行JMeter测试
echo "🔧 步骤1: 执行JMeter测试..."
echo "🔧 步骤1: 执行JMeter测试..." >> "$LOG_FILE"

ant test >> "$LOG_FILE" 2>&1
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ JMeter测试执行成功"
    echo "✅ JMeter测试执行成功" >> "$LOG_FILE"
else
    echo "❌ JMeter测试执行失败"
    echo "❌ JMeter测试执行失败" >> "$LOG_FILE"
    exit 1
fi

# 2. 生成Allure报告
echo "📊 步骤2: 生成Allure报告..."
echo "📊 步骤2: 生成Allure报告..." >> "$LOG_FILE"

./generate-allure-report.sh >> "$LOG_FILE" 2>&1
ALLURE_RESULT=$?

if [ $ALLURE_RESULT -eq 0 ]; then
    echo "✅ Allure报告生成成功"
    echo "✅ Allure报告生成成功" >> "$LOG_FILE"
    
    # 获取最新的Allure报告路径
    LATEST_ALLURE_REPORT=$(find "$WORKSPACE_DIR/allure-reports" -name "JMeter_Allure_Report_*" -type d -exec ls -td {} + | head -1)
    
    if [ -n "$LATEST_ALLURE_REPORT" ] && [ -d "$LATEST_ALLURE_REPORT" ]; then
        echo "📄 Allure报告位置: $LATEST_ALLURE_REPORT"
        echo "📄 Allure报告位置: $LATEST_ALLURE_REPORT" >> "$LOG_FILE"
        
        # 显示访问地址
        echo "🌐 Allure报告访问地址:"
        echo "   本地文件: file://$LATEST_ALLURE_REPORT/index.html"
        echo "   命令打开: open $LATEST_ALLURE_REPORT/index.html"
        
        echo "🌐 Allure报告访问地址: file://$LATEST_ALLURE_REPORT/index.html" >> "$LOG_FILE"
        
        # 检查ZIP文件
        ALLURE_ZIP="$LATEST_ALLURE_REPORT.zip"
        if [ -f "$ALLURE_ZIP" ]; then
            echo "📦 Allure报告压缩包: $ALLURE_ZIP"
            echo "📦 Allure报告压缩包: $ALLURE_ZIP" >> "$LOG_FILE"
        fi
        
        # 自动打开报告（如果系统支持）
        if command -v open >/dev/null 2>&1; then
            echo "🚀 正在自动打开Allure报告..."
            echo "🚀 正在自动打开Allure报告..." >> "$LOG_FILE"
            open "$LATEST_ALLURE_REPORT/index.html"
        fi
        
    else
        echo "⚠️ 未找到Allure报告目录"
        echo "⚠️ 未找到Allure报告目录" >> "$LOG_FILE"
    fi
    
else
    echo "❌ Allure报告生成失败"
    echo "❌ Allure报告生成失败" >> "$LOG_FILE"
    exit 1
fi

# 3. 显示传统JMeter报告
echo "📊 步骤3: 检查传统JMeter报告..."
LATEST_HTML_REPORT=$(find "$WORKSPACE_DIR/jmeter-results/html" -name "*.html" -type f -exec ls -t {} + | head -1)
if [ -n "$LATEST_HTML_REPORT" ] && [ -f "$LATEST_HTML_REPORT" ]; then
    echo "📊 JMeter HTML报告: $LATEST_HTML_REPORT"
    echo "📊 JMeter HTML报告: $LATEST_HTML_REPORT" >> "$LOG_FILE"
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 测试与报告生成完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

echo "========================================="
echo "🎉 测试与Allure报告生成完成！"
echo "⏰ 完成时间: $END_TIMESTAMP"
echo "📄 详细日志: $LOG_FILE"
echo "========================================="

# 显示总结
echo ""
echo "📋 报告总结:"
echo "   📊 Allure报告: $LATEST_ALLURE_REPORT/index.html"
if [ -n "$LATEST_HTML_REPORT" ]; then
    echo "   📊 JMeter报告: $LATEST_HTML_REPORT"
fi
echo "   📄 详细日志: $LOG_FILE"
echo ""
echo "🌐 快速访问命令:"
echo "   open $LATEST_ALLURE_REPORT/index.html"
echo ""