#!/bin/bash

echo "========================================="
echo "🚀 开始执行Ford Smart Badge自动化测试"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
echo "========================================="

# 设置工作目录
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

# 记录日志
LOG_FILE="$WORKSPACE_DIR/jenkins-test.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🕐 Jenkins开始执行每日自动化测试 - $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# 检查工作目录
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ 错误: 工作目录不存在: $WORKSPACE_DIR" >> "$LOG_FILE"
    echo "❌ 错误: 工作目录不存在: $WORKSPACE_DIR"
    exit 1
fi

echo "📁 工作目录: $WORKSPACE_DIR" >> "$LOG_FILE"
echo "📁 工作目录: $WORKSPACE_DIR"

# 检查必要文件
if [ ! -f "$WORKSPACE_DIR/build.xml" ]; then
    echo "❌ 错误: build.xml文件不存在" >> "$LOG_FILE"
    echo "❌ 错误: build.xml文件不存在"
    exit 1
fi

if [ ! -f "$WORKSPACE_DIR/jmeter-script/Ford-Smart-API-Test.jmx" ]; then
    echo "❌ 错误: JMeter测试脚本不存在" >> "$LOG_FILE"
    echo "❌ 错误: JMeter测试脚本不存在"
    exit 1
fi

echo "✅ 必要文件检查通过" >> "$LOG_FILE"
echo "✅ 必要文件检查通过"

# 使用ant的绝对路径
ANT_PATH="/opt/homebrew/bin/ant"
echo "🔍 使用ant绝对路径: $ANT_PATH" >> "$LOG_FILE"
echo "🔍 使用ant绝对路径: $ANT_PATH"

# 检查ant文件是否存在
if [ ! -f "$ANT_PATH" ]; then
    echo "❌ 错误: ant文件不存在: $ANT_PATH" >> "$LOG_FILE"
    echo "❌ 错误: ant文件不存在: $ANT_PATH"
    exit 1
fi

# 显示ant版本信息
echo "📋 ant版本信息:" >> "$LOG_FILE"
echo "📋 ant版本信息:"
"$ANT_PATH" -version >> "$LOG_FILE" 2>&1
"$ANT_PATH" -version

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
echo "🚀 开始执行Ant构建..."
"$ANT_PATH" run >> "$LOG_FILE" 2>&1
ANT_EXIT_CODE=$?

echo "Ant执行退出码: $ANT_EXIT_CODE" >> "$LOG_FILE"
echo "Ant执行退出码: $ANT_EXIT_CODE"

# 检查执行结果
if [ $ANT_EXIT_CODE -eq 0 ]; then
    echo "✅ Ant构建执行成功" >> "$LOG_FILE"
    echo "✅ Ant构建执行成功"
    
    # 查找最新的ZIP报告文件
    LATEST_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
    
    if [ -n "$LATEST_ZIP" ] && [ -f "$LATEST_ZIP" ]; then
        echo "📦 找到最新报告: $LATEST_ZIP" >> "$LOG_FILE"
        echo "📦 找到最新报告: $LATEST_ZIP"
        
        # 发送邮件通知
        echo "📧 发送邮件通知..." >> "$LOG_FILE"
        echo "📧 发送邮件通知..."
        
        # 使用Python脚本发送邮件
        if [ -f "$WORKSPACE_DIR/send-email-python.py" ]; then
            echo "🐍 使用Python脚本发送邮件..." >> "$LOG_FILE"
            echo "🐍 使用Python脚本发送邮件..."
            
            cd "$WORKSPACE_DIR"
            python3 send-email-python.py
            MAIL_RESULT=$?
            
            if [ $MAIL_RESULT -eq 0 ]; then
                echo "✅ 邮件发送成功 (使用Python脚本)" >> "$LOG_FILE"
                echo "✅ 邮件发送成功 (使用Python脚本)"
            else
                echo "❌ Python邮件发送失败" >> "$LOG_FILE"
                echo "❌ Python邮件发送失败"
            fi
        else
            echo "❌ Python邮件脚本不存在" >> "$LOG_FILE"
            echo "❌ Python邮件脚本不存在"
        fi
    else
        echo "⚠️ 未找到ZIP报告文件" >> "$LOG_FILE"
        echo "⚠️ 未找到ZIP报告文件"
    fi
else
    echo "❌ Ant构建执行失败 (退出码: $ANT_EXIT_CODE)" >> "$LOG_FILE"
    echo "❌ Ant构建执行失败 (退出码: $ANT_EXIT_CODE)"
    echo "请查看日志文件: $LOG_FILE" >> "$LOG_FILE"
    echo "请查看日志文件: $LOG_FILE"
    exit 1
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 Jenkins每日自动化测试完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 清理旧日志（保留最近30天）
find "$WORKSPACE_DIR" -name "jenkins-test.log" -mtime +30 -delete 2>/dev/null

echo "========================================="
echo "🎉 Jenkins自动化测试脚本执行完成！"
echo "📧 测试报告已发送到: 2335327949@qq.com"
echo "📄 详细日志: $LOG_FILE"
echo "========================================="
