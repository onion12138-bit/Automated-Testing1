# 🔧 Jenkins环境配置完整指南

## 🚨 问题分析

你之前使用相对路径方法失败的根本原因是：**Jenkins环境变量配置问题**。

## 📍 Jenkins配置文件位置

### 1. **主配置文件**
```
~/.jenkins/config.xml
```

### 2. **Shell执行器配置**
```
~/.jenkins/hudson.tasks.Shell.xml
```

### 3. **Ant工具配置**
```
~/.jenkins/hudson.tasks.Ant.xml
```

### 4. **环境变量过滤器配置**
```
~/.jenkins/jenkins.tasks.filters.EnvVarsFilterGlobalConfiguration.xml
```

## 🔍 当前配置分析

### 主配置文件 (`config.xml`)
```xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson>
  <!-- 全局配置 -->
  <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULL_NAME}</workspaceDir>
  <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
  
  <!-- JDK配置 -->
  <jdks>
    <jdk>
      <name>JDK</name>
      <home>/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home</home>
    </jdk>
  </jdks>
  
  <!-- 节点属性（环境变量） -->
  <nodeProperties/>
  <globalNodeProperties/>
</hudson>
```

### Shell执行器配置 (`hudson.tasks.Shell.xml`)
```xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson.tasks.Shell_-DescriptorImpl>
  <shell>/bin/bash</shell>
</hudson.tasks.Shell_-DescriptorImpl>
```

### Ant工具配置 (`hudson.tasks.Ant.xml`)
```xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson.tasks.Ant_-DescriptorImpl plugin="ant@513.vde9e7b_a_0da_0f">
  <installations>
    <hudson.tasks.Ant_-AntInstallation>
      <name>ant</name>
      <home>/opt/homebrew/Cellar/ant/1.10.15_1/libexec</home>
    </hudson.tasks.AntInstallation>
  </installations>
</hudson.tasks.Ant_-DescriptorImpl>
```

## 🛠️ 解决方案1：配置全局环境变量

### 方法A：通过Jenkins Web界面配置

1. **打开Jenkins管理页面**
   - 访问：`http://127.0.0.1:8080`
   - 点击：`Manage Jenkins`（管理Jenkins）

2. **配置全局属性**
   - 点击：`Configure System`（配置系统）
   - 找到：`Global properties`（全局属性）
   - 勾选：`Environment variables`（环境变量）

3. **添加环境变量**
   ```
   PATH = /opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin
   HOME = /Users/onion
   SHELL = /bin/bash
   LANG = en_US.UTF-8
   LC_ALL = en_US.UTF-8
   ```

### 方法B：直接修改配置文件

编辑 `~/.jenkins/config.xml`，在 `<hudson>` 标签内添加：

```xml
<globalNodeProperties>
  <hudson.slaves.EnvironmentVariablesNodeProperty>
    <envVars serialization="custom">
      <unserializable-parents/>
      <tree-map>
        <default>
          <comparator class="hudson.util.CaseInsensitiveComparator"/>
        </default>
        <int>5</int>
        <string>HOME</string>
        <string>/Users/onion</string>
        <string>LANG</string>
        <string>en_US.UTF-8</string>
        <string>LC_ALL</string>
        <string>en_US.UTF-8</string>
        <string>PATH</string>
        <string>/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin</string>
        <string>SHELL</string>
        <string>/bin/bash</string>
      </tree-map>
    </envVars>
  </hudson.slaves.EnvironmentVariablesNodeProperty>
</globalNodeProperties>
```

## 🛠️ 解决方案2：配置节点环境变量

### 方法A：通过Web界面配置节点

1. **管理节点**
   - 点击：`Manage Jenkins` → `Manage Nodes and Clouds`
   - 点击：`master` 节点

2. **配置节点属性**
   - 点击：`Configure`
   - 找到：`Node Properties`
   - 勾选：`Environment variables`
   - 添加环境变量

### 方法B：修改节点配置

编辑 `~/.jenkins/config.xml`，在 `<hudson>` 标签内添加：

