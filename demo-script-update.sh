#!/bin/bash

echo "=========================================="
echo "演示Git集成 - 模拟脚本更新流程"
echo "=========================================="

# 1. 显示当前状态
echo "1. 当前Git状态:"
git log --oneline -3
echo ""

# 2. 模拟修改测试脚本（添加注释）
echo "2. 模拟修改测试脚本..."
# 这里只是演示，实际使用时你会修改.jmx文件
echo "<!-- 这是一个测试注释 - $(date) -->" >> jmeter-script/test-comment.txt

# 3. 提交修改
echo "3. 提交修改到Git:"
git add .
git commit -m "Update test script - $(date)"

# 4. 显示新的Git状态
echo ""
echo "4. 更新后的Git状态:"
git log --oneline -3

# 5. 执行Jenkins模拟测试
echo ""
echo "5. 执行Jenkins测试（会自动拉取最新代码）:"
echo "============================================"
./jenkins-simulation.sh