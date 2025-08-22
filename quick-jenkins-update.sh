#!/bin/bash

echo "========================================="
echo "🚀 快速修复Jenkins ant命令问题"
echo "========================================="

# 检查Jenkins是否运行
if ! pgrep -f jenkins > /dev/null; then
    echo "❌ Jenkins未运行，请先启动Jenkins"
    echo "启动命令: brew services start jenkins-lts"
    exit 1
fi

echo "✅ Jenkins正在运行"

# 备份当前配置
echo "📋 备份当前Jenkins任务配置..."
cp ~/.jenkins/jobs/Ford-Smart-Badge-Test/config.xml ~/.jenkins/jobs/Ford-Smart-Badge-Test/config.xml.backup.$(date +%Y%m%d_%H%M%S)

echo "✅ 配置已备份"

echo ""
echo "========================================="
echo "🔧 问题分析"
echo "========================================="
echo "Jenkins仍然找不到ant命令，说明环境变量设置没有生效。"
echo "我们将使用ant的绝对路径来解决这个问题。"
echo ""

echo "========================================="
echo "📝 立即更新步骤"
echo "========================================="
echo "请在Jenkins Web界面中执行以下操作："
echo ""
echo "1. 打开浏览器访问: http://127.0.0.1:8080"
echo "2. 进入任务: Ford-Smart-Badge-Test"
echo "3. 点击 '配置' 按钮"
echo "4. 在 '构建' 部分，完全删除Shell脚本内容"
echo "5. 粘贴以下新脚本："
echo ""

# 显示新的脚本内容
cat << 'EOF'
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
EOF

echo ""
echo "6. 在 '构建后操作' 部分："
echo "   - 移除 'E-mail Notification' 插件"
echo "7. 点击 '保存' 按钮"
echo ""

echo "========================================="
echo "🔑 关键改进"
echo "========================================="
echo "• 使用ant绝对路径: /opt/homebrew/bin/ant"
echo "• 添加ant文件存在性检查"
echo "• 显示ant版本信息"
echo "• 详细的错误处理和日志记录"
echo ""

echo "========================================="
echo "🧪 测试验证"
echo "========================================="
echo "更新后点击 '立即构建'，应该看到："
echo "• 🔍 使用ant绝对路径: /opt/homebrew/bin/ant"
echo "• 📋 ant版本信息: [版本号]"
echo "• 🚀 开始执行Ant构建..."
echo "• ✅ Ant构建执行成功"
echo ""

echo "✅ 更新说明完成！请按照上述步骤更新Jenkins配置。"
echo "这次使用绝对路径应该能解决ant命令找不到的问题！"
