# Jenkins + Git 集成配置指南

## 前提条件
1. Jenkins 已安装并运行
2. Git 已安装
3. Ant 已安装
4. JMeter 已配置

## Jenkins 插件要求
确保安装以下Jenkins插件：
- Git Plugin
- Pipeline Plugin
- HTML Publisher Plugin
- Ant Plugin

## 配置步骤

### 方法1：Pipeline Job（推荐）

1. **创建新的Pipeline Job**
   - 在Jenkins中点击 "New Item"
   - 选择 "Pipeline" 
   - 输入Job名称（如：JMeter-Automation）

2. **配置Pipeline**
   - 在Pipeline配置中选择 "Pipeline script from SCM"
   - SCM选择 "Git"
   - Repository URL: 你的Git仓库地址
   - Branch: */master（或你的主分支）
   - Script Path: Jenkinsfile

3. **保存并运行**
   - 点击Save保存配置
   - 点击 "Build Now" 执行测试

### 方法2：Freestyle Job

1. **创建Freestyle Project**
   - 在Jenkins中点击 "New Item"
   - 选择 "Freestyle project"
   - 输入Job名称

2. **源码管理配置**
   - 选择 "Git"
   - Repository URL: 你的Git仓库地址
   - Branch Specifier: */master

3. **构建配置**
   - 添加构建步骤 "Invoke Ant"
   - Ant Target: run
   - Build File: build.xml

4. **构建后操作**
   - 添加 "Publish HTML reports"
   - HTML directory to archive: jmeter-results/html
   - Index page: *.html
   - Report title: JMeter Test Report

## Git 仓库设置

### 本地测试（当前设置）
当前项目已配置为本地Git仓库，适合本地测试。

### 远程仓库设置（生产环境推荐）
```bash
# 1. 在GitHub/GitLab等平台创建远程仓库

# 2. 添加远程仓库
git remote add origin <你的仓库URL>

# 3. 推送代码到远程仓库
git push -u origin master

# 4. 验证远程仓库
git remote -v
```

## 测试验证

### 本地验证
```bash
# 执行Jenkins模拟脚本
./jenkins-simulation.sh
```

### Jenkins验证
1. 修改测试脚本（jmeter-script/测试要删.jmx）
2. 提交代码到Git：
   ```bash
   git add .
   git commit -m "更新测试脚本"
   git push origin master  # 如果有远程仓库
   ```
3. 在Jenkins中执行Job
4. 验证是否拉取到最新代码
5. 查看测试报告

## 自动化触发

### Git Hook 触发
在Jenkins Job配置中启用：
- "GitHub hook trigger for GITScm polling" （如果使用GitHub）
- "Poll SCM" 定时检查（如：H/5 * * * * 每5分钟检查一次）

### 定时触发
在 "Build Triggers" 中配置：
- "Build periodically": 如 H 2 * * * （每天凌晨2点执行）

## 目录结构
```
JmeterMac2/
├── .git/                    # Git仓库文件
├── .gitignore              # Git忽略文件
├── build.xml               # Ant构建脚本（已集成Git拉取）
├── Jenkinsfile             # Jenkins Pipeline脚本
├── jenkins-simulation.sh   # Jenkins模拟脚本
├── JENKINS_SETUP.md        # 本配置文档
├── jmeter-script/          # JMeter测试脚本目录
├── jmeter-results/         # 测试结果目录（被Git忽略）
└── apache-jmeter-5.4.3/    # JMeter安装包（被Git忽略）
```

## 注意事项
1. 确保Jenkins运行用户有Git仓库的访问权限
2. 如果使用SSH密钥，需要在Jenkins中配置SSH凭据
3. 建议在生产环境中使用远程Git仓库
4. 定期备份Jenkins配置和测试脚本