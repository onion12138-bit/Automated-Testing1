#!/bin/bash

# 邮件编码测试脚本
# 测试修复后的邮件发送是否支持UTF-8编码

echo "=========================================="
echo "📧 邮件编码测试脚本"
echo "=========================================="

# 设置UTF-8编码环境
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

echo "🔍 当前编码环境："
echo "LANG: $LANG"
echo "LC_ALL: $LC_ALL"
echo ""

# 测试邮件内容（包含中文和emoji）
TEST_SUBJECT="📊 邮件编码测试 - $(date '+%Y-%m-%d %H:%M:%S')"
TEST_BODY="📧 JMeter邮件编码测试

🕐 测试时间: $(date '+%Y-%m-%d %H:%M:%S')
📈 测试目的: 验证UTF-8编码支持
📊 测试内容:
   • 中文字符显示测试
   • Emoji表情符号测试: 📧 📊 🕐 📈 📎 ✅ ⚠️ ❌
   • 特殊字符测试: ¥ € £ © ® ™

🎯 测试结果: 如果您能正常看到以上所有字符，说明UTF-8编码修复成功！

---
JMeter自动化测试系统编码测试
"

echo "📝 测试邮件内容："
echo "主题: $TEST_SUBJECT"
echo "正文:"
echo "$TEST_BODY"
echo ""

# 创建测试ZIP文件
TEST_ZIP="/tmp/encoding_test_$(date +%s).zip"
echo "测试UTF-8编码支持" > "/tmp/test_content.txt"
zip -q "$TEST_ZIP" "/tmp/test_content.txt"

echo "📦 创建测试附件: $TEST_ZIP"
echo ""

# 测试修复后的邮件发送脚本
echo "🚀 测试修复后的邮件发送脚本..."
echo ""

if [ -f "send-email-with-attachment.sh" ]; then
    echo "📧 执行send-email-with-attachment.sh测试..."
    ./send-email-with-attachment.sh "TEST" "/dev/null" "/dev/null" "$TEST_ZIP"
else
    echo "❌ send-email-with-attachment.sh 不存在"
fi

echo ""
echo "=========================================="
echo "📊 测试完成"
echo "=========================================="
echo "💡 检查要点："
echo "• 查看邮件发送日志中是否显示'UTF-8编码'"
echo "• 确认使用了Python脚本而非系统mail命令"
echo "• 检查是否避免了重复发送"
echo ""
echo "📧 如果收到测试邮件，请检查："
echo "• 中文字符是否正常显示"
echo "• Emoji表情是否正确显示"
echo "• 是否只收到一封邮件（不重复）"

# 清理测试文件
rm -f "$TEST_ZIP" "/tmp/test_content.txt"
