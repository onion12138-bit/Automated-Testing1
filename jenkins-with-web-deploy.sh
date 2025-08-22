#!/bin/bash

echo "========================================="
echo "🚀 Ford Smart Badge 自动化测试脚本 (含Web部署)"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
echo "定时设置: 早上9点, 下午2点, 晚上6点"
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
        
        # 部署报告到Web服务器
        echo "🌐 部署报告到Web服务器..." >> "$LOG_FILE"
        echo "🌐 部署报告到Web服务器..."
        
        # 创建Web目录
        WEB_ROOT="$WORKSPACE_DIR/web-reports"
        mkdir -p "$WEB_ROOT/reports"
        
        # 解压报告
        REPORT_NAME=$(basename "$LATEST_ZIP" .zip)
        REPORT_DIR="$WEB_ROOT/reports/$REPORT_NAME"
        rm -rf "$REPORT_DIR"
        unzip -q "$LATEST_ZIP" -d "$REPORT_DIR"
        
        echo "✅ 报告解压完成: $REPORT_DIR" >> "$LOG_FILE"
        echo "✅ 报告解压完成: $REPORT_DIR"
        
        # 复制ZIP文件到Web目录
        cp "$LATEST_ZIP" "$WEB_ROOT/reports/"
        
        # 生成可访问的URL
        WEB_URL="http://localhost:8000"
        REPORT_BASE_URL="$WEB_URL/reports/$REPORT_NAME"
        
        # 查找HTML报告文件
        SUMMARY_REPORT=""
        DETAIL_REPORT=""
        
        for html_file in "$REPORT_DIR"/html_summary_reports/*.html; do
            if [ -f "$html_file" ]; then
                SUMMARY_REPORT="$REPORT_BASE_URL/html_summary_reports/$(basename "$html_file")"
                break
            fi
        done
        
        for html_file in "$REPORT_DIR"/html_detail_reports/*.html; do
            if [ -f "$html_file" ]; then
                DETAIL_REPORT="$REPORT_BASE_URL/html_detail_reports/$(basename "$html_file")"
                break
            fi
        done
        
        # 启动Web服务器（如果未运行）
        if ! pgrep -f "python3 -m http.server" > /dev/null; then
            echo "🚀 启动Web服务器..." >> "$LOG_FILE"
            echo "🚀 启动Web服务器..."
            cd "$WEB_ROOT"
            python3 -m http.server 8000 > /dev/null 2>&1 &
            echo "✅ Web服务器已启动" >> "$LOG_FILE"
            echo "✅ Web服务器已启动"
        fi
        
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
        
        # 显示可访问的URL
        echo ""
        echo "========================================="
        echo "🔗 可访问的报告链接"
        echo "========================================="
        if [ -n "$SUMMARY_REPORT" ]; then
            echo "📈 汇总报告: $SUMMARY_REPORT"
        fi
        if [ -n "$DETAIL_REPORT" ]; then
            echo "📋 详细报告: $DETAIL_REPORT"
        fi
        echo "📦 下载报告: $WEB_URL/reports/$(basename "$LATEST_ZIP")"
        echo "🏠 报告中心: $WEB_URL"
        echo "========================================="
        
        # 将URL写入日志
        echo "🔗 可访问的报告链接:" >> "$LOG_FILE"
        if [ -n "$SUMMARY_REPORT" ]; then
            echo "📈 汇总报告: $SUMMARY_REPORT" >> "$LOG_FILE"
        fi
        if [ -n "$DETAIL_REPORT" ]; then
            echo "📋 详细报告: $DETAIL_REPORT" >> "$LOG_FILE"
        fi
        echo "📦 下载报告: $WEB_URL/reports/$(basename "$LATEST_ZIP")" >> "$LOG_FILE"
        echo "🏠 报告中心: $WEB_URL" >> "$LOG_FILE"
        
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
echo "⏰ 下次执行时间: 早上9点, 下午2点, 晚上6点"
echo "🌐 Web报告中心: $WEB_URL"
echo "========================================="
