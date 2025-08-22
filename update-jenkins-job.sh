#!/bin/bash

echo "========================================="
echo "🔧 更新Jenkins任务配置"
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

# 显示修复说明
echo ""
echo "========================================="
echo "🔍 问题分析和解决方案"
echo "========================================="
echo "1. 构建失败问题："
echo "   - 原因：Jenkins中找不到ant命令"
echo "   - 解决：在脚本开头设置正确的PATH环境变量"
echo ""
echo "2. 邮件乱码问题："
echo "   - 原因：Jenkins邮件插件配置错误，尝试连接localhost:25"
echo "   - 解决：移除Jenkins邮件插件，使用我们自己的Python脚本"
echo ""

echo "========================================="
echo "📝 需要手动更新的内容"
echo "========================================="
echo "请在Jenkins Web界面中执行以下操作："
echo ""
echo "1. 打开浏览器访问: http://127.0.0.1:8080"
echo "2. 进入任务: Ford-Smart-Badge-Test"
echo "3. 点击 '配置' 按钮"
echo "4. 在 '构建' 部分，更新Shell脚本内容："
echo ""

# 显示新的脚本内容
cat << 'EOF'
#!/bin/bash

# 设置环境变量
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin:$PATH"
export HOME="/Users/onion"
export SHELL="/bin/bash"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Ford Smart Badge 每日自动化测试脚本
# 通过Jenkins执行，比cron更可靠

echo "========================================="
echo "🚀 开始执行Ford Smart Badge自动化测试"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
echo "PATH: $PATH"
echo "ANT路径: $(which ant)"
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

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
echo "🚀 开始执行Ant构建..."
ant run >> "$LOG_FILE" 2>&1

# 检查执行结果
if [ $? -eq 0 ]; then
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
    echo "❌ Ant构建执行失败" >> "$LOG_FILE"
    echo "❌ Ant构建执行失败"
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
echo "5. 在 '构建后操作' 部分："
echo "   - 移除 'E-mail Notification' 插件"
echo "   - 或者保留但不要配置SMTP服务器"
echo ""
echo "6. 点击 '保存' 按钮"
echo ""

echo "========================================="
echo "🧪 测试建议"
echo "========================================="
echo "更新配置后："
echo "1. 点击 '立即构建' 测试任务"
echo "2. 查看构建日志，确认："
echo "   - ant命令能找到并执行"
echo "   - 测试报告生成成功"
echo "   - Python邮件脚本执行成功"
echo "3. 检查邮箱是否收到测试报告"
echo ""

echo "========================================="
echo "📚 相关文件"
echo "========================================="
echo "• 修复后的配置文件: Jenkins-Fixed-Config.xml"
echo "• 当前备份: ~/.jenkins/jobs/Ford-Smart-Badge-Test/config.xml.backup.*"
echo "• 测试日志: $WORKSPACE_DIR/jenkins-test.log"
echo ""

echo "✅ 更新说明完成！请按照上述步骤手动更新Jenkins任务配置。"
