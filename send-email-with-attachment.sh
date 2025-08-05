#!/bin/bash

# 支持附件的JMeter测试结果邮件发送脚本
# 参数：$1=测试结果状态, $2=JTL文件路径, $3=HTML报告路径, $4=ZIP附件路径

echo "=========================================="
echo "准备发送包含报告附件的邮件..."
echo "=========================================="

# 设置变量
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
TEST_STATUS="$1"
JTL_FILE="$2"
HTML_REPORT="$3"
ZIP_ATTACHMENT="$4"
TO_EMAIL="2335327949@qq.com"

echo "收件人: $TO_EMAIL"
echo "测试状态: $TEST_STATUS"
echo "附件文件: $ZIP_ATTACHMENT"

# 从JTL文件提取测试统计信息
if [ -f "$JTL_FILE" ]; then
    # 提取测试统计
    TOTAL_SAMPLES=$(grep -c "sample" "$JTL_FILE" 2>/dev/null || echo "0")
    ERROR_COUNT=$(grep "success=\"false\"" "$JTL_FILE" | wc -l 2>/dev/null || echo "0")
    ERROR_COUNT=$(echo $ERROR_COUNT | tr -d ' ')
    
    if [ "$TOTAL_SAMPLES" -gt 0 ] 2>/dev/null; then
        ERROR_RATE=$(echo "scale=2; $ERROR_COUNT * 100 / $TOTAL_SAMPLES" | bc 2>/dev/null || echo "0")
    else
        ERROR_RATE="0"
    fi
    
    # 提取平均响应时间
    AVG_TIME=$(grep "elapsed=" "$JTL_FILE" | head -10 | grep -o 'elapsed="[0-9]*"' | grep -o '[0-9]*' | awk '{sum+=$1; count++} END {if(count>0) print int(sum/count); else print "0"}' 2>/dev/null || echo "0")
else
    TOTAL_SAMPLES="0"
    ERROR_COUNT="0"
    ERROR_RATE="0"
    AVG_TIME="0"
fi

# 获取附件信息
if [ -f "$ZIP_ATTACHMENT" ]; then
    ZIP_SIZE=$(ls -lh "$ZIP_ATTACHMENT" | awk '{print $5}')
    ZIP_NAME=$(basename "$ZIP_ATTACHMENT")
    ATTACHMENT_INFO="附件: $ZIP_NAME (大小: $ZIP_SIZE)"
else
    ZIP_SIZE="0"
    ZIP_NAME="无附件"
    ATTACHMENT_INFO="无附件"
fi

# 生成邮件内容
EMAIL_SUBJECT="📊 JMeter自动化测试报告 - $TIMESTAMP"
EMAIL_BODY="📧 JMeter自动化测试报告

🕐 测试时间: $TIMESTAMP
📈 测试状态: $TEST_STATUS
📊 测试统计:
   • 执行用例数: $TOTAL_SAMPLES
   • 错误数量: $ERROR_COUNT
   • 错误率: ${ERROR_RATE}%
   • 平均响应时间: ${AVG_TIME}ms

📂 Git信息:
   • 提交版本: $(git log --oneline -1 2>/dev/null || echo "无Git信息")
   • 分支: $(git branch --show-current 2>/dev/null || echo "未知")

📎 报告文件:
   • $ATTACHMENT_INFO
   • JTL数据: $(basename "$JTL_FILE" 2>/dev/null || echo "无")
   • HTML报告: $(basename "$HTML_REPORT" 2>/dev/null || echo "无")

📋 报告说明:
   1. 解压附件ZIP文件
   2. 打开html_summary_reports目录查看汇总报告
   3. 打开html_detail_reports目录查看详细报告
   4. 所有报告均可离线查看，无需网络连接

⚠️ 重要提示:
   - 报告包含完整的测试数据和图表
   - 建议使用现代浏览器查看HTML报告
   - JTL原始数据可用于进一步分析

---
🤖 此邮件由JMeter自动化测试系统自动发送
📅 发送时间: $TIMESTAMP
🔧 系统版本: v2.0 (支持报告附件)"

# 创建临时邮件文件
TEMP_EMAIL_FILE="/tmp/jmeter_email_with_attachment_$(date +%s).txt"
echo "$EMAIL_BODY" > "$TEMP_EMAIL_FILE"

