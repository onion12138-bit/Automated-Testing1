# Ford Smart Badge JMeter 自动化测试系统

## 项目简介
Ford Smart Badge API 自动化测试项目，支持生成 JMeter HTML 报告和 Allure 报告。

## 核心功能
- ✅ JMeter 自动化测试执行
- ✅ JMeter HTML 报告生成（汇总 + 详细）
- ✅ Allure 报告生成
- ✅ 报告自动打包和邮件发送
- ✅ Git 版本管理集成

## 目录结构
```
JmeterMac2/
├── jmeter-script/           # JMeter 测试脚本
│   └── Ford-Smart-API-Test.jmx
├── jmeter-results/          # 测试结果
│   ├── jtl/                # 原始结果文件
│   ├── html/               # JMeter HTML 汇总报告
│   └── detail/             # JMeter HTML 详细报告
├── allure-results/          # Allure 原始结果
├── allure-reports/          # Allure HTML 报告
├── web-reports/             # 历史报告存档
├── apache-jmeter-5.4.3/     # JMeter 安装目录
├── build.xml                # Ant 构建配置
└── 核心脚本...
```

## 核心脚本

### 1. 双报告生成（推荐）
```bash
./run-dual-reports.sh
```
- 执行 JMeter 测试
- 生成 JMeter HTML 报告（汇总+详细）
- 生成 Allure 报告
- 自动打包并发送邮件

### 2. 仅 Allure 报告
```bash
./start-test-with-allure.sh
```
- 执行 JMeter 测试
- 仅生成 Allure 报告

### 3. 单独生成 Allure 报告
```bash
./generate-allure-report.sh [jtl_file_path]
```
- 从现有 JTL 文件生成 Allure 报告

### 4. 立即执行测试
```bash
./start-test-now.sh
```
- 执行测试并发送传统 JMeter 报告

## Ant 任务

### 完整双报告流程
```bash
ant run
```
依赖：git-update → clean → test → report → generate-allure-report → package-reports → send-email-with-attachment

### 仅 Allure 流程
```bash
ant run-with-allure
```
依赖：git-update → clean → test → generate-allure-report → package-allure-reports → send-allure-email

### 单独任务
```bash
ant test                    # 仅执行测试
ant report                  # 仅生成 JMeter HTML 报告
ant generate-allure-report  # 仅生成 Allure 报告
```

## 邮件配置
收件人：2335327949@qq.com
发送内容：
- 测试结果摘要
- 报告附件（ZIP格式）
- Allure 报告 或 JMeter 报告

## 报告访问

### JMeter 报告
- 汇总报告：`jmeter-results/html/JMeter-Summary-Report-[timestamp].html`
- 详细报告：`jmeter-results/detail/JMeter-Detail-Report-[timestamp].html`

### Allure 报告
- 报告目录：`allure-reports/JMeter_Allure_Report_[timestamp]/index.html`
- 压缩包：`allure-reports/JMeter_Allure_Report_[timestamp].zip`

## 环境要求
- Java 8+（JMeter 运行）
- Ant（构建工具）
- Python 3（邮件发送和数据转换）
- Allure 2.34.0（报告生成）
  - 路径：`/Users/onion/Desktop/automation/allure-2.34.0`

## 测试执行流程
1. Git 代码更新（如果有远程仓库）
2. 清理旧报告
3. 执行 JMeter 测试
4. 生成报告（JMeter HTML + Allure）
5. 打包报告
6. 发送邮件通知

## 常用操作

### 快速测试
```bash
# 双报告生成
./run-dual-reports.sh

# 查看最新 Allure 报告
find allure-reports -name "index.html" -exec ls -t {} + | head -1 | xargs open
```

### 手动报告生成
```bash
# 先执行测试
ant test

# 生成传统报告
ant report

# 生成 Allure 报告
ant generate-allure-report
```

## 日志文件
- `dual-reports-test.log` - 双报告生成日志
- `test-with-allure.log` - Allure 测试日志  
- `immediate-test.log` - 立即测试日志

## 注意事项
1. 确保 Allure 已正确安装在指定路径
2. 首次运行前检查邮件配置
3. 报告文件会自动清理，只保留最新几个版本
4. 支持本地和远程 Git 仓库