# ⚙️ 可配置定时任务使用指南

## 🎯 核心特性

### ✅ 集中配置
- **只需修改一个文件**: `schedule-config.sh`
- **自动同步**: 所有脚本自动使用最新配置
- **配置验证**: 自动检查时间格式和文件路径

### ✅ 快速修改
- **命令行修改**: `./change-schedule-time.sh 小时 分钟`
- **手动编辑**: 直接编辑配置文件
- **自动备份**: 修改前自动备份原配置

## 📁 配置文件位置

### 🔧 主要配置文件
```
📁 /Users/onion/Desktop/JmeterMac2/schedule-config.sh
```

**这是唯一需要修改的配置文件！**

## 🚀 修改方法

### 方法一：快速命令行修改（推荐）

```bash
# 修改为每天14:30执行
./change-schedule-time.sh 14 30

# 修改为每天09:15执行
./change-schedule-time.sh 9 15

# 修改为每天23:45执行
./change-schedule-time.sh 23 45
```

### 方法二：手动编辑配置文件

1. **打开配置文件**:
```bash
nano schedule-config.sh
# 或者
vim schedule-config.sh
# 或者用任何文本编辑器
```

2. **修改时间变量**:
```bash
# 找到这两行并修改
SCHEDULE_MINUTE="35"    # 修改分钟 (0-59)
SCHEDULE_HOUR="10"      # 修改小时 (0-23)
```

3. **应用配置**:
```bash
./schedule-config.sh update
```

## 📋 配置项说明

### ⏰ 时间配置
```bash
SCHEDULE_MINUTE="35"    # 分钟 (0-59)
SCHEDULE_HOUR="10"      # 小时 (0-23)
SCHEDULE_DAY="*"        # 日 (1-31, *表示每天)
SCHEDULE_MONTH="*"      # 月 (1-12, *表示每月)
SCHEDULE_WEEKDAY="*"    # 星期 (0-7, *表示每天)
```

### 📧 邮件配置
```bash
EMAIL_RECIPIENT="2335327949@qq.com"  # 收件人邮箱
```

### 📁 路径配置
```bash
WORKSPACE_DIR="/Users/onion/Desktop/JmeterMac2"
SCRIPT_PATH="$WORKSPACE_DIR/schedule-daily-test.sh"
LOG_FILE="$WORKSPACE_DIR/daily-test.log"
```

## 🔍 管理命令

### 查看当前配置
```bash
./schedule-config.sh show
```

### 测试配置
```bash
./schedule-config.sh test
```

### 更新定时任务
```bash
./schedule-config.sh update
```

### 查看当前定时任务
```bash
./schedule-config.sh current
```

### 查看系统状态
```bash
./manage-schedule.sh status
```

### 查看执行日志
```bash
./manage-schedule.sh log
```

## 📝 使用示例

### 示例1：修改为每天下午2点执行
```bash
./change-schedule-time.sh 14 0
```

### 示例2：修改为每天上午8点30分执行
```bash
./change-schedule-time.sh 8 30
```

### 示例3：修改为每天午夜12点执行
```bash
./change-schedule-time.sh 0 0
```

### 示例4：修改收件人邮箱
```bash
# 编辑配置文件
nano schedule-config.sh
# 修改 EMAIL_RECIPIENT 变量
# 然后运行
./schedule-config.sh update
```

## 🔄 自动同步

### 同步的文件
修改 `schedule-config.sh` 后，以下文件会自动使用新配置：

- ✅ `manage-schedule.sh` - 管理脚本
- ✅ `test-schedule.sh` - 测试脚本
- ✅ `schedule-daily-test.sh` - 执行脚本
- ✅ 所有相关文档

### 同步机制
- 所有脚本都通过 `source schedule-config.sh` 加载配置
- 修改配置文件后，所有脚本立即生效
- 无需手动修改其他文件

## 🛡️ 安全特性

### 自动备份
- 修改前自动备份原配置
- 备份文件：`schedule-config.sh.backup`
- 失败时自动恢复

### 配置验证
- 自动检查时间格式
- 验证文件路径存在
- 检查脚本权限

### 错误处理
- 格式错误时提示并退出
- 文件不存在时警告
- 权限不足时提示

## 🔧 故障排除

### 时间格式错误
```bash
❌ 分钟格式错误: 60 (应为0-59)
❌ 小时格式错误: 24 (应为0-23)
```

**解决方法**: 使用正确的时间格式

### 配置文件不存在
```bash
❌ 脚本文件不存在: /path/to/script
```

**解决方法**: 检查文件路径是否正确

### 权限不足
```bash
❌ 定时任务更新失败
```

**解决方法**: 检查crontab权限

### 恢复原配置
```bash
# 恢复备份的配置
cp schedule-config.sh.backup schedule-config.sh
./schedule-config.sh update
```

## 📊 当前配置状态

### ✅ 配置信息
- **执行时间**: 每天 10:35
- **收件人**: 2335327949@qq.com
- **工作目录**: /Users/onion/Desktop/JmeterMac2
- **配置文件**: schedule-config.sh

### ✅ 系统状态
- 定时任务已设置
- 脚本文件存在
- 邮件发送正常
- 日志记录完整

## 🎯 最佳实践

### 1. 使用命令行修改
```bash
# 推荐：使用快速修改脚本
./change-schedule-time.sh 14 30

# 不推荐：直接编辑配置文件
```

### 2. 修改前测试
```bash
# 修改前先测试配置
./schedule-config.sh test
```

### 3. 定期检查状态
```bash
# 定期检查系统状态
./manage-schedule.sh status
```

### 4. 查看执行日志
```bash
# 查看最近的执行记录
./manage-schedule.sh log
```

---

## 🎉 总结

**🎯 核心优势**:
- ✅ **只需修改一个文件**: `schedule-config.sh`
- ✅ **快速命令行修改**: `./change-schedule-time.sh 小时 分钟`
- ✅ **自动同步所有脚本**: 无需手动修改其他文件
- ✅ **配置验证和备份**: 安全可靠

**📁 配置文件位置**:
```
/Users/onion/Desktop/JmeterMac2/schedule-config.sh
```

**🚀 快速修改命令**:
```bash
./change-schedule-time.sh 小时 分钟
```

**现在您只需要修改一个地方就能更改定时任务时间了！** 🎊 