```xml
<nodeProperties>
  <hudson.slaves.EnvironmentVariablesNodeProperty>
    <envVars serialization="custom">
      <unserializable-parents/>
      <tree-map>
        <default>
          <comparator class="hudson.util.CaseInsensitiveComparator"/>
        </default>
        <int>5</int>
        <string>HOME</string>
        <string>/Users/onion</string>
        <string>LANG</string>
        <string>en_US.UTF-8</string>
        <string>LC_ALL</string>
        <string>en_US.UTF-8</string>
        <string>PATH</string>
        <string>/opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin</string>
        <string>SHELL</string>
        <string>/bin/bash</string>
      </tree-map>
    </envVars>
  </hudson.slaves.EnvironmentVariablesNodeProperty>
</nodeProperties>
```

## 🛠️ 解决方案3：配置任务级环境变量

### 在任务配置中添加环境变量

1. **编辑任务配置**
   - 进入任务：`Ford-Smart-Badge-Test`
   - 点击：`配置`

2. **添加构建环境变量**
   - 找到：`Build Environment`（构建环境）
   - 勾选：`Environment variables`
   - 添加：
     ```
     PATH = /opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin
     HOME = /Users/onion
     SHELL = /bin/bash
     ```

## 🔧 配置验证方法

### 1. **在Jenkins脚本中验证环境变量**

```bash
#!/bin/bash

echo "=== 环境变量验证 ==="
echo "PATH: $PATH"
echo "HOME: $HOME"
echo "SHELL: $SHELL"
echo "LANG: $LANG"
echo "LC_ALL: $LC_ALL"

echo "=== 命令路径验证 ==="
echo "which ant: $(which ant)"
echo "ant -version: $(ant -version)"

echo "=== 文件存在性验证 ==="
ls -la /opt/homebrew/bin/ant
```

### 2. **检查Jenkins日志**

查看构建日志，确认环境变量是否正确设置。

## 📊 配置方法对比

| 配置级别 | 优点 | 缺点 | 适用场景 |
|---------|------|------|----------|
| **全局配置** | 影响所有任务 | 需要重启Jenkins | 系统级配置 |
| **节点配置** | 影响特定节点 | 配置复杂 | 多节点环境 |
| **任务配置** | 只影响特定任务 | 每个任务都要配置 | 任务级定制 |

## 🎯 推荐配置方案

### 最佳实践：**全局环境变量配置**

1. **通过Web界面配置**（推荐）
   - 简单易操作
   - 不需要手动编辑XML
   - 配置后立即生效

2. **配置内容**
   ```
   PATH = /opt/homebrew/bin:/opt/homebrew/sbin:/bin:/usr/bin:/sbin:/usr/sbin
   HOME = /Users/onion
   SHELL = /bin/bash
   LANG = en_US.UTF-8
   LC_ALL = en_US.UTF-8
   ```

## 🚀 配置完成后测试

### 1. **重启Jenkins**
```bash
brew services restart jenkins-lts
```

### 2. **测试环境变量**
在Jenkins脚本中使用相对路径：
```bash
#!/bin/bash
echo "PATH: $PATH"
which ant
ant -version
ant run
```

### 3. **验证结果**
应该看到：
- `PATH` 包含正确的路径
- `which ant` 能找到ant命令
- `ant -version` 显示版本信息
- `ant run` 执行成功

## ⚠️ 注意事项

1. **配置后需要重启Jenkins**才能生效
2. **环境变量优先级**：任务级 > 节点级 > 全局级
3. **路径分隔符**：使用冒号`:`分隔多个路径
4. **权限问题**：确保Jenkins有权限访问配置的路径

## 🔍 故障排除

### 如果配置后仍然失败：

1. **检查Jenkins是否重启**
2. **验证环境变量是否正确设置**
3. **检查文件权限**
4. **查看Jenkins系统日志**

---

## 📝 总结

**相对路径失败的根本原因**：Jenkins没有正确配置环境变量，特别是`PATH`变量。

**最佳解决方案**：
1. 配置全局环境变量（推荐）
2. 或者使用绝对路径（当前使用的方案）

配置好环境变量后，你就可以使用相对路径的脚本了！
