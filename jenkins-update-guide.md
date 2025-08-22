# 🔧 Jenkins任务修复指南

## 🚨 当前问题
Jenkins任务可以运行，但是`ant`命令找不到，导致构建失败。

## 🔍 问题分析
1. **环境变量未生效**：Jenkins中的PATH环境变量设置不正确
2. **ant命令路径**：ant安装在`/opt/homebrew/bin/ant`，但Jenkins找不到
3. **配置不完整**：之前的Jenkins配置更新不完整

## 🛠️ 解决方案

### 方法1：完全替换Jenkins脚本（推荐）

1. **打开Jenkins**：浏览器访问 `http://127.0.0.1:8080`
2. **进入任务**：点击 `Ford-Smart-Badge-Test`
3. **点击配置**：点击 `配置` 按钮
4. **删除旧脚本**：在"构建"部分的Shell脚本中，删除所有内容
5. **粘贴新脚本**：将以下完整脚本复制粘贴进去：

```bash
#!/bin/bash

# 设置环境变量 - 这是关键！
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin:$PATH"
export HOME="/Users/onion"
export SHELL="/bin/bash"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# 显示环境信息
echo "========================================="
echo "🚀 开始执行Ford Smart Badge自动化测试"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
echo "当前PATH: $PATH"
echo "ANT路径: $(which ant 2>/dev/null || echo 'ant命令未找到')"
echo "JAVA_HOME: $JAVA_HOME"
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

# 再次确认ant命令可用
echo "🔍 检查ant命令..." >> "$LOG_FILE"
echo "🔍 检查ant命令..."
which ant >> "$LOG_FILE" 2>&1
ant -version >> "$LOG_FILE" 2>&1

# 执行Ant构建
echo "🚀 开始执行Ant构建..." >> "$LOG_FILE"
echo "🚀 开始执行Ant构建..."
ant run >> "$LOG_FILE" 2>&1
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
echo "========================================="
```

6. **移除邮件插件**：在"构建后操作"部分，移除 `E-mail Notification`
7. **保存配置**：点击 `保存` 按钮

### 方法2：使用绝对路径（备选方案）

如果方法1不行，可以在脚本中使用ant的绝对路径：

```bash
# 替换 ant run 为：
/opt/homebrew/bin/ant run
```

## 🧪 测试验证

更新配置后：

1. **立即构建**：点击 `立即构建` 测试任务
2. **查看控制台输出**：确认显示：
   - `ANT路径: /opt/homebrew/bin/ant`
   - `🔍 检查ant命令...`
   - `🚀 开始执行Ant构建...`
3. **检查构建日志**：确认ant命令执行成功
4. **验证邮件发送**：检查是否收到测试报告

## 🔧 故障排除

### 如果仍然失败：

1. **检查Jenkins环境**：
   ```bash
   # 在Jenkins脚本中添加调试信息
   echo "当前用户: $(whoami)"
   echo "当前目录: $(pwd)"
   echo "所有环境变量:"
   env | sort
   ```

2. **手动测试ant**：
   ```bash
   # 在终端中测试
   cd /Users/onion/Desktop/JmeterMac2
   /opt/homebrew/bin/ant -version
   ```

3. **检查Jenkins权限**：
   ```bash
   # 确保Jenkins可以访问目录
   ls -la /Users/onion/Desktop/JmeterMac2
   ```

## 📚 相关文件

- **修复后的脚本**：`jenkins-fixed-script.sh`
- **Jenkins日志**：`jenkins-test.log`
- **Ant构建文件**：`build.xml`

## ✅ 预期结果

修复成功后，你应该看到：
- Jenkins任务正常执行
- ant命令找到并执行
- JMeter测试完整运行
- 测试报告生成
- Python邮件脚本成功发送邮件
- 构建状态显示为SUCCESS

---

**重要提示**：确保完全替换Jenkins中的脚本内容，不要只是追加或部分修改！
