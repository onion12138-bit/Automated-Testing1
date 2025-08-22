#!/bin/bash

# ==========================================
# 邮件发送问题诊断脚本
# ==========================================

echo "========================================="
echo "🔍 邮件发送问题诊断"
echo "========================================="

# 检查系统邮件服务状态
echo "📧 检查系统邮件服务状态..."
echo "----------------------------------------"

# 检查Postfix状态
if command -v postfix &> /dev/null; then
    echo "✅ Postfix已安装"
    POSTFIX_STATUS=$(sudo postfix status 2>/dev/null | head -1)
    echo "📊 Postfix状态: $POSTFIX_STATUS"
else
    echo "❌ Postfix未安装"
fi

# 检查邮件配置
echo ""
echo "🔧 检查邮件配置..."
echo "----------------------------------------"

# 检查inet_interfaces配置
INET_INTERFACES=$(sudo postconf -h inet_interfaces 2>/dev/null)
echo "🌐 网络接口配置: $INET_INTERFACES"

# 检查relayhost配置
RELAYHOST=$(sudo postconf -h relayhost 2>/dev/null)
echo "📤 中继服务器: $RELAYHOST"

# 检查邮件队列
echo ""
echo "📬 检查邮件队列..."
echo "----------------------------------------"
MAIL_QUEUE=$(sudo mailq 2>/dev/null | head -10)
if [ -n "$MAIL_QUEUE" ]; then
    echo "📋 邮件队列内容:"
    echo "$MAIL_QUEUE"
else
    echo "✅ 邮件队列为空"
fi

# 检查本地邮件
echo ""
echo "📮 检查本地邮件..."
echo "----------------------------------------"
if [ -f "/var/mail/onion" ]; then
    LOCAL_MAIL_SIZE=$(ls -lh /var/mail/onion | awk '{print $5}')
    echo "📁 本地邮件文件大小: $LOCAL_MAIL_SIZE"
    echo "📄 最近邮件内容预览:"
    tail -5 /var/mail/onion | grep -E "(From:|To:|Subject:|Date:)" | head -10
else
    echo "❌ 本地邮件文件不存在"
fi

# 检查网络连接
echo ""
echo "🌐 检查网络连接..."
echo "----------------------------------------"

# 测试QQ邮箱SMTP连接
echo "🔍 测试QQ邮箱SMTP连接..."
if nc -z -w5 smtp.qq.com 587 2>/dev/null; then
    echo "✅ QQ邮箱SMTP端口587可访问"
else
    echo "❌ QQ邮箱SMTP端口587不可访问"
fi

if nc -z -w5 smtp.qq.com 465 2>/dev/null; then
    echo "✅ QQ邮箱SMTP端口465可访问"
else
    echo "❌ QQ邮箱SMTP端口465不可访问"
fi

# 提供解决方案
echo ""
echo "========================================="
echo "💡 问题诊断结果和解决方案"
echo "========================================="

if [ "$INET_INTERFACES" = "loopback-only" ]; then
    echo "❌ 主要问题: Postfix配置为仅本地回环"
    echo "   这意味着邮件只能发送到本地，无法发送到外部邮箱"
    echo ""
    echo "🔧 解决方案:"
    echo "1. 配置SMTP中继服务器"
    echo "2. 使用外部邮件服务"
    echo "3. 配置本地SMTP服务器"
    echo ""
    echo "🚀 推荐解决方案: 配置QQ邮箱SMTP"
    echo "   编辑 /etc/postfix/main.cf 添加:"
    echo "   relayhost = [smtp.qq.com]:587"
    echo "   smtp_sasl_auth_enable = yes"
    echo "   smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
    echo "   smtp_sasl_security_options = noanonymous"
    echo "   smtp_tls_security_level = encrypt"
    echo "   smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
fi

echo ""
echo "📧 临时解决方案:"
echo "1. 使用Python脚本发送邮件"
echo "2. 使用curl发送邮件"
echo "3. 配置Jenkins邮件插件"
echo "4. 使用第三方邮件服务"

echo ""
echo "========================================="
echo "🔍 诊断完成"
echo "========================================="

