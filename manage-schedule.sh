#!/bin/bash

# ==========================================
# Ford Smart Badge 定时任务管理脚本
# ==========================================
# 功能: 管理每日自动化测试的定时任务
# ==========================================

# 加载配置文件
source "$(dirname "$0")/schedule-config.sh"
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
SCRIPT_PATH="$WORKSPACE_DIR/schedule-daily-test.sh"

echo "========================================="
echo "🕐 Ford Smart Badge 定时任务管理"
echo "========================================="

case "$1" in
    "status")
        echo "📋 当前定时任务状态:"
        echo "----------------------------------------"
        crontab -l 2>/dev/null || echo "❌ 没有设置定时任务"
        echo "----------------------------------------"
        echo "📁 脚本路径: $SCRIPT_PATH"
        if [ -f "$SCRIPT_PATH" ]; then
            echo "✅ 脚本文件存在"
            ls -la "$SCRIPT_PATH"
        else
            echo "❌ 脚本文件不存在"
        fi
        ;;
    
    "start")
        echo "🚀 启动定时任务..."
        echo "25 19 * * * $SCRIPT_PATH" | crontab -
        if [ $? -eq 0 ]; then
                    echo "✅ 定时任务启动成功"
        echo "📅 执行时间: 每天 $SCHEDULE_HOUR:$SCHEDULE_MINUTE"
            echo "📧 收件人: 2335327949@qq.com"
        else
            echo "❌ 定时任务启动失败"
        fi
        ;;
    
    "stop")
        echo "🛑 停止定时任务..."
        crontab -r
        if [ $? -eq 0 ]; then
            echo "✅ 定时任务已停止"
        else
            echo "❌ 停止定时任务失败"
        fi
        ;;
    
    "test")
        echo "🧪 测试定时脚本..."
        if [ -f "$SCRIPT_PATH" ]; then
            echo "执行测试脚本..."
            "$SCRIPT_PATH"
        else
            echo "❌ 脚本文件不存在: $SCRIPT_PATH"
        fi
        ;;
    
    "log")
        echo "📄 查看执行日志..."
        LOG_FILE="$WORKSPACE_DIR/daily-test.log"
        if [ -f "$LOG_FILE" ]; then
            echo "最近的执行日志:"
            echo "----------------------------------------"
            tail -50 "$LOG_FILE"
            echo "----------------------------------------"
        else
            echo "❌ 日志文件不存在: $LOG_FILE"
        fi
        ;;
    
    "install")
        echo "📦 安装定时任务系统..."
        
        # 检查脚本文件
        if [ ! -f "$SCRIPT_PATH" ]; then
            echo "❌ 脚本文件不存在: $SCRIPT_PATH"
            exit 1
        fi
        
        # 添加执行权限
        chmod +x "$SCRIPT_PATH"
        echo "✅ 脚本权限设置完成"
        
        # 设置定时任务
        echo "$SCHEDULE_EXPRESSION $SCRIPT_PATH" | crontab -
        if [ $? -eq 0 ]; then
            echo "✅ 定时任务安装成功"
            echo "📅 执行时间: 每天 $SCHEDULE_HOUR:$SCHEDULE_MINUTE"
            echo "📧 收件人: 2335327949@qq.com"
            echo "📁 脚本路径: $SCRIPT_PATH"
        else
            echo "❌ 定时任务安装失败"
            exit 1
        fi
        
        # 显示当前状态
        echo ""
        echo "📋 当前定时任务:"
        crontab -l
        ;;
    
    *)
        echo "使用方法: $0 {status|start|stop|test|log|install}"
        echo ""
        echo "命令说明:"
        echo "  status  - 查看定时任务状态"
        echo "  start   - 启动定时任务"
        echo "  stop    - 停止定时任务"
        echo "  test    - 测试执行脚本"
        echo "  log     - 查看执行日志"
        echo "  install - 安装定时任务系统"
        echo ""
        echo "📅 定时任务配置:"
        echo "  执行时间: 每天 $SCHEDULE_HOUR:$SCHEDULE_MINUTE"
        echo "  收件人: 2335327949@qq.com"
        echo "  脚本: $SCRIPT_PATH"
        ;;
esac 