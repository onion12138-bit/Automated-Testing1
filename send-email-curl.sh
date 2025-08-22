#!/bin/bash

# ==========================================
# 使用curl发送邮件的脚本
# ==========================================
# 功能: 绕过系统邮件服务，直接使用curl发送邮件
# 优点: 简单、可靠、不需要额外配置
# ==========================================

# 邮件配置
SMTP_SERVER="smtp.qq.com"
SMTP_PORT="587"
SENDER_EMAIL="your_qq_email@qq.com"  # 需要修改为你的QQ邮箱
SENDER_PASSWORD="your_app_password"   # 需要修改为你的QQ邮箱授权码
RECIPIENT_EMAIL="2335327949@qq.com"

# 检查配置
check_config() {
    if [ "$SENDER_EMAIL" = "your_qq_email@qq.com" ]; then
        echo "❌ 请先配置发送邮箱信息！"
        echo "📝 编辑此脚本，修改以下变量："
        echo "   SENDER_EMAIL = '你的QQ邮箱@qq.com'"
        echo "   SENDER_PASSWORD = '你的QQ邮箱授权码'"
        echo ""
        echo "💡 获取授权码方法："
        echo "1. 登录QQ邮箱网页版"
        echo "2. 设置 -> 账户 -> POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务"
        echo "3. 开启SMTP服务并获取授权码"
        return 1
    fi
    return 0
}

# 发送邮件
send_email() {
    local subject="$1"
    local body="$2"
    local attachment_path="$3"
    
    echo "📧 准备发送邮件..."
    echo "📤 发送者: $SENDER_EMAIL"
    echo "📥 收件人: $RECIPIENT_EMAIL"
    echo "📋 主题: $subject"
    
    # 创建邮件内容文件
    local mail_file="/tmp/email_content_$$.txt"
    cat > "$mail_file" << EOF
From: $SENDER_EMAIL
To: $RECIPIENT_EMAIL
Subject: $subject
Content-Type: text/plain; charset=UTF-8

$body
EOF
    
    # 如果有附件，使用multipart格式
    if [ -n "$attachment_path" ] && [ -f "$attachment_path" ]; then
        echo "📎 添加附件: $attachment_path"
        
        # 使用curl发送带附件的邮件
        curl --mail-from "$SENDER_EMAIL" \
             --mail-rcpt "$RECIPIENT_EMAIL" \
             --upload-file "$mail_file" \
             --ssl-reqd \
             --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
             "smtp://$SMTP_SERVER:$SMTP_PORT" \
             --verbose
        
        local result=$?
    else
        echo "📧 发送纯文本邮件..."
        
        # 使用curl发送纯文本邮件
        curl --mail-from "$SENDER_EMAIL" \
             --mail-rcpt "$RECIPIENT_EMAIL" \
             --upload-file "$mail_file" \
             --ssl-reqd \
             --user "$SENDER_EMAIL:$SENDER_PASSWORD" \
             "smtp://$SMTP_SERVER:$SMTP_PORT"
        
        local result=$?
    fi
    
    # 清理临时文件
    rm -f "$mail_file"
    
    return $result
}

# 主函数
main() {
    echo "========================================="
    echo "📧 Ford Smart Badge 邮件发送脚本 (curl版)"
    echo "========================================="
    
    # 检查配置
    if ! check_config; then
        exit 1
    fi
    
    # 检查curl是否可用
    if ! command -v curl &> /dev/null; then
        echo "❌ curl命令不可用，请先安装curl"
        exit 1
    fi
    
    # 邮件内容
    local subject="📊 Ford Smart Badge 测试报告 - $(date '+%Y-%m-%d %H:%M:%S')"
    local body="
Ford Smart Badge 自动化测试报告

📅 测试时间: $(date '+%Y-%m-%d %H:%M:%S')
📧 发送者: $SENDER_EMAIL
📧 收件人: $RECIPIENT_EMAIL

🎯 测试状态: 完成
📊 测试内容: JMeter API测试
📁 工作目录: /Users/onion/Desktop/JmeterMac2

此邮件由curl脚本自动发送，绕过了系统邮件服务问题。

---
Ford Smart Badge 自动化测试系统
    "
    
    # 查找最新的测试报告
    local attachment_path=""
    local latest_zip=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
    
    if [ -n "$latest_zip" ] && [ -f "$latest_zip" ]; then
        attachment_path="$latest_zip"
        echo "📦 找到测试报告: $attachment_path"
    else
        echo "⚠️ 未找到测试报告文件"
    fi
    
    # 发送邮件
    echo ""
    echo "🚀 开始发送邮件..."
    if send_email "$subject" "$body" "$attachment_path"; then
        echo ""
        echo "========================================="
        echo "🎉 邮件发送成功！"
        echo "📧 收件人: $RECIPIENT_EMAIL"
        if [ -n "$attachment_path" ]; then
            echo "📎 附件: $attachment_path"
        fi
        echo "========================================="
    else
        echo ""
        echo "========================================="
        echo "❌ 邮件发送失败"
        echo "🔍 请检查网络连接和邮箱配置"
        echo "========================================="
        exit 1
    fi
}

# 运行主函数
main "$@"

