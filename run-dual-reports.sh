#!/bin/bash

# ==========================================
# Ford Smart Badge 双报告测试脚本
# ==========================================
# 功能: 执行JMeter测试，生成HTML和Allure双报告
# 使用方法: ./run-dual-reports.sh
# ==========================================

WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

LOG_FILE="$WORKSPACE_DIR/dual-reports-test.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🚀 开始双报告生成测试 - $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

echo "========================================="
echo "🚀 Ford Smart Badge - 双报告生成测试"
echo "========================================="
echo "📁 工作目录: $WORKSPACE_DIR"
echo "📅 开始时间: $TIMESTAMP"
echo "📊 报告类型: JMeter HTML + Allure"
echo "========================================="

# 执行完整的双报告生成流程
echo "🔧 执行双报告生成流程..."
echo "🔧 执行双报告生成流程..." >> "$LOG_FILE"

ant run >> "$LOG_FILE" 2>&1
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ 双报告生成成功"
    echo "✅ 双报告生成成功" >> "$LOG_FILE"
    
    # 查找生成的报告
    echo ""
    echo "📊 查找生成的报告..."
    
    # JMeter HTML报告
    LATEST_HTML_REPORT=$(find "$WORKSPACE_DIR/jmeter-results/html" -name "*.html" -type f -exec ls -t {} + 2>/dev/null | head -1)
    LATEST_DETAIL_REPORT=$(find "$WORKSPACE_DIR/jmeter-results/detail" -name "*.html" -type f -exec ls -t {} + 2>/dev/null | head -1)
    
    # Allure报告
    LATEST_ALLURE_REPORT=$(find "$WORKSPACE_DIR/allure-reports" -name "JMeter_Allure_Report_*" -type d -exec ls -td {} + 2>/dev/null | head -1)
    
    echo ""
    echo "📋 报告生成结果:"
    echo "================================"
    
    # JMeter报告
    if [ -n "$LATEST_HTML_REPORT" ] && [ -f "$LATEST_HTML_REPORT" ]; then
        echo "✅ JMeter汇总报告: $LATEST_HTML_REPORT"
        echo "✅ JMeter汇总报告: $LATEST_HTML_REPORT" >> "$LOG_FILE"
        echo "🌐 访问地址: file://$LATEST_HTML_REPORT"
    else
        echo "❌ JMeter汇总报告生成失败"
        echo "❌ JMeter汇总报告生成失败" >> "$LOG_FILE"
    fi
    
    if [ -n "$LATEST_DETAIL_REPORT" ] && [ -f "$LATEST_DETAIL_REPORT" ]; then
        echo "✅ JMeter详细报告: $LATEST_DETAIL_REPORT"
        echo "✅ JMeter详细报告: $LATEST_DETAIL_REPORT" >> "$LOG_FILE"
        echo "🌐 访问地址: file://$LATEST_DETAIL_REPORT"
    else
        echo "❌ JMeter详细报告生成失败"
        echo "❌ JMeter详细报告生成失败" >> "$LOG_FILE"
    fi
    
    # Allure报告
    if [ -n "$LATEST_ALLURE_REPORT" ] && [ -d "$LATEST_ALLURE_REPORT" ]; then
        echo "✅ Allure报告: $LATEST_ALLURE_REPORT/index.html"
        echo "✅ Allure报告: $LATEST_ALLURE_REPORT/index.html" >> "$LOG_FILE"
        echo "🌐 访问地址: file://$LATEST_ALLURE_REPORT/index.html"
        
        # 检查Allure压缩包
        ALLURE_ZIP="$LATEST_ALLURE_REPORT.zip"
        if [ -f "$ALLURE_ZIP" ]; then
            echo "📦 Allure压缩包: $ALLURE_ZIP"
            echo "📦 Allure压缩包: $ALLURE_ZIP" >> "$LOG_FILE"
        fi
    else
        echo "❌ Allure报告生成失败"
        echo "❌ Allure报告生成失败" >> "$LOG_FILE"
    fi
    
    # 检查邮件发送的ZIP包
    LATEST_MAIL_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
    if [ -n "$LATEST_MAIL_ZIP" ] && [ -f "$LATEST_MAIL_ZIP" ]; then
        echo "📧 邮件附件包: $LATEST_MAIL_ZIP"
        echo "📧 邮件附件包: $LATEST_MAIL_ZIP" >> "$LOG_FILE"
    fi
    
    echo "================================"
    echo ""
    
    # 自动打开报告（可选）
    echo "🚀 打开报告..."
    if [ -n "$LATEST_HTML_REPORT" ] && command -v open >/dev/null 2>&1; then
        echo "📊 正在打开JMeter汇总报告..."
        open "$LATEST_HTML_REPORT"
    fi
    
    if [ -n "$LATEST_ALLURE_REPORT" ] && command -v open >/dev/null 2>&1; then
        echo "📊 正在打开Allure报告..."
        open "$LATEST_ALLURE_REPORT/index.html"
    fi
    
else
    echo "❌ 双报告生成失败"
    echo "❌ 双报告生成失败" >> "$LOG_FILE"
    echo "📄 查看详细日志: $LOG_FILE"
    exit 1
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 双报告生成完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

echo "========================================="
echo "🎉 双报告生成完成！"
echo "⏰ 完成时间: $END_TIMESTAMP"
echo "📄 详细日志: $LOG_FILE"
echo ""
echo "📋 快速访问命令:"
if [ -n "$LATEST_HTML_REPORT" ]; then
    echo "   📊 JMeter汇总: open $LATEST_HTML_REPORT"
fi
if [ -n "$LATEST_DETAIL_REPORT" ]; then
    echo "   📊 JMeter详细: open $LATEST_DETAIL_REPORT"
fi
if [ -n "$LATEST_ALLURE_REPORT" ]; then
    echo "   📊 Allure报告: open $LATEST_ALLURE_REPORT/index.html"
fi
echo "========================================="