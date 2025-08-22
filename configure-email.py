#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
邮箱配置向导
帮助用户配置QQ邮箱信息
"""

import os
import re
import getpass

def validate_email(email):
    """验证邮箱格式"""
    pattern = r'^[a-zA-Z0-9._%+-]+@qq\.com$'
    return re.match(pattern, email) is not None

def configure_email():
    """配置邮箱信息"""
    print("=========================================")
    print("📧 QQ邮箱配置向导")
    print("=========================================")
    print()
    
    # 获取QQ邮箱
    while True:
        email = input("请输入你的QQ邮箱地址 (例如: 123456789@qq.com): ").strip()
        if validate_email(email):
            break
        else:
            print("❌ 邮箱格式错误！请输入有效的QQ邮箱地址")
    
    print()
    print("💡 获取授权码的步骤：")
    print("1. 登录QQ邮箱网页版 (https://mail.qq.com)")
    print("2. 点击右上角 '设置'")
    print("3. 选择 '账户'")
    print("4. 找到 'POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务'")
    print("5. 开启 'POP3/SMTP服务'")
    print("6. 点击 '生成授权码' 按钮")
    print("7. 将收到的授权码复制到下面")
    print()
    
    # 获取授权码
    while True:
        password = getpass.getpass("请输入QQ邮箱授权码: ").strip()
        if len(password) >= 10:
            break
        else:
            print("❌ 授权码太短！QQ邮箱授权码通常是16位字符")
    
    print()
    print("✅ 邮箱信息配置完成！")
    print(f"📧 邮箱地址: {email}")
    print(f"🔑 授权码: {'*' * len(password)}")
    
    return email, password

def update_script(email, password):
    """更新Python脚本中的邮箱配置"""
    script_path = "send-email-python.py"
    
    if not os.path.exists(script_path):
        print(f"❌ 脚本文件 {script_path} 不存在")
        return False
    
    try:
        # 读取原脚本
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 替换邮箱配置
        content = content.replace(
            'SENDER_EMAIL = "your_qq_email@qq.com"',
            f'SENDER_EMAIL = "{email}"'
        )
        content = content.replace(
            'SENDER_PASSWORD = "your_app_password"',
            f'SENDER_PASSWORD = "{password}"'
        )
        
        # 写回文件
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ 已更新 {script_path} 文件")
        return True
        
    except Exception as e:
        print(f"❌ 更新脚本文件失败: {e}")
        return False

def test_email_sending():
    """测试邮件发送"""
    print()
    print("🚀 现在测试邮件发送功能...")
    
    try:
        # 导入并运行邮件发送脚本
        import subprocess
        result = subprocess.run(['python3', 'send-email-python.py'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ 邮件发送测试成功！")
            print("📧 请检查你的QQ邮箱收件箱")
        else:
            print("❌ 邮件发送测试失败")
            print("错误信息:")
            print(result.stderr)
            
    except Exception as e:
        print(f"❌ 测试邮件发送时出错: {e}")

def main():
    """主函数"""
    print("欢迎使用QQ邮箱配置向导！")
    print("这个工具将帮助你配置邮件发送功能")
    print()
    
    # 配置邮箱
    email, password = configure_email()
    
    # 更新脚本
    if update_script(email, password):
        print()
        print("🎉 配置完成！现在可以发送邮件了")
        
        # 询问是否立即测试
        test_now = input("\n是否立即测试邮件发送？(y/n): ").strip().lower()
        if test_now in ['y', 'yes', '是']:
            test_email_sending()
        else:
            print("\n💡 你可以稍后运行以下命令来测试:")
            print("   python3 send-email-python.py")
    else:
        print("\n❌ 配置失败，请手动编辑脚本文件")

if __name__ == "__main__":
    main()

