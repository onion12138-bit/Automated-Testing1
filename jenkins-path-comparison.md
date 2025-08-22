# 🔍 Jenkins脚本路径方法对比分析

## 📊 方法对比总览

| 特性 | 相对路径方法 | 绝对路径方法 |
|------|-------------|-------------|
| **可靠性** | ❌ 低（依赖环境变量） | ✅ 高（直接调用文件） |
| **兼容性** | ❌ 受Jenkins环境影响 | ✅ 不受环境变量影响 |
| **调试难度** | ❌ 高（环境问题难排查） | ✅ 低（路径明确） |
| **维护性** | ❌ 低（需要配置环境） | ✅ 高（路径固定） |

## 🔧 方法1：相对路径（之前尝试的方法）

### 脚本内容
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

### 关键特点
- **环境变量设置**：`export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin:$PATH"`
- **相对命令调用**：`ant run`
- **环境检查**：`which ant` 和 `ant -version`

### 失败原因分析
1. **环境变量未生效**：Jenkins可能没有正确加载export的环境变量
2. **PATH设置失败**：Jenkins的shell环境与用户shell环境不同
3. **权限问题**：Jenkins可能没有权限修改环境变量

### 错误日志示例
```
/var/folders/s7/cwsk3y_552dbp6gfk95h2qtc0000gn/T/jenkins6195372101444105746.sh: line 53: ant: command not found
```

---

## 🔧 方法2：绝对路径（推荐解决方案）

### 脚本内容
```bash
#!/bin/bash

echo "========================================="
echo "🚀 开始执行Ford Smart Badge自动化测试"
echo "========================================="
echo "执行时间: $(date)"
echo "Jenkins工作目录: $WORKSPACE"
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
echo "========================================="
```

### 关键特点
- **绝对路径定义**：`ANT_PATH="/opt/homebrew/bin/ant"`
- **文件存在性检查**：`if [ ! -f "$ANT_PATH" ]`
- **绝对路径调用**：`"$ANT_PATH" run`

### 成功原因分析
1. **路径明确**：直接指定ant可执行文件的完整路径
2. **不依赖环境**：绕过PATH环境变量问题
3. **文件验证**：先检查文件是否存在，再执行

### 预期成功日志
```
🔍 使用ant绝对路径: /opt/homebrew/bin/ant
📋 ant版本信息: Apache Ant(TM) version 1.10.14
🚀 开始执行Ant构建...
✅ Ant构建执行成功
```

---

## 📊 详细对比分析

### 1. **环境变量处理**
| 相对路径方法 | 绝对路径方法 |
|-------------|-------------|
| ```bash
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin:$PATH"
export HOME="/Users/onion"
export SHELL="/bin/bash"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
``` | ```bash
# 无需设置环境变量
ANT_PATH="/opt/homebrew/bin/ant"
``` |

### 2. **命令调用方式**
| 相对路径方法 | 绝对路径方法 |
|-------------|-------------|
| ```bash
ant run
``` | ```bash
"$ANT_PATH" run
``` |

### 3. **错误处理**
| 相对路径方法 | 绝对路径方法 |
|-------------|-------------|
| ```bash
which ant >> "$LOG_FILE" 2>&1
ant -version >> "$LOG_FILE" 2>&1
``` | ```bash
if [ ! -f "$ANT_PATH" ]; then
    echo "❌ 错误: ant文件不存在: $ANT_PATH"
    exit 1
fi
"$ANT_PATH" -version
``` |

### 4. **调试信息**
| 相对路径方法 | 绝对路径方法 |
|-------------|-------------|
| ```bash
echo "当前PATH: $PATH"
echo "ANT路径: $(which ant 2>/dev/null || echo 'ant命令未找到')"
``` | ```bash
echo "🔍 使用ant绝对路径: $ANT_PATH"
echo "📋 ant版本信息:"
"$ANT_PATH" -version
``` |

---

## 🎯 推荐使用绝对路径方法的原因

### ✅ 优势
1. **可靠性高**：不依赖Jenkins环境变量设置
2. **调试简单**：路径明确，问题容易定位
3. **兼容性好**：适用于各种Jenkins配置环境
4. **维护简单**：路径固定，无需配置环境

### ❌ 相对路径方法的问题
1. **环境依赖**：需要Jenkins正确加载环境变量
2. **调试困难**：环境问题难以排查
3. **兼容性差**：不同Jenkins配置可能表现不同
4. **维护复杂**：需要确保环境变量正确设置

---

## 🚀 立即行动建议

**推荐使用绝对路径方法**，因为：
- 更可靠，不依赖环境变量
- 更容易调试和维护
- 在当前Jenkins环境中已经验证失败

请按照之前的指南，在Jenkins中使用绝对路径版本的脚本！
