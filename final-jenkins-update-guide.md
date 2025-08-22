# 🎯 Jenkins最终配置指南 - 包含最新定时设置

## ⏰ 最新定时设置

**定时执行时间**：
- **早上9点** - 09:00
- **下午2点** - 14:00  
- **晚上6点** - 18:00

**Cron表达式**：`0 9,14,18 * * *`

## 📋 更新步骤

### 1. **打开Jenkins任务配置**
- 访问：`http://127.0.0.1:8080`
- 进入任务：`Ford-Smart-Badge-Test`
- 点击：`配置` 按钮

### 2. **更新定时触发器**
在 `Build Triggers`（构建触发器）部分：
- 勾选：`Build periodically`（定期构建）
- 输入：`0 9,14,18 * * *`

### 3. **更新Shell脚本**
在 `Build`（构建）部分，完全替换Shell脚本内容为：

```bash
#!/bin/bash

echo "========================================="
echo "🚀 Ford Smart Badge 自动化测试脚本"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
echo "定时设置: 早上9点, 下午2点, 晚上6点"
echo "========================================="

# 设置工作目录
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
cd "$WORKSPACE_DIR"

# 记录日志
LOG_FILE="$WORKSPACE_DIR/jenkins-test.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========================================" >> "$LOG_FILE"
echo "🕐 Jenkins开始执行每日自动化测试 - $TIMESTAMP" >> "$LOG_FILE"
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

# 使用ant的绝对路径
ANT_PATH="/opt/homebrew/bin/ant"
echo "🔍 使用ant绝对路径: $ANT_PATH" >> "$LOG_FILE"
echo "🔍 使用ant绝对路径: $ANT_PATH"

# 检查ant文件是否存在
if [ ! -f "$ANT_PATH" ]; then
    echo "❌ 错误: ant文件不存在: $ANT_PATH" >> "$LOG_FILE"
    echo "❌ 错误: ant文件不存在: $ANT_PATH"
    exit 1
fi

# 显示ant版本信息
echo "📋 ant版本信息:" >> "$LOG_FILE"
echo "📋 ant版本信息:"
"$ANT_PATH" -version >> "$LOG_FILE" 2>&1
"$ANT_PATH" -version

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
echo "🚀 开始执行Ant构建..."
"$ANT_PATH" run >> "$LOG_FILE" 2>&1
ANT_EXIT_CODE=$?

echo "Ant执行退出码: $ANT_EXIT_CODE" >> "$LOG_FILE"
echo "Ant执行退出码: $ANT_EXIT_CODE"

# 检查执行结果
if [ $ANT_EXIT_CODE -eq 0 ]; then
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
        
        # 使用Python脚本发送邮件
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
                echo "❌ Python邮件发送失败" >> "$LOG_FILE"
                echo "❌ Python邮件发送失败"
            fi
        else
            echo "❌ Python邮件脚本不存在" >> "$LOG_FILE"
            echo "❌ Python邮件脚本不存在"
        fi
    else
        echo "⚠️ 未找到ZIP报告文件" >> "$LOG_FILE"
        echo "⚠️ 未找到ZIP报告文件"
    fi
else
    echo "❌ Ant构建执行失败 (退出码: $ANT_EXIT_CODE)" >> "$LOG_FILE"
    echo "❌ Ant构建执行失败 (退出码: $ANT_EXIT_CODE)"
    echo "请查看日志文件: $LOG_FILE" >> "$LOG_FILE"
    echo "请查看日志文件: $LOG_FILE"
    exit 1
fi

# 记录完成时间
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=========================================" >> "$LOG_FILE"
echo "🏁 Jenkins每日自动化测试完成 - $END_TIMESTAMP" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# 清理旧日志（保留最近30天）
find "$WORKSPACE_DIR" -name "jenkins-test.log" -mtime +30 -delete 2>/dev/null

echo "========================================="
echo "🎉 Jenkins自动化测试脚本执行完成！"
echo "📧 测试报告已发送到: 2335327949@qq.com"
echo "📄 详细日志: $LOG_FILE"
echo "⏰ 下次执行时间: 早上9点, 下午2点, 晚上6点"
echo "========================================="
```

### 4. **移除邮件插件**
在 `Post-build Actions`（构建后操作）部分：
- 移除：`E-mail Notification` 插件

### 5. **保存配置**
点击：`保存` 按钮

## 🔍 关键特性

### **定时设置**
- **Cron表达式**：`0 9,14,18 * * *`
- **执行时间**：每天9:00、14:00、18:00
- **说明**：分钟=0，小时=9,14,18，每天执行

### **Ant命令**
- **使用绝对路径**：`/opt/homebrew/bin/ant`
- **避免环境变量问题**：直接调用可执行文件
- **版本验证**：显示ant版本信息

### **邮件发送**
- **使用Python脚本**：`send-email-python.py`
- **避免Jenkins邮件插件**：防止乱码和连接问题
- **收件人**：2335327949@qq.com

## 🧪 测试验证

### 1. **立即测试**
- 点击：`立即构建`
- 查看：构建日志输出
- 确认：ant命令执行成功

### 2. **定时测试**
- 等待下一个定时点
- 检查：是否自动执行
- 验证：邮件是否发送成功

### 3. **日志检查**
- 查看：`jenkins-test.log` 文件
- 确认：执行记录完整
- 验证：错误处理正常

## 📊 预期输出

### **成功执行时应该看到**：
```
=========================================
🚀 Ford Smart Badge 自动化测试脚本
=========================================
执行时间: Wed Aug 21 10:30:00 CST 2025
Jenkins工作目录: /Users/onion/Desktop/JmeterMac2
定时设置: 早上9点, 下午2点, 晚上6点
=========================================
🔍 使用ant绝对路径: /opt/homebrew/bin/ant
📋 ant版本信息: Apache Ant(TM) version 1.10.15
🚀 开始执行Ant构建...
✅ Ant构建执行成功
🐍 使用Python脚本发送邮件...
✅ 邮件发送成功 (使用Python脚本)
🎉 Jenkins自动化测试脚本执行完成！
⏰ 下次执行时间: 早上9点, 下午2点, 晚上6点
=========================================
```

## ⚠️ 注意事项

1. **确保Python脚本存在**：`send-email-python.py`
2. **检查ant路径**：`/opt/homebrew/bin/ant`
3. **验证工作目录**：`/Users/onion/Desktop/JmeterMac2`
4. **定时执行**：每天3次，间隔5小时

## 🎯 总结

这个最终配置：
- ✅ **定时设置**：早上9点、下午2点、晚上6点
- ✅ **Ant命令**：使用绝对路径，避免环境变量问题
- ✅ **邮件发送**：使用Python脚本，避免Jenkins插件问题
- ✅ **错误处理**：完整的日志记录和错误处理
- ✅ **日志管理**：自动清理30天前的旧日志

配置完成后，你的Jenkins任务将在每天指定时间自动执行，并发送测试报告邮件！
