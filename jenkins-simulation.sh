#!/bin/bash

# Jenkins 模拟脚本 - 模拟 Jenkins 从 Git 拉取代码并执行测试
echo "=========================================="
echo "Jenkins 自动化测试模拟开始"
echo "=========================================="

# 设置工作目录
WORKSPACE="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE"

echo "当前工作目录: $(pwd)"
echo "时间戳: $(date)"

# 1. 显示当前Git状态
echo ""
echo "1. Git 状态检查:"
echo "当前分支: $(git branch --show-current)"
echo "最新提交: $(git log --oneline -1)"

# 2. 拉取最新代码（如果有远程仓库）
echo ""
echo "2. 尝试拉取最新代码:"
if git remote | grep -q origin; then
    echo "检测到远程仓库，正在拉取最新代码..."
    git pull origin master
else
    echo "未配置远程仓库，跳过拉取步骤"
fi

# 3. 显示当前测试脚本
echo ""
echo "3. 当前测试脚本:"
ls -la jmeter-script/

# 4. 执行Ant构建
echo ""
echo "4. 执行自动化测试:"
echo "=========================================="
ant run

# 5. 显示结果
echo ""
echo "=========================================="
echo "Jenkins 自动化测试模拟完成"
echo "=========================================="
echo "测试结果位置:"
echo "- JTL 文件: jmeter-results/jtl/"
echo "- HTML 报告: jmeter-results/html/"
echo "- 详细报告: jmeter-results/detail/"