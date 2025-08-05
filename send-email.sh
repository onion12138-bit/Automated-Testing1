#!/bin/bash

# JMeter测试结果邮件发送脚本
# 参数：$1=测试结果状态, $2=JTL文件路径, $3=HTML报告路径

echo "=========================================="
echo "准备发送测试结果邮件..."
echo "=========================================="

# 设置变量
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
TEST_STATUS="$1"
JTL_FILE="$2"
HTML_REPORT="$3"
TO_EMAIL="2335327949@qq.com"

# 从JTL文件提取测试统计信息
if [ -f "$JTL_FILE" ]; then
    # 提取测试统计（简化版本）
    TOTAL_SAMPLES=$(grep -c "sample" "$JTL_FILE" 2>/dev/null || echo "0")
    ERROR_COUNT=$(grep "success=\"false\"" "$JTL_FILE" | wc -l 2>/dev/null || echo "0")
    ERROR_COUNT=$(echo $ERROR_COUNT | tr -d ' ')  # 去除空格
    
    if [ "$TOTAL_SAMPLES" -gt 0 ] 2>/dev/null; then
        ERROR_RATE=$(echo "scale=2; $ERROR_COUNT * 100 / $TOTAL_SAMPLES" | bc 2>/dev/null || echo "0")
    else
        ERROR_RATE="0"
    fi
    
    # 提取平均响应时间（简化版本）
    AVG_TIME=$(grep "elapsed=" "$JTL_FILE" | head -10 | grep -o 'elapsed="[0-9]*"' | grep -o '[0-9]*' | awk '{sum+=$1; count++} END {if(count>0) print int(sum/count); else print "0"}' 2>/dev/null || echo "0")
else
    TOTAL_SAMPLES="0"
    ERROR_COUNT="0"
    ERROR_RATE="0"
    AVG_TIME="0"
fi

# 生成邮件内容
EMAIL_SUBJECT="JMeter自动化测试报告 - $TIMESTAMP"
EMAIL_BODY="JMeter自动化测试执行完成！

测试时间: $TIMESTAMP
测试状态: $TEST_STATUS
执行用例数: $TOTAL_SAMPLES
错误数量: $ERROR_COUNT
错误率: ${ERROR_RATE}%
平均响应时间: ${AVG_TIME}ms

Git提交信息: $(git log --oneline -1 2>/dev/null || echo "无Git信息")

测试报告文件:
- JTL数据文件: $JTL_FILE
- HTML报告: $HTML_REPORT

详细报告请查看Jenkins或本地文件系统中的HTML报告。

---
此邮件由JMeter自动化测试系统自动发送
发送时间: $TIMESTAMP"

# 创建临时邮件文件
TEMP_EMAIL_FILE="/tmp/jmeter_email_$(date +%s).txt"
echo "$EMAIL_BODY" > "$TEMP_EMAIL_FILE"

echo "邮件内容已准备："
echo "收件人: $TO_EMAIL"
echo "主题: $EMAIL_SUBJECT"
echo "内容预览:"
echo "----------------------------------------"
head -15 "$TEMP_EMAIL_FILE"
echo "----------------------------------------"

# 使用系统邮件命令发送（需要配置本地邮件服务）
if command -v mail >/dev/null 2>&1; then
    echo "尝试使用系统mail命令发送邮件..."
    if mail -s "$EMAIL_SUBJECT" "$TO_EMAIL" < "$TEMP_EMAIL_FILE" 2>/dev/null; then
        echo "✅ 邮件发送成功（使用系统mail命令）"
    else
        echo "⚠️ 系统mail命令发送失败，需要配置SMTP"
    fi
else
    echo "⚠️ 系统未安装mail命令"
fi

# 使用Python发送邮件（如果可用且配置了SMTP）
if command -v python3 >/dev/null 2>&1; then
    echo "尝试使用Python发送邮件..."
    python3 -c "
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys

try:
    # 注意：这里需要真实的SMTP配置才能工作
    print('Python邮件发送功能需要SMTP配置，当前仅显示邮件内容')
    print('如需实际发送，请在email-config.properties中配置真实的邮箱信息')
except Exception as e:
    print(f'Python邮件发送失败: {e}')
"
fi

# 清理临时文件
rm -f "$TEMP_EMAIL_FILE"

echo ""
echo "📧 邮件处理完成！"
echo "注意: 如需实际发送邮件，请配置SMTP服务器或使用Jenkins的邮件插件"