#!/bin/bash

# ==========================================
# 定时任务诊断脚本
# ==========================================
# 功能: 全面诊断定时任务问题
# ==========================================

echo "========================================="
echo "🔍 定时任务问题诊断"
echo "========================================="

# 加载配置文件
source "$(dirname "$0")/schedule-config.sh"

echo "🕐 当前时间: $(date)"
echo "📅 当前日期: $(date '+%Y-%m-%d')"
echo ""

# 1. 检查定时任务配置
echo "1️⃣ 检查定时任务配置:"
echo "----------------------------------------"
crontab -l 2>/dev/null || echo "❌ 没有设置定时任务"
echo ""

# 2. 检查配置文件
echo "2️⃣ 检查配置文件:"
echo "----------------------------------------"
echo "📁 配置文件: schedule-config.sh"
echo "🕐 配置时间: $SCHEDULE_HOUR:$SCHEDULE_MINUTE"
echo "📅 定时表达式: $SCHEDULE_EXPRESSION"
echo ""

# 3. 检查脚本文件
echo "3️⃣ 检查脚本文件:"
echo "----------------------------------------"
if [ -f "$SCRIPT_PATH" ]; then
    echo "✅ 脚本文件存在: $SCRIPT_PATH"
    ls -la "$SCRIPT_PATH"
else
    echo "❌ 脚本文件不存在: $SCRIPT_PATH"
fi
echo ""

# 4. 检查日志文件
echo "4️⃣ 检查日志文件:"
echo "----------------------------------------"
if [ -f "$LOG_FILE" ]; then
    echo "✅ 日志文件存在: $LOG_FILE"
    echo "📊 文件大小: $(ls -lh "$LOG_FILE" | awk '{print $5}')"
    echo "📅 最后修改: $(ls -la "$LOG_FILE" | awk '{print $6, $7, $8}')"
    echo ""
    echo "📋 最近的执行记录:"
    grep -E "开始执行每日自动化测试|每日自动化测试完成" "$LOG_FILE" | tail -6
else
    echo "❌ 日志文件不存在: $LOG_FILE"
fi
echo ""

# 5. 检查邮件发送能力
echo "5️⃣ 检查邮件发送能力:"
echo "----------------------------------------"
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
echo ""

# 6. 检查最新的ZIP报告
echo "6️⃣ 检查最新报告:"
echo "----------------------------------------"
LATEST_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
if [ -n "$LATEST_ZIP" ] && [ -f "$LATEST_ZIP" ]; then
    echo "✅ 找到最新报告: $LATEST_ZIP"
    echo "📊 文件大小: $(ls -lh "$LATEST_ZIP" | awk '{print $5}')"
    echo "📅 创建时间: $(ls -la "$LATEST_ZIP" | awk '{print $6, $7, $8}')"
else
    echo "❌ 未找到ZIP报告文件"
fi
echo ""

# 7. 检查cron服务状态
echo "7️⃣ 检查cron服务状态:"
echo "----------------------------------------"
if pgrep -x "cron" > /dev/null; then
    echo "✅ cron进程正在运行"
else
    echo "❌ cron进程未运行"
fi

# 检查launchd中的cron
if launchctl list | grep -q cron; then
    echo "✅ launchd中的cron服务存在"
else
    echo "❌ launchd中的cron服务不存在"
fi
echo ""

# 8. 检查系统时间
echo "8️⃣ 检查系统时间:"
echo "----------------------------------------"
echo "🕐 系统时间: $(date)"
echo "⏰ 时区: $(date '+%Z')"
echo ""

# 9. 计算下次执行时间
echo "9️⃣ 下次执行时间:"
echo "----------------------------------------"
CURRENT_HOUR=$(date '+%H')
CURRENT_MINUTE=$(date '+%M')
SCHEDULED_HOUR=$SCHEDULE_HOUR
SCHEDULED_MINUTE=$SCHEDULE_MINUTE

if [ "$CURRENT_HOUR" -lt "$SCHEDULED_HOUR" ] || ([ "$CURRENT_HOUR" -eq "$SCHEDULED_HOUR" ] && [ "$CURRENT_MINUTE" -lt "$SCHEDULED_MINUTE" ]); then
    echo "🕐 今天 $SCHEDULED_HOUR:$SCHEDULED_MINUTE 执行"
else
    echo "🕐 明天 $SCHEDULED_HOUR:$SCHEDULED_MINUTE 执行"
fi
echo ""

# 10. 问题诊断
echo "🔟 问题诊断:"
echo "----------------------------------------"

# 检查配置是否一致
CRON_LINE=$(crontab -l 2>/dev/null | grep schedule-daily-test.sh)
if [ -n "$CRON_LINE" ]; then
    CRON_TIME=$(echo "$CRON_LINE" | awk '{print $1, $2}')
    CONFIG_TIME="$SCHEDULE_MINUTE $SCHEDULE_HOUR"
    
    if [ "$CRON_TIME" = "$CONFIG_TIME" ]; then
        echo "✅ 定时任务和配置文件时间一致"
    else
        echo "❌ 定时任务和配置文件时间不一致"
        echo "   定时任务: $CRON_TIME"
        echo "   配置文件: $CONFIG_TIME"
    fi
else
    echo "❌ 未找到定时任务"
fi

# 检查今天是否应该执行
if [ "$CURRENT_HOUR" -gt "$SCHEDULED_HOUR" ] || ([ "$CURRENT_HOUR" -eq "$SCHEDULED_HOUR" ] && [ "$CURRENT_MINUTE" -gt "$SCHEDULED_MINUTE" ]); then
    echo "⚠️ 今天应该已经执行过了，检查是否成功"
    
    # 检查今天的执行记录
    TODAY=$(date '+%Y-%m-%d')
    if grep -q "开始执行每日自动化测试 - $TODAY" "$LOG_FILE" 2>/dev/null; then
        echo "✅ 今天已有执行记录"
    else
        echo "❌ 今天没有执行记录"
    fi
fi

echo ""
echo "========================================="
echo "💡 建议解决方案:"
echo "========================================="

if [ "$CURRENT_HOUR" -gt "$SCHEDULED_HOUR" ] || ([ "$CURRENT_HOUR" -eq "$SCHEDULED_HOUR" ] && [ "$CURRENT_MINUTE" -gt "$SCHEDULED_MINUTE" ]); then
    echo "1. 手动执行测试: ./schedule-daily-test.sh"
    echo "2. 检查邮箱是否收到邮件"
    echo "3. 等待明天 $SCHEDULED_HOUR:$SCHEDULED_MINUTE 的自动执行"
else
    echo "1. 等待今天 $SCHEDULED_HOUR:$SCHEDULED_MINUTE 的自动执行"
    echo "2. 手动执行测试: ./schedule-daily-test.sh"
fi

echo "3. 查看执行日志: tail -f daily-test.log"
echo "4. 检查系统状态: ./manage-schedule.sh status"
echo "=========================================" 