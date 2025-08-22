#!/bin/bash

echo "========================================="
echo "🌐 部署JMeter报告到Web服务器"
echo "========================================="

# 配置
WEB_ROOT="/Users/onion/Desktop/JmeterMac2/web-reports"
REPORTS_DIR="/tmp"
WEB_URL="http://localhost:8000"

# 创建Web目录
echo "📁 创建Web目录..."
mkdir -p "$WEB_ROOT"
mkdir -p "$WEB_ROOT/reports"

# 查找最新的JMeter报告
echo "🔍 查找最新报告..."
LATEST_ZIP=$(ls -t "$REPORTS_DIR"/JMeter_Report_*.zip 2>/dev/null | head -1)

if [ -z "$LATEST_ZIP" ]; then
    echo "❌ 未找到JMeter报告文件"
    exit 1
fi

echo "📦 找到报告: $LATEST_ZIP"

# 解压报告到Web目录
echo "📂 解压报告..."
REPORT_NAME=$(basename "$LATEST_ZIP" .zip)
REPORT_DIR="$WEB_ROOT/reports/$REPORT_NAME"

# 清理旧报告
rm -rf "$REPORT_DIR"

# 解压新报告
unzip -q "$LATEST_ZIP" -d "$REPORT_DIR"

echo "✅ 报告解压完成: $REPORT_DIR"

# 创建索引页面
echo "📄 创建索引页面..."
cat > "$WEB_ROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JMeter测试报告中心</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; }
        .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-top: 30px; }
        .report-card { border: 1px solid #ddd; border-radius: 8px; padding: 20px; background: #fafafa; }
        .report-card h3 { margin-top: 0; color: #34495e; }
        .report-card p { color: #7f8c8d; margin: 10px 0; }
        .report-links { margin-top: 15px; }
        .report-links a { display: inline-block; margin: 5px 10px 5px 0; padding: 8px 16px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; }
        .report-links a:hover { background: #2980b9; }
        .timestamp { color: #95a5a6; font-size: 0.9em; }
        .status { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.8em; font-weight: bold; }
        .status.success { background: #d4edda; color: #155724; }
        .status.pending { background: #fff3cd; color: #856404; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 JMeter测试报告中心</h1>
        <p style="text-align: center; color: #7f8c8d;">Ford Smart Badge 自动化测试报告</p>
        
        <div class="report-grid">
EOF

# 遍历所有报告目录
for report_dir in "$WEB_ROOT"/reports/*; do
    if [ -d "$report_dir" ]; then
        report_name=$(basename "$report_dir")
        report_date=$(echo "$report_name" | sed 's/JMeter_Report_//' | sed 's/_/ /g')
        
        # 检查是否有HTML报告
        if [ -f "$report_dir/html_summary_reports"/*.html ] || [ -f "$report_dir/html_detail_reports"/*.html ]; then
            status="success"
            status_text="✅ 完成"
        else
            status="pending"
            status_text="⏳ 处理中"
        fi
        
        cat >> "$WEB_ROOT/index.html" << EOF
            <div class="report-card">
                <h3>📊 $report_name</h3>
                <p class="timestamp">📅 生成时间: $report_date</p>
                <p class="timestamp">🕐 最后更新: $(date '+%Y-%m-%d %H:%M:%S')</p>
                <p><span class="status $status">$status_text</span></p>
                <div class="report-links">
EOF
        
        # 添加汇总报告链接
        for html_file in "$report_dir"/html_summary_reports/*.html; do
            if [ -f "$html_file" ]; then
                relative_path="reports/$report_name/html_summary_reports/$(basename "$html_file")"
                cat >> "$WEB_ROOT/index.html" << EOF
                    <a href="$relative_path" target="_blank">📈 汇总报告</a>
EOF
                break
            fi
        done
        
        # 添加详细报告链接
        for html_file in "$report_dir"/html_detail_reports/*.html; do
            if [ -f "$html_file" ]; then
                relative_path="reports/$report_name/html_detail_reports/$(basename "$html_file")"
                cat >> "$WEB_ROOT/index.html" << EOF
                    <a href="$relative_path" target="_blank">📋 详细报告</a>
EOF
                break
            fi
        done
        
        # 添加ZIP下载链接
        if [ -f "$REPORTS_DIR/${report_name}.zip" ]; then
            cat >> "$WEB_ROOT/index.html" << EOF
                    <a href="reports/$report_name.zip" download>📦 下载报告</a>
EOF
        fi
        
        cat >> "$WEB_ROOT/index.html" << EOF
                </div>
            </div>
EOF
    fi
done

# 完成HTML页面
cat >> "$WEB_ROOT/index.html" << 'EOF'
        </div>
        
        <div style="margin-top: 40px; text-align: center; color: #7f8c8d;">
            <p>🔄 报告自动更新 | 📧 邮件通知: 2335327949@qq.com</p>
            <p>⏰ 定时执行: 早上9点, 下午2点, 晚上6点</p>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ 索引页面创建完成"

# 启动Python HTTP服务器
echo "🚀 启动Web服务器..."
echo "📱 访问地址: $WEB_URL"
echo "📁 报告目录: $WEB_ROOT"

# 检查是否已有服务器在运行
if pgrep -f "python3 -m http.server" > /dev/null; then
    echo "⚠️ 检测到已有HTTP服务器在运行"
    echo "🔍 请访问: $WEB_URL"
else
    echo "🌐 启动新的HTTP服务器..."
    cd "$WEB_ROOT"
    python3 -m http.server 8000 > /dev/null 2>&1 &
    SERVER_PID=$!
    echo "✅ 服务器已启动 (PID: $SERVER_PID)"
    echo "🌐 访问地址: $WEB_URL"
fi

# 生成可访问的URL列表
echo ""
echo "========================================="
echo "🔗 可访问的报告链接"
echo "========================================="

for report_dir in "$WEB_ROOT"/reports/*; do
    if [ -d "$report_dir" ]; then
        report_name=$(basename "$report_dir")
        
        # 汇总报告
        for html_file in "$report_dir"/html_summary_reports/*.html; do
            if [ -f "$html_file" ]; then
                echo "📈 汇总报告: $WEB_URL/reports/$report_name/html_summary_reports/$(basename "$html_file")"
                break
            fi
        done
        
        # 详细报告
        for html_file in "$report_dir"/html_detail_reports/*.html; do
            if [ -f "$html_file" ]; then
                echo "📋 详细报告: $WEB_URL/reports/$report_name/html_detail_reports/$(basename "$html_file")"
                break
            fi
        done
        
        echo ""
    fi
done

echo "========================================="
echo "🎯 使用方法"
echo "========================================="
echo "1. 将上述链接发送给需要查看报告的人员"
echo "2. 他们可以通过浏览器直接访问这些链接"
echo "3. 报告会自动更新，无需重新部署"
echo "4. 如需外网访问，请配置端口转发或使用ngrok等工具"
echo ""

echo "✅ 部署完成！"
