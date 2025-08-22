#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
邮箱问题修复脚本
帮助用户解决QQ邮箱SMTP连接问题
"""

import smtplib
import ssl
import socket

def check_qq_email_setup():
    """检查QQ邮箱设置"""
    print("=========================================")
    print("🔍 QQ邮箱设置检查")
    print("=========================================")
    print()
    
    print("📋 请按照以下步骤检查和设置QQ邮箱：")
    print()
    print("1️⃣ 登录QQ邮箱网页版")
    print("   网址: https://mail.qq.com")
    print()
    print("2️⃣ 开启SMTP服务")
    print("   • 点击右上角 '设置'")
    print("   • 选择 '账户'")
    print("   • 找到 'POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务'")
    print("   • 开启 'POP3/SMTP服务'")
    print("   • 开启 'IMAP/SMTP服务'")
    print()
    print("3️⃣ 获取授权码")
    print("   • 在SMTP服务设置中点击 '生成授权码'")
    print("   • 输入QQ密码验证")
    print("   • 复制生成的16位授权码")
    print()
    print("4️⃣ 重要提醒")
    print("   • 授权码不是QQ密码！")
    print("   • 授权码通常以字母开头")
    print("   • 如果授权码不工作，请重新生成")
    print()
    
    return input("完成设置后按回车继续，或输入 'q' 退出: ").strip().lower()

def test_with_debug():
    """使用调试模式测试SMTP连接"""
    print("\n=========================================")
    print("🔍 调试模式SMTP测试")
    print("=========================================")
    
    # 获取用户输入
    email = input("请输入QQ邮箱地址: ").strip()
    password = input("请输入授权码: ").strip()
    
    if not email or not password:
        print("❌ 邮箱地址和授权码不能为空")
        return False
    
    print(f"\n📧 测试邮箱: {email}")
    print(f"🔑 授权码长度: {len(password)}")
    
    # 测试连接
    try:
        print("\n🔌 尝试连接SMTP服务器...")
        
        # 创建SMTP连接，启用调试
        server = smtplib.SMTP_SSL("smtp.qq.com", 465, timeout=30)
        server.set_debuglevel(1)  # 启用详细调试
        
        print("✅ SMTP连接成功")
        
        # 尝试登录
        print("\n🔐 尝试登录...")
        server.login(email, password)
        print("✅ 登录成功！")
        
        # 发送测试邮件
        print("\n📧 发送测试邮件...")
        test_msg = f"""From: {email}
To: 2335327949@qq.com
Subject: 邮箱配置测试成功
Content-Type: text/plain; charset=UTF-8

恭喜！你的QQ邮箱SMTP配置已经成功。

发送时间: {__import__('datetime').datetime.now()}
发送邮箱: {email}

---
Ford Smart Badge 自动化测试系统
"""
        
        server.sendmail(email, ["2335327949@qq.com"], test_msg)
        print("✅ 测试邮件发送成功！")
        print("📧 请检查收件箱: 2335327949@qq.com")
        
        server.quit()
        return True
        
    except smtplib.SMTPAuthenticationError as e:
        print(f"\n❌ 认证失败: {e}")
        print("💡 可能的原因:")
        print("   • 授权码不正确")
        print("   • 邮箱地址错误")
        print("   • SMTP服务未开启")
        print("   • 需要重新生成授权码")
        return False
        
    except smtplib.SMTPConnectError as e:
        print(f"\n❌ 连接失败: {e}")
        print("💡 可能的原因:")
        print("   • 网络连接问题")
        print("   • 防火墙阻止")
        print("   • SMTP服务器不可用")
        return False
        
    except Exception as e:
        print(f"\n❌ 未知错误: {e}")
        print("💡 请检查网络连接和邮箱设置")
        return False

def update_config_file(email, password):
    """更新配置文件"""
    print(f"\n📝 更新配置文件...")
    
    try:
        # 更新Python脚本
        with open("send-email-python.py", "r", encoding="utf-8") as f:
            content = f.read()
        
        # 替换邮箱配置
        content = content.replace(
            'SENDER_EMAIL = "2635880013@qq.com"',
            f'SENDER_EMAIL = "{email}"'
        )
        content = content.replace(
            'SENDER_PASSWORD = "$lp123456$lp123456"',
            f'SENDER_PASSWORD = "{password}"'
        )
        
        with open("send-email-python.py", "w", encoding="utf-8") as f:
            f.write(content)
        
        print("✅ send-email-python.py 已更新")
        
        # 更新curl脚本
        with open("send-email-curl.sh", "r", encoding="utf-8") as f:
            content = f.read()
        
        content = content.replace(
            'SENDER_EMAIL="your_qq_email@qq.com"',
            f'SENDER_EMAIL="{email}"'
        )
        content = content.replace(
            'SENDER_PASSWORD="your_app_password"',
            f'SENDER_PASSWORD="{password}"'
        )
        
        with open("send-email-curl.sh", "w", encoding="utf-8") as f:
            f.write(content)
        
        print("✅ send-email-curl.sh 已更新")
        
        return True
        
    except Exception as e:
        print(f"❌ 更新配置文件失败: {e}")
        return False

def main():
    """主函数"""
    print("欢迎使用邮箱问题修复脚本！")
    print("这个工具将帮助你解决QQ邮箱SMTP连接问题")
    print()
    
    # 检查邮箱设置
    if check_qq_email_setup() == 'q':
        print("👋 退出程序")
        return
    
    # 测试连接
    if test_with_debug():
        print("\n🎉 邮箱配置测试成功！")
        
        # 获取当前配置的邮箱信息
        email = input("\n请输入要保存的邮箱地址: ").strip()
        password = input("请输入要保存的授权码: ").strip()
        
        if email and password:
            if update_config_file(email, password):
                print("\n✅ 所有配置文件已更新！")
                print("🚀 现在你可以运行以下命令来测试:")
                print("   python3 send-email-python.py")
                print("   ./start-test-now.sh")
            else:
                print("\n❌ 配置文件更新失败")
        else:
            print("\n⚠️ 未输入邮箱信息，配置文件未更新")
    else:
        print("\n❌ 邮箱配置测试失败")
        print("💡 请按照上述步骤重新检查和设置QQ邮箱")
        print("🔍 如果问题持续，请检查:")
        print("   • 网络连接")
        print("   • 防火墙设置")
        print("   • QQ邮箱服务状态")

if __name__ == "__main__":
    main()

