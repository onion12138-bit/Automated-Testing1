#!/bin/bash

# ==========================================
# Ford Smart Badge 每日自动化测试脚本
# ==========================================
# 功能: 每天晚上19:25自动执行JMeter测试并发送邮件
# 收件人: 2335327949@qq.com
# 执行时间: 每天 19:25
# ==========================================

# 设置工作目录
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

# 记录日志
LOG_FILE="$WORKSPACE_DIR/daily-test.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🕐 开始执行每日自动化测试 - $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# 检查工作目录
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ 错误: 工作目录不存在: $WORKSPACE_DIR" >> "$LOG_FILE"
    exit 1
fi

echo "📁 工作目录: $WORKSPACE_DIR" >> "$LOG_FILE"

# 检查必要文件
if [ ! -f "$WORKSPACE_DIR/build.xml" ]; then
    echo "❌ 错误: build.xml文件不存在" >> "$LOG_FILE"
    exit 1
fi

if [ ! -f "$WORKSPACE_DIR/jmeter-script/Ford-Smart-API-Test.jmx" ]; then
    echo "❌ 错误: JMeter测试脚本不存在" >> "$LOG_FILE"
    exit 1
fi

echo "✅ 必要文件检查通过" >> "$LOG_FILE"

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
ant run >> "$LOG_FILE" 2>&1

# 检查执行结果
if [ $? -eq 0 ]; then
    echo "✅ Ant构建执行成功" >> "$LOG_FILE"
    
    # 查找最新的ZIP报告文件
    LATEST_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
    
    if [ -n "$LATEST_ZIP" ] && [ -f "$LATEST_ZIP" ]; then
        echo "📦 找到最新报告: $LATEST_ZIP" >> "$LOG_FILE"
        
        # 发送邮件通知
        echo "📧 发送邮件通知..." >> "$LOG_FILE"
        
        # 使用Python邮件发送脚本
        if [ -f "$WORKSPACE_DIR/send-email-python.py" ]; then
            echo "🐍 使用Python脚本发送邮件..." >> "$LOG_FILE"
            
            cd "$WORKSPACE_DIR"
            python3 send-email-python.py
            MAIL_RESULT=$?
            
            if [ $MAIL_RESULT -eq 0 ]; then
                echo "✅ 邮件发送成功" >> "$LOG_FILE"
            else
                echo "❌ Python邮件发送失败" >> "$LOG_FILE"
            fi
        else
            echo "❌ 错误：Python邮件脚本不存在" >> "$LOG_FILE"
            echo "❌ 邮件发送失败：找不到send-email-python.py文件" >> "$LOG_FILE"
        fi
    else
        echo "⚠️ 未找到ZIP报告文件" >> "$LOG_FILE"
    fi
else
    echo "❌ Ant构建执行失败" >> "$LOG_FILE"
    echo "❌ 测试失败，请检查日志文件：$LOG_FILE" >> "$LOG_FILE"
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 每日自动化测试完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 清理旧日志（保留最近30天）
find "$WORKSPACE_DIR" -name "daily-test.log" -mtime +30 -delete 2>/dev/null

echo "✅ 每日自动化测试脚本执行完成" 