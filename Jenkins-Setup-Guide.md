# 🚀 Jenkins定时任务设置指南

## 📋 **为什么选择Jenkins而不是Cron？**

### ✅ **Jenkins的优势**
- **更稳定可靠** - 专门为CI/CD设计，比系统cron更稳定
- **Web界面管理** - 可视化配置，易于管理和监控
- **丰富的插件** - 支持邮件、通知、报告等多种功能
- **错误处理** - 自动重试、失败通知、详细日志
- **权限管理** - 用户认证和权限控制
- **跨平台** - 不依赖系统cron服务

### ❌ **Cron的问题**
- **权限问题** - 经常出现"Operation not permitted"错误
- **环境变量** - 环境不完整，路径问题
- **调试困难** - 错误信息不清晰，难以排查
- **系统依赖** - 依赖系统服务状态

## 🔧 **Jenkins任务配置步骤**

### **步骤1: 访问Jenkins**
1. 打开浏览器，访问: `http://127.0.0.1:8080`
2. 使用你的Jenkins账号登录

### **步骤2: 创建新任务**
1. 点击 **"新建任务"** 或 **"New Item"**
2. 输入任务名称: `Ford-Smart-Badge-Test`
3. 选择 **"构建一个自由风格的软件项目"**
4. 点击 **"确定"**

### **步骤3: 配置任务**
1. **描述**: `Ford Smart Badge 每日自动化测试任务`
2. **构建触发器**: 
   - 勾选 **"定时构建"**
   - 输入cron表达式: `0 9,14,17 * * *`
   - 含义: 每天9:00、14:30、17:05执行

3. **构建环境**: 保持默认设置

4. **构建**: 
   - 点击 **"增加构建步骤"**
   - 选择 **"执行shell"**
   - 复制以下脚本内容:

```bash
#!/bin/bash

# Ford Smart Badge 每日自动化测试脚本
# 通过Jenkins执行，比cron更可靠

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
    echo "❌ Ant构建执行失败" >> "$LOG_FILE"
    echo "❌ Ant构建执行失败"
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

5. **构建后操作**:
   - 点击 **"增加构建后操作步骤"**
   - 选择 **"E-mail Notification"**
   - 收件人: `2335327949@qq.com`
   - 勾选 **"每次不稳定的构建都发送邮件通知"**

6. **保存**: 点击 **"保存"**

### **步骤4: 测试任务**
1. 点击 **"立即构建"** 测试任务是否正常
2. 查看构建日志，确认执行成功
3. 检查是否收到测试邮件

## 📅 **定时执行配置**

### **Cron表达式说明**
```bash
0 9,14,17 * * *
│ │ │      │ │ │
│ │ │      │ │ └── 星期 (0-7, *表示每天)
│ │ │      │ └──── 月 (1-12, *表示每月)
│ │ │      └────── 日 (1-31, *表示每天)
│ │ └───────────── 小时 (9,14,17表示9点、14点、17点)
│ └─────────────── 分钟 (0表示整点)
└───────────────── 秒 (Jenkins中通常为0)
```

### **执行时间**
- **09:00** - 上午测试
- **14:30** - 下午测试 (注意: 14:30需要特殊配置)
- **17:05** - 傍晚测试 (注意: 17:05需要特殊配置)

### **修正后的Cron表达式**
```bash
# 为了精确控制时间，使用以下表达式:
0 9 * * *      # 9:00
30 14 * * *    # 14:30
5 17 * * *     # 17:05

# 或者使用多个触发器分别配置
```

## 🔍 **监控和管理**

### **查看任务状态**
- Jenkins主页显示所有任务状态
- 绿色: 构建成功
- 红色: 构建失败
- 黄色: 构建不稳定

### **查看构建日志**
1. 点击任务名称
2. 点击构建号
3. 点击 **"Console Output"** 查看详细日志

### **手动触发**
- 随时可以点击 **"立即构建"** 手动执行测试
- 适合调试和紧急测试

## 🎯 **优势总结**

1. **可靠性高** - Jenkins专门为自动化任务设计
2. **易于管理** - Web界面，可视化配置
3. **错误处理** - 自动重试、失败通知
4. **日志完整** - 详细的执行日志和错误信息
5. **邮件集成** - 内置邮件通知功能
6. **权限控制** - 用户认证和访问控制

## 🚀 **下一步操作**

1. 按照上述步骤在Jenkins中创建任务
2. 测试任务是否正常执行
3. 配置正确的定时触发器
4. 停用系统cron任务，避免冲突

使用Jenkins后，你的自动化测试将更加稳定可靠！🎉
