#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
SMTP连接测试脚本
用于诊断QQ邮箱SMTP连接问题
"""

import smtplib
import ssl

def test_smtp_connection():
    """测试SMTP连接"""
    print("=========================================")
    print("🔍 SMTP连接测试")
    print("=========================================")
    
    # 测试配置
    smtp_server = "smtp.qq.com"
    smtp_port = 465
    email = "2635880013@qq.com"
    password = "$lp123456$lp123456"
    
    print(f"📧 邮箱: {email}")
    print(f"🌐 服务器: {smtp_server}:{smtp_port}")
    print()
    
    # 测试1: 端口连接
    print("🔌 测试1: 端口连接...")
    try:
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((smtp_server, smtp_port))
        sock.close()
        
        if result == 0:
            print("✅ 端口连接成功")
        else:
            print(f"❌ 端口连接失败: {result}")
            return False
    except Exception as e:
        print(f"❌ 端口连接测试异常: {e}")
        return False
    
    # 测试2: SSL连接
    print("\n🔌 测试2: SSL连接...")
    try:
        context = ssl.create_default_context()
        with socket.create_connection((smtp_server, smtp_port), timeout=10) as sock:
            with context.wrap_socket(sock, server_hostname=smtp_server) as ssock:
                print("✅ SSL连接成功")
    except Exception as e:
        print(f"❌ SSL连接失败: {e}")
        return False
    
    # 测试3: SMTP连接
    print("\n🔌 测试3: SMTP连接...")
    try:
        server = smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=10)
        print("✅ SMTP连接成功")
        
        # 测试4: 登录
        print("\n🔐 测试4: 邮箱登录...")
        try:
            server.login(email, password)
            print("✅ 邮箱登录成功")
            
            # 测试5: 发送测试邮件
            print("\n📧 测试5: 发送测试邮件...")
            try:
                test_msg = f"""From: {email}
To: 2335327949@qq.com
Subject: SMTP连接测试
Content-Type: text/plain; charset=UTF-8

这是一封SMTP连接测试邮件。
发送时间: {__import__('datetime').datetime.now()}

---
SMTP连接测试脚本
"""
                server.sendmail(email, ["2335327949@qq.com"], test_msg)
                print("✅ 测试邮件发送成功！")
                print("📧 请检查收件箱: 2335327949@qq.com")
                
            except Exception as e:
                print(f"❌ 测试邮件发送失败: {e}")
                
        except Exception as e:
            print(f"❌ 邮箱登录失败: {e}")
            print("💡 请检查邮箱地址和授权码")
            
        server.quit()
        
    except Exception as e:
        print(f"❌ SMTP连接失败: {e}")
        return False
    
    return True

def test_alternative_ports():
    """测试其他端口"""
    print("\n=========================================")
    print("🔍 测试其他SMTP端口")
    print("=========================================")
    
    ports = [587, 25, 465]
    smtp_server = "smtp.qq.com"
    
    for port in ports:
        print(f"\n🔌 测试端口 {port}...")
        try:
            if port == 465:
                server = smtplib.SMTP_SSL(smtp_server, port, timeout=5)
            else:
                server = smtplib.SMTP(smtp_server, port, timeout=5)
                if port == 587:
                    server.starttls()
            
            print(f"✅ 端口 {port} 连接成功")
            server.quit()
            
        except Exception as e:
            print(f"❌ 端口 {port} 连接失败: {e}")

if __name__ == "__main__":
    print("开始SMTP连接诊断...")
    
    if test_smtp_connection():
        print("\n🎉 所有测试通过！")
    else:
        print("\n❌ 连接测试失败")
        test_alternative_ports()
    
    print("\n=========================================")
    print("🔍 诊断完成")
    print("=========================================")

