# 🕐 Ford Smart Badge 每日定时任务设置指南

## ✅ 定时任务已成功配置

### 📅 执行时间
- **每天 10:35** 自动执行JMeter测试
- **收件人**: 2335327949@qq.com
- **自动发送**: 包含ZIP附件的测试报告邮件

## 🚀 系统组件

### 1. 定时执行脚本
- **文件**: `schedule-daily-test.sh`
- **功能**: 执行完整的JMeter测试流程
- **日志**: 记录到 `daily-test.log`

### 2. 管理脚本
- **文件**: `manage-schedule.sh`
- **功能**: 管理定时任务的启动、停止、状态查看

## 📋 管理命令

### 查看状态
```bash
./manage-schedule.sh status
```

### 启动定时任务
```bash
./manage-schedule.sh start
```

### 停止定时任务
```bash
./manage-schedule.sh stop
```

### 测试执行
```bash
./manage-schedule.sh test
```

### 查看日志
```bash
./manage-schedule.sh log
```

### 完整安装
```bash
./manage-schedule.sh install
```

## 🔧 当前配置状态

### ✅ 已配置项目
- [x] 定时任务已设置: `35 10 * * * /Users/onion/Desktop/JmeterMac2/schedule-daily-test.sh`
- [x] 脚本文件存在且有执行权限
- [x] 工作目录: `/Users/onion/Desktop/JmeterMac2`
- [x] 收件人邮箱: `2335327949@qq.com`

### 📊 执行流程
1. **10:35** - 自动启动测试
2. **执行测试** - 运行4个API接口测试
3. **生成报告** - 创建HTML和ZIP报告
4. **发送邮件** - 自动发送到指定邮箱
5. **记录日志** - 保存执行记录

## 📧 邮件内容

### 成功时
- **主题**: `📊 Ford Smart Badge 每日测试报告 - YYYY-MM-DD`
- **附件**: 包含完整测试报告的ZIP文件
- **内容**: 测试统计和结果摘要

### 失败时
- **主题**: `❌ Ford Smart Badge 每日测试失败 - YYYY-MM-DD`
- **内容**: 错误信息和失败原因

## 📁 文件结构

```
JmeterMac2/
├── schedule-daily-test.sh      # 定时执行脚本
├── manage-schedule.sh          # 管理脚本
├── daily-test.log             # 执行日志
├── DAILY_SCHEDULE_SETUP.md    # 本说明文档
├── build.xml                  # Ant构建文件
├── jmeter-script/
│   └── Ford-Smart-API-Test.jmx # JMeter测试脚本
└── jmeter-results/            # 测试结果目录
```

## 🔍 故障排除

### 检查定时任务状态
```bash
crontab -l
```

### 查看系统日志
```bash
./manage-schedule.sh log
```

### 手动测试
```bash
./manage-schedule.sh test
```

### 重新安装
```bash
./manage-schedule.sh install
```

## ⚠️ 注意事项

1. **系统要求**: macOS系统需要保持运行状态
2. **网络连接**: 需要稳定的网络连接执行API测试
3. **邮件服务**: 依赖系统邮件服务发送通知
4. **磁盘空间**: 定期清理旧的测试报告和日志文件

## 🎯 测试内容

每日定时任务将执行以下4个API接口测试：

1. **登录接口** - 获取access_token
2. **客户列表接口** - 验证Token有效性
3. **质检规则列表接口** - 获取规则列表
4. **下架质检规则接口** - 使用完整参数下架规则

## 📈 监控建议

- 定期检查 `daily-test.log` 文件
- 监控邮件接收情况
- 关注测试成功率
- 及时处理失败情况

---

**🎉 定时任务配置完成！系统将在每天上午10:35自动执行测试并发送报告到 2335327949@qq.com** 