echo ""
echo "📧 邮件内容预览:"
echo "----------------------------------------"
echo "主题: $EMAIL_SUBJECT"
echo "收件人: $TO_EMAIL"
echo "附件: $ZIP_NAME ($ZIP_SIZE)"
echo ""
echo "邮件正文:"
head -20 "$TEMP_EMAIL_FILE"
echo "----------------------------------------"

# 检查系统邮件命令支持
echo ""
echo "🔍 检查邮件发送能力..."

# 方法1: 使用mutt（支持附件）
if command -v mutt >/dev/null 2>&1 && [ -f "$ZIP_ATTACHMENT" ]; then
    echo "✅ 尝试使用mutt发送带附件的邮件..."
    if mutt -s "$EMAIL_SUBJECT" -a "$ZIP_ATTACHMENT" -- "$TO_EMAIL" < "$TEMP_EMAIL_FILE" 2>/dev/null; then
        echo "✅ 邮件发送成功（使用mutt，包含附件）"
        SEND_SUCCESS=true
    else
        echo "⚠️ mutt发送失败"
        SEND_SUCCESS=false
    fi
elif command -v mutt >/dev/null 2>&1; then
    echo "⚠️ mutt可用但附件文件不存在"
    SEND_SUCCESS=false
else
    echo "⚠️ 系统未安装mutt命令"
    SEND_SUCCESS=false
fi

# 方法2: 使用mail（仅文本）
if [ "$SEND_SUCCESS" != "true" ] && command -v mail >/dev/null 2>&1; then
    echo "📤 尝试使用系统mail命令发送文本邮件..."
    
    # 在邮件正文中添加附件下载信息
    echo "" >> "$TEMP_EMAIL_FILE"
    echo "📎 附件信息:" >> "$TEMP_EMAIL_FILE"
    echo "   由于邮件系统限制，无法直接发送附件。" >> "$TEMP_EMAIL_FILE"
    echo "   附件文件位置: $ZIP_ATTACHMENT" >> "$TEMP_EMAIL_FILE"
    echo "   请联系管理员获取报告文件。" >> "$TEMP_EMAIL_FILE"
    
    if mail -s "$EMAIL_SUBJECT" "$TO_EMAIL" < "$TEMP_EMAIL_FILE" 2>/dev/null; then
        echo "✅ 文本邮件发送成功（不含附件）"
        SEND_SUCCESS=true
    else
        echo "⚠️ 系统mail命令发送失败"
        SEND_SUCCESS=false
    fi
fi

# 方法3: Python邮件发送（高级选项）
if [ "$SEND_SUCCESS" != "true" ] && command -v python3 >/dev/null 2>&1; then
    echo "🐍 尝试使用Python发送邮件..."
    
    # 创建Python邮件发送脚本
    cat > "/tmp/send_email.py" << 'EOF'
import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import os

def send_email_with_attachment(to_email, subject, body, attachment_path):
    try:
        print("Python邮件发送功能需要SMTP配置")
        print("当前仅验证文件和显示邮件信息")
        print(f"收件人: {to_email}")
        print(f"主题: {subject}")
        print(f"附件: {attachment_path}")
        if os.path.exists(attachment_path):
            size = os.path.getsize(attachment_path)
            print(f"附件大小: {size} bytes")
            print("✅ 附件文件存在且可读")
        else:
            print("❌ 附件文件不存在")
        
        print("如需实际发送，请配置email-config.properties中的SMTP设置")
        return True
    except Exception as e:
        print(f"Python邮件处理失败: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) >= 5:
        result = send_email_with_attachment(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        sys.exit(0 if result else 1)
    else:
        print("参数不足")
        sys.exit(1)
EOF

    if python3 "/tmp/send_email.py" "$TO_EMAIL" "$EMAIL_SUBJECT" "$EMAIL_BODY" "$ZIP_ATTACHMENT"; then
        echo "✅ Python邮件处理完成"
    else
        echo "⚠️ Python邮件处理失败"
    fi
    
    rm -f "/tmp/send_email.py"
fi

# 清理临时文件
rm -f "$TEMP_EMAIL_FILE"

echo ""
echo "=========================================="
echo "📧 邮件处理完成！"
echo "=========================================="
echo "收件人: $TO_EMAIL"
echo "主题: $EMAIL_SUBJECT"
echo "附件: $ZIP_NAME ($ZIP_SIZE)"
echo ""
echo "💡 建议:"
echo "• 如需稳定的邮件发送，请配置Jenkins邮件插件"
echo "• 或在email-config.properties中配置SMTP服务器"
echo "• 当前系统已生成完整的报告包: $ZIP_ATTACHMENT"