#!/bin/bash

# ==========================================
# 定时任务测试脚本
# ==========================================
# 功能: 测试定时任务是否能正常执行
# ==========================================

echo "========================================="
echo "🧪 定时任务测试脚本"
echo "========================================="

# 检查当前时间
echo "🕐 当前时间: $(date)"
echo "📅 当前日期: $(date '+%Y-%m-%d')"

# 检查定时任务状态
echo ""
echo "📋 定时任务状态:"
crontab -l 2>/dev/null || echo "❌ 没有设置定时任务"

# 检查脚本文件
SCRIPT_PATH="/Users/onion/Desktop/JmeterMac2/schedule-daily-test.sh"
echo ""
echo "📁 脚本文件检查:"
if [ -f "$SCRIPT_PATH" ]; then
    echo "✅ 脚本文件存在: $SCRIPT_PATH"
    ls -la "$SCRIPT_PATH"
else
    echo "❌ 脚本文件不存在: $SCRIPT_PATH"
fi

# 检查日志文件
LOG_FILE="/Users/onion/Desktop/JmeterMac2/daily-test.log"
echo ""
echo "📄 日志文件检查:"
if [ -f "$LOG_FILE" ]; then
    echo "✅ 日志文件存在: $LOG_FILE"
    echo "📊 文件大小: $(ls -lh "$LOG_FILE" | awk '{print $5}')"
    echo "📅 最后修改: $(ls -la "$LOG_FILE" | awk '{print $6, $7, $8}')"
else
    echo "❌ 日志文件不存在: $LOG_FILE"
fi

# 检查邮件发送能力
echo ""
echo "📧 邮件发送能力检查:"
if command -v mutt &> /dev/null; then
    echo "✅ mutt可用: $(which mutt)"
else
    echo "❌ mutt不可用"
fi

if command -v mail &> /dev/null; then
    echo "✅ mail可用: $(which mail)"
else
    echo "❌ mail不可用"
fi

# 检查最新的ZIP报告
echo ""
echo "📦 最新报告检查:"
LATEST_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
if [ -n "$LATEST_ZIP" ] && [ -f "$LATEST_ZIP" ]; then
    echo "✅ 找到最新报告: $LATEST_ZIP"
    echo "📊 文件大小: $(ls -lh "$LATEST_ZIP" | awk '{print $5}')"
    echo "📅 创建时间: $(ls -la "$LATEST_ZIP" | awk '{print $6, $7, $8}')"
else
    echo "❌ 未找到ZIP报告文件"
fi

# 显示今天的执行时间
echo ""
echo "📅 今天的执行时间:"
echo "🕐 19:25 - 定时任务执行时间"
echo "📧 收件人: 2335327949@qq.com"

# 显示最近的执行记录
echo ""
echo "📋 最近的执行记录:"
if [ -f "$LOG_FILE" ]; then
    echo "最近3次执行记录:"
    grep -E "开始执行每日自动化测试|每日自动化测试完成" "$LOG_FILE" | tail -6
else
    echo "❌ 没有执行记录"
fi

echo ""
echo "========================================="
echo "✅ 定时任务测试完成"
echo "=========================================" 