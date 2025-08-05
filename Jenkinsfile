pipeline {
    agent any
    
    environment {
        // 设置工作空间路径
        WORKSPACE_PATH = "${WORKSPACE}"
        JMETER_HOME = "${WORKSPACE}/apache-jmeter-5.4.3"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo '正在从Git仓库拉取最新代码...'
                checkout scm
                script {
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                    def gitBranch = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    echo "当前分支: ${gitBranch}"
                    echo "当前提交: ${gitCommit}"
                }
            }
        }
        
        stage('Verify Environment') {
            steps {
                echo '验证测试环境...'
                sh '''
                    echo "工作目录: $(pwd)"
                    echo "Java版本:"
                    java -version
                    echo "Ant版本:"
                    ant -version
                    echo "测试脚本:"
                    ls -la jmeter-script/
                '''
            }
        }
        
        stage('Clean Previous Results') {
            steps {
                echo '清理之前的测试结果...'
                sh '''
                    rm -rf jmeter-results/
                    mkdir -p jmeter-results/jtl
                    mkdir -p jmeter-results/html
                    mkdir -p jmeter-results/detail
                '''
            }
        }
        
        stage('Run JMeter Tests') {
            steps {
                echo '执行JMeter自动化测试...'
                sh '''
                    # 设置JAVA_HOME（如果需要）
                    # export JAVA_HOME=/path/to/java
                    
                    # 执行Ant构建（不包含git-update，因为Jenkins已经处理了代码拉取）
                    ant clean test report
                '''
            }
        }
        
        stage('Archive Results') {
            steps {
                echo '归档测试结果...'
                // 归档测试结果文件
                archiveArtifacts artifacts: 'jmeter-results/**/*', fingerprint: true
                
                // 如果有JUnit格式的结果，可以发布测试结果
                // publishTestResults testResultsPattern: 'jmeter-results/**/*.xml'
            }
        }
        
        stage('Publish Reports') {
            steps {
                echo '发布HTML测试报告...'
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'jmeter-results/html',
                    reportFiles: '*.html',
                    reportName: 'JMeter Summary Report',
                    reportTitles: 'JMeter Test Summary'
                ])
                
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'jmeter-results/detail',
                    reportFiles: '*.html',
                    reportName: 'JMeter Detail Report',
                    reportTitles: 'JMeter Test Details'
                ])
            }
        }
    }
    
    post {
        always {
            echo '测试执行完成，清理工作空间...'
            // 清理临时文件，但保留结果
            sh '''
                # 可以根据需要清理临时文件
                echo "清理完成"
            '''
        }
        
        success {
            echo '✅ JMeter测试执行成功！'
            script {
                sh '''
                    echo "发送成功通知邮件..."
                    ./send-email.sh "SUCCESS" "jmeter-results/jtl/*.jtl" "jmeter-results/html/*.html"
                '''
            }
        }
        
        failure {
            echo '❌ JMeter测试执行失败！'
            script {
                sh '''
                    echo "发送失败通知邮件..."
                    ./send-email.sh "FAILED" "测试失败" "无报告"
                '''
            }
        }
        
        unstable {
            echo '⚠️ JMeter测试不稳定！'
            // 可以添加不稳定状态的通知
        }
    }
}