#!/bin/bash

# ==========================================
# Ford Smart Badge 立即执行测试脚本
# ==========================================
# 功能: 立即执行JMeter测试并发送邮件
# 收件人: 2335327949@qq.com
# 执行方式: 手动执行，立即开始
# ==========================================

# 设置工作目录
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

# 记录日志
LOG_FILE="$WORKSPACE_DIR/immediate-test.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🚀 开始立即执行测试 - $TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"

# 检查工作目录
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ 错误: 工作目录不存在: $WORKSPACE_DIR" >> "$LOG_FILE"
    echo "❌ 错误: 工作目录不存在: $WORKSPACE_DIR"
    exit 1
fi

echo "📁 工作目录: $WORKSPACE_DIR" >> "$LOG_FILE"
echo "📁 工作目录: $WORKSPACE_DIR"

# 检查必要文件
if [ ! -f "$WORKSPACE_DIR/build.xml" ]; then
    echo "❌ 错误: build.xml文件不存在" >> "$LOG_FILE"
    echo "❌ 错误: build.xml文件不存在"
    exit 1
fi

if [ ! -f "$WORKSPACE_DIR/jmeter-script/Ford-Smart-API-Test.jmx" ]; then
    echo "❌ 错误: JMeter测试脚本不存在" >> "$LOG_FILE"
    echo "❌ 错误: JMeter测试脚本不存在"
    exit 1
fi

echo "✅ 必要文件检查通过" >> "$LOG_FILE"
echo "✅ 必要文件检查通过"

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
echo "🚀 开始执行Ant构建..."
ant run >> "$LOG_FILE" 2>&1

# 检查执行结果
if [ $? -eq 0 ]; then
    echo "✅ Ant构建执行成功" >> "$LOG_FILE"
    echo "✅ Ant构建执行成功"
    
    # 查找最新的ZIP报告文件
    LATEST_ZIP=$(ls -t /tmp/JMeter_Report_*.zip 2>/dev/null | head -1)
    
    if [ -n "$LATEST_ZIP" ] && [ -f "$LATEST_ZIP" ]; then
        echo "📦 找到最新报告: $LATEST_ZIP" >> "$LOG_FILE"
        echo "📦 找到最新报告: $LATEST_ZIP"
        
        # 发送邮件通知
        echo "📧 发送邮件通知..." >> "$LOG_FILE"
        echo "📧 发送邮件通知..."
        
        # 优先使用Python邮件发送脚本
        if [ -f "$WORKSPACE_DIR/send-email-python.py" ]; then
            echo "🐍 使用Python脚本发送邮件..." >> "$LOG_FILE"
            echo "🐍 使用Python脚本发送邮件..."
            
            cd "$WORKSPACE_DIR"
            python3 send-email-python.py
            MAIL_RESULT=$?
            
            if [ $MAIL_RESULT -eq 0 ]; then
                echo "✅ 邮件发送成功 (使用Python脚本)" >> "$LOG_FILE"
                echo "✅ 邮件发送成功 (使用Python脚本)"
            else
                echo "❌ Python邮件发送失败，尝试备用方案..." >> "$LOG_FILE"
                echo "❌ Python邮件发送失败，尝试备用方案..."
                
                # 备用方案：使用mutt
                if command -v mutt &> /dev/null; then
                    echo "📊 Ford Smart Badge 立即测试报告 - $(date '+%Y-%m-%d %H:%M:%S')" | mutt -s "📊 Ford Smart Badge 立即测试报告 - $(date '+%Y-%m-%d %H:%M:%S')" -a "$LATEST_ZIP" -- 2335327949@qq.com
                    MAIL_RESULT=$?
                    if [ $MAIL_RESULT -eq 0 ]; then
                        echo "✅ 邮件发送成功 (使用mutt备用)" >> "$LOG_FILE"
                        echo "✅ 邮件发送成功 (使用mutt备用)"
                    else
                        echo "❌ mutt邮件发送也失败" >> "$LOG_FILE"
                        echo "❌ mutt邮件发送也失败"
                    fi
                else
                    echo "❌ 所有邮件发送方式都失败" >> "$LOG_FILE"
                    echo "❌ 所有邮件发送方式都失败"
                fi
            fi
        else
            echo "⚠️ Python邮件脚本不存在，使用mutt..." >> "$LOG_FILE"
            echo "⚠️ Python邮件脚本不存在，使用mutt..."
            
            # 使用mutt作为备用
            if command -v mutt &> /dev/null; then
                echo "📊 Ford Smart Badge 立即测试报告 - $(date '+%Y-%m-%d %H:%M:%S')" | mutt -s "📊 Ford Smart Badge 立即测试报告 - $(date '+%Y-%m-%d %H:%M:%S')" -a "$LATEST_ZIP" -- 2335327949@qq.com
                MAIL_RESULT=$?
                if [ $MAIL_RESULT -eq 0 ]; then
                    echo "✅ 邮件发送成功 (使用mutt)" >> "$LOG_FILE"
                    echo "✅ 邮件发送成功 (使用mutt)"
                else
                    echo "❌ 邮件发送失败 (mutt退出码: $MAIL_RESULT)" >> "$LOG_FILE"
                    echo "❌ 邮件发送失败 (mutt退出码: $MAIL_RESULT)"
                fi
            else
                echo "❌ mutt不可用，邮件发送失败" >> "$LOG_FILE"
                echo "❌ mutt不可用，邮件发送失败"
            fi
        fi
    else
        echo "⚠️ 未找到ZIP报告文件" >> "$LOG_FILE"
        echo "⚠️ 未找到ZIP报告文件"
    fi
else
    echo "❌ Ant构建执行失败" >> "$LOG_FILE"
    echo "❌ Ant构建执行失败"
    # 发送失败通知邮件
    echo "❌ Ford Smart Badge 立即测试失败 - $(date '+%Y-%m-%d %H:%M:%S')" | mail -s "❌ Ford Smart Badge 立即测试失败 - $(date '+%Y-%m-%d %H:%M:%S')" 2335327949@qq.com
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 立即测试完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 清理旧日志（保留最近30天）
find "$WORKSPACE_DIR" -name "immediate-test.log" -mtime +30 -delete 2>/dev/null

echo "========================================="
echo "🎉 立即测试脚本执行完成！"
echo "📧 测试报告已发送到: 2335327949@qq.com"
echo "📄 详细日志: $LOG_FILE"
echo "========================================="
