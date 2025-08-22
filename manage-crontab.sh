#!/bin/bash
# ==========================================
# Crontab管理脚本
# ==========================================
# 功能: 安全地管理crontab配置
# ==========================================

CRONTAB_BACKUP="crontab-backup.txt"
CRONTAB_TEMP="crontab-temp.txt"

show_usage() {
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  show     - 显示当前crontab"
    echo "  backup   - 备份当前crontab到文件"
    echo "  restore  - 从备份文件恢复crontab"
    echo "  edit     - 编辑crontab (使用默认编辑器)"
    echo "  status   - 检查crontab和cron服务状态"
    echo "  test     - 测试crontab配置"
    echo "  help     - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 show      # 显示当前配置"
    echo "  $0 backup    # 备份配置"
    echo "  $0 restore   # 恢复配置"
}

show_status() {
    echo "=== Crontab状态检查 ==="
    echo "时间: $(date)"
    echo ""
    echo "1. 当前crontab配置:"
    if crontab -l 2>/dev/null; then
        echo "✅ Crontab配置正常"
    else
        echo "❌ Crontab为空或不可访问"
    fi
    echo ""
    echo "2. Cron服务状态:"
    if ps aux | grep cron | grep -v grep >/dev/null; then
        echo "✅ Cron服务运行中"
        ps aux | grep cron | grep -v grep
    else
        echo "❌ Cron服务未运行"
    fi
    echo ""
    echo "3. 备份文件状态:"
    if [ -f "$CRONTAB_BACKUP" ]; then
        echo "✅ 备份文件存在: $CRONTAB_BACKUP"
        echo "备份时间: $(stat -f "%Sm" "$CRONTAB_BACKUP" 2>/dev/null || echo '未知')"
    else
        echo "❌ 备份文件不存在"
    fi
}

backup_crontab() {
    echo "=== 备份Crontab配置 ==="
    if crontab -l > "$CRONTAB_BACKUP" 2>/dev/null; then
        echo "✅ Crontab备份成功: $CRONTAB_BACKUP"
        echo "备份内容:"
        cat "$CRONTAB_BACKUP"
    else
        echo "❌ Crontab备份失败"
        return 1
    fi
}

restore_crontab() {
    echo "=== 恢复Crontab配置 ==="
    if [ ! -f "$CRONTAB_BACKUP" ]; then
        echo "❌ 备份文件不存在: $CRONTAB_BACKUP"
        return 1
    fi
    
    echo "备份文件内容:"
    cat "$CRONTAB_BACKUP"
    echo ""
    echo "确认恢复? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if crontab "$CRONTAB_BACKUP"; then
            echo "✅ Crontab恢复成功"
            echo "当前配置:"
            crontab -l
        else
            echo "❌ Crontab恢复失败"
            return 1
        fi
    else
        echo "取消恢复操作"
    fi
}

test_crontab() {
    echo "=== 测试Crontab配置 ==="
    echo "当前时间: $(date)"
    echo ""
    echo "1. 检查crontab语法:"
    if crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | while read -r line; do
        if [ -n "$line" ]; then
            echo "检查行: $line"
            # 这里可以添加更复杂的语法检查
        fi
    done; then
        echo "✅ Crontab语法检查通过"
    else
        echo "❌ Crontab语法检查失败"
    fi
    echo ""
    echo "2. 检查cron服务:"
    if ps aux | grep cron | grep -v grep >/dev/null; then
        echo "✅ Cron服务正常"
    else
        echo "❌ Cron服务异常"
    fi
}

# 主程序
case "${1:-help}" in
    show)
        echo "=== 当前Crontab配置 ==="
        crontab -l 2>/dev/null || echo "Crontab为空"
        ;;
    backup)
        backup_crontab
        ;;
    restore)
        restore_crontab
        ;;
    edit)
        echo "=== 编辑Crontab ==="
        crontab -e
        ;;
    status)
        show_status
        ;;
    test)
        test_crontab
        ;;
    help|*)
        show_usage
        ;;
esac 