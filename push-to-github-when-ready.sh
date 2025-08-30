#!/bin/bash

# 网络恢复后推送到GitHub的脚本
# 当网络连接稳定时运行此脚本

echo "=========================================="
echo "📤 GitHub推送脚本"
echo "=========================================="

# 检查网络连接
echo "🌐 检查网络连接..."
if ping -c 2 github.com > /dev/null 2>&1; then
    echo "✅ GitHub连接正常"
else
    echo "❌ GitHub连接失败，请检查网络"
    exit 1
fi

# 检查Git状态
echo ""
echo "📋 检查Git状态..."
git status --porcelain
if [ $? -eq 0 ]; then
    echo "✅ Git状态正常"
else
    echo "❌ Git状态异常"
    exit 1
fi

# 显示最新提交
echo ""
echo "📊 最新提交信息："
git log --oneline -3

# 推送到GitHub
echo ""
echo "🚀 推送到GitHub..."
git push origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 推送成功！"
    echo "=========================================="
    echo "🔗 GitHub仓库: https://github.com/onion12138-bit/Automated-Testing1"
    echo "📧 邮件编码修复: 已推送"
    echo "🗑️ 文件清理: 已推送"
    echo "📝 提交信息: 包含详细的变更说明"
    echo ""
    echo "💡 下一步："
    echo "• Jenkins将在下次定时执行时使用最新代码"
    echo "• 今晚18:00会发送修复后的邮件"
    echo "• 不会再出现乱码和重复邮件问题"
else
    echo ""
    echo "=========================================="
    echo "❌ 推送失败"
    echo "=========================================="
    echo "请检查网络连接或重试"
fi

