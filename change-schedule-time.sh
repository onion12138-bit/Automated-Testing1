#!/bin/bash

# ==========================================
# 快速修改定时任务时间脚本
# ==========================================
# 功能: 快速修改定时任务的执行时间
# 使用方法: ./change-schedule-time.sh 小时 分钟
# 示例: ./change-schedule-time.sh 14 30 (设置为每天14:30)
# ==========================================

# 检查参数
if [ $# -ne 2 ]; then
    echo "========================================="
    echo "❌ 参数错误"
    echo "========================================="
    echo "使用方法: $0 小时 分钟"
    echo "示例: $0 14 30 (设置为每天14:30)"
    echo "示例: $0 9 15  (设置为每天09:15)"
    echo "========================================="
    exit 1
fi

HOUR=$1
MINUTE=$2

# 验证时间格式
if [[ ! "$MINUTE" =~ ^[0-5]?[0-9]$ ]] || [ "$MINUTE" -gt 59 ]; then
    echo "❌ 分钟格式错误: $MINUTE (应为0-59)"
    exit 1
fi

if [[ ! "$HOUR" =~ ^[0-9]|1[0-9]|2[0-3]$ ]] || [ "$HOUR" -gt 23 ]; then
    echo "❌ 小时格式错误: $HOUR (应为0-23)"
    exit 1
fi

echo "========================================="
echo "🕐 修改定时任务时间"
echo "========================================="
echo "📅 新时间: 每天 $HOUR:$MINUTE"
echo ""

# 备份原配置
cp schedule-config.sh schedule-config.sh.backup
echo "✅ 已备份原配置文件"

# 更新配置文件
sed -i '' "s/SCHEDULE_HOUR=\"[0-9]*\"/SCHEDULE_HOUR=\"$HOUR\"/" schedule-config.sh
sed -i '' "s/SCHEDULE_MINUTE=\"[0-9]*\"/SCHEDULE_MINUTE=\"$MINUTE\"/" schedule-config.sh

echo "✅ 配置文件已更新"

# 更新定时任务
./schedule-config.sh update

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "🎉 定时任务时间修改成功！"
    echo "========================================="
    echo "🕐 新执行时间: 每天 $HOUR:$MINUTE"
    echo "📧 收件人: 2335327949@qq.com"
    echo ""
    echo "📋 当前定时任务:"
    crontab -l
    echo ""
    echo "💡 提示: 如需恢复原配置，请运行:"
    echo "   cp schedule-config.sh.backup schedule-config.sh"
    echo "   ./schedule-config.sh update"
else
    echo ""
    echo "❌ 定时任务更新失败"
    echo "🔄 正在恢复原配置..."
    cp schedule-config.sh.backup schedule-config.sh
    echo "✅ 原配置已恢复"
    exit 1
fi 