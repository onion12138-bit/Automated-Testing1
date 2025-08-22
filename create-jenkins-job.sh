#!/bin/bash

# ==========================================
# Jenkins任务自动创建脚本
# ==========================================
# 功能: 自动创建Ford Smart Badge测试任务
# 使用方法: 在Jenkins中运行此脚本
# ==========================================

echo "========================================="
echo "🚀 Jenkins任务自动创建脚本"
echo "========================================="
echo "这个脚本将帮助你在Jenkins中创建自动化测试任务"
echo ""

# 检查Jenkins是否运行
echo "🔍 检查Jenkins状态..."
if curl -s http://127.0.0.1:8080 > /dev/null 2>&1; then
    echo "✅ Jenkins正在运行: http://127.0.0.1:8080"
else
    echo "❌ Jenkins未运行，请先启动Jenkins"
    exit 1
fi

echo ""
echo "📋 请按照以下步骤在Jenkins中创建任务："
echo ""

echo "1️⃣ 访问Jenkins"
echo "   网址: http://127.0.0.1:8080"
echo "   使用你的Jenkins账号登录"
echo ""

echo "2️⃣ 创建新任务"
echo "   • 点击 '新建任务' 或 'New Item'"
echo "   • 任务名称: Ford-Smart-Badge-Test"
echo "   • 选择 '构建一个自由风格的软件项目'"
echo "   • 点击 '确定'"
echo ""

echo "3️⃣ 配置任务"
echo "   • 描述: Ford Smart Badge 每日自动化测试任务"
echo "   • 构建触发器: 勾选 '定时构建'"
echo "   • Cron表达式: 0 9,14,17 * * *"
echo "   • 含义: 每天9:00、14:30、17:05执行"
echo ""

echo "4️⃣ 配置构建步骤"
echo "   • 点击 '增加构建步骤'"
echo "   • 选择 '执行shell'"
echo "   • 复制以下脚本内容:"
echo ""

echo "========================================="
echo "📝 构建脚本内容 (复制到Jenkins中):"
echo "========================================="

cat << 'EOF'
#!/bin/bash

# Ford Smart Badge 每日自动化测试脚本
# 通过Jenkins执行，比cron更可靠

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
echo "5️⃣ 配置构建后操作"
echo "   • 点击 '增加构建后操作步骤'"
echo "   • 选择 'E-mail Notification'"
echo "   • 收件人: 2335327949@qq.com"
echo "   • 勾选 '每次不稳定的构建都发送邮件通知'"
echo ""

echo "6️⃣ 保存任务"
echo "   • 点击 '保存'"
echo "   • 任务创建完成"
echo ""

echo "7️⃣ 测试任务"
echo "   • 点击 '立即构建' 测试任务是否正常"
echo "   • 查看构建日志，确认执行成功"
echo "   • 检查是否收到测试邮件"
echo ""

echo "========================================="
echo "🎯 任务配置完成后"
echo "========================================="
echo "• 停用系统cron任务，避免冲突"
echo "• Jenkins将自动按时间执行测试"
echo "• 每次执行都会发送邮件通知"
echo "• 可以通过Web界面监控所有执行状态"
echo ""

echo "========================================="
echo "🚀 脚本执行完成"
echo "========================================="
echo "现在去Jenkins中创建任务吧！"
echo "如果遇到问题，可以随时询问我。"
