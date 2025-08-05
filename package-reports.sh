#!/bin/bash

# JMeter测试报告打包脚本
# 将HTML和详细报告打包成ZIP文件，方便邮件发送

echo "=========================================="
echo "开始打包JMeter测试报告..."
echo "=========================================="

# 设置变量
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
PACKAGE_NAME="JMeter_Report_${TIMESTAMP}"
PACKAGE_DIR="/tmp/${PACKAGE_NAME}"
ZIP_FILE="/tmp/${PACKAGE_NAME}.zip"

HTML_REPORT_DIR="jmeter-results/html"
DETAIL_REPORT_DIR="jmeter-results/detail"
JTL_DIR="jmeter-results/jtl"

echo "时间戳: $TIMESTAMP"
echo "打包目录: $PACKAGE_DIR"
echo "ZIP文件: $ZIP_FILE"

# 创建临时打包目录
mkdir -p "$PACKAGE_DIR"

# 检查并复制HTML报告
if [ -d "$HTML_REPORT_DIR" ] && [ "$(ls -A $HTML_REPORT_DIR 2>/dev/null)" ]; then
    echo "✅ 复制HTML汇总报告..."
    cp -r "$HTML_REPORT_DIR" "$PACKAGE_DIR/html_summary_reports"
    HTML_COUNT=$(find "$HTML_REPORT_DIR" -name "*.html" | wc -l)
    echo "   HTML报告文件数: $HTML_COUNT"
else
    echo "⚠️ HTML报告目录为空或不存在"
fi

# 检查并复制详细报告
if [ -d "$DETAIL_REPORT_DIR" ] && [ "$(ls -A $DETAIL_REPORT_DIR 2>/dev/null)" ]; then
    echo "✅ 复制HTML详细报告..."
    cp -r "$DETAIL_REPORT_DIR" "$PACKAGE_DIR/html_detail_reports"
    DETAIL_COUNT=$(find "$DETAIL_REPORT_DIR" -name "*.html" | wc -l)
    echo "   详细报告文件数: $DETAIL_COUNT"
else
    echo "⚠️ 详细报告目录为空或不存在"
fi

# 复制JTL原始数据（可选）
if [ -d "$JTL_DIR" ] && [ "$(ls -A $JTL_DIR 2>/dev/null)" ]; then
    echo "✅ 复制JTL原始数据..."
    cp -r "$JTL_DIR" "$PACKAGE_DIR/jtl_raw_data"
    JTL_COUNT=$(find "$JTL_DIR" -name "*.jtl" | wc -l)
    echo "   JTL数据文件数: $JTL_COUNT"
fi

# 创建说明文件
cat > "$PACKAGE_DIR/README.md" << EOF
# JMeter自动化测试报告包

## 报告生成时间
$TIMESTAMP

## Git信息
提交版本: $(git log --oneline -1 2>/dev/null || echo "无Git信息")
分支: $(git branch --show-current 2>/dev/null || echo "未知")

## 目录说明
- **html_summary_reports/**: HTML汇总报告
  - 包含测试概览、统计图表
  - 打开 *.html 文件查看汇总结果

- **html_detail_reports/**: HTML详细报告  
  - 包含每个请求的详细信息
  - 打开 *.html 文件查看详细结果

- **jtl_raw_data/**: JTL原始数据
  - JMeter原始测试数据
  - 可导入JMeter GUI进行分析

## 使用方法
1. 解压此ZIP文件
2. 用浏览器打开HTML报告文件
3. 查看测试结果和性能数据

## 注意事项
- HTML报告最佳在现代浏览器中查看
- JTL文件可以用JMeter GUI重新生成图表
- 报告中的图片和CSS已包含，无需网络连接

---
生成时间: $(date)
由JMeter自动化测试系统生成
EOF

# 显示打包内容
echo ""
echo "📦 打包内容预览:"
echo "----------------------------------------"
find "$PACKAGE_DIR" -type f | sort | sed 's|^/tmp/[^/]*/||' | head -20
echo "----------------------------------------"

# 创建ZIP压缩包
echo ""
echo "🗜️ 创建ZIP压缩包..."
cd /tmp
if zip -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}" >/dev/null 2>&1; then
    echo "✅ 压缩包创建成功: $ZIP_FILE"
    
    # 显示压缩包信息
    ZIP_SIZE=$(ls -lh "$ZIP_FILE" | awk '{print $5}')
    FILE_COUNT=$(unzip -l "$ZIP_FILE" | tail -1 | awk '{print $2}')
    
    echo "   文件大小: $ZIP_SIZE"
    echo "   包含文件数: $FILE_COUNT"
    
    # 验证压缩包
    if unzip -t "$ZIP_FILE" >/dev/null 2>&1; then
        echo "✅ 压缩包完整性验证通过"
    else
        echo "❌ 压缩包验证失败"
        exit 1
    fi
else
    echo "❌ 创建ZIP压缩包失败"
    exit 1
fi

# 清理临时目录
rm -rf "$PACKAGE_DIR"

# 返回原目录
cd - >/dev/null

echo ""
echo "=========================================="
echo "📦 报告打包完成！"
echo "=========================================="
echo "ZIP文件路径: $ZIP_FILE"
echo "文件大小: $ZIP_SIZE"
echo "准备通过邮件发送..."

# 返回ZIP文件路径供其他脚本使用
echo "$ZIP_FILE"