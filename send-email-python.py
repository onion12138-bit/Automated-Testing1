#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Ford Smart Badge 邮件发送脚本
使用Python smtplib发送邮件，绕过系统邮件服务问题
"""

import smtplib
import os
import sys
import glob
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime

# 邮件配置
SMTP_SERVER = "smtp.qq.com"
SMTP_PORT = 465  # 使用SSL端口
SENDER_EMAIL = "2635880013@qq.com"  # 需要修改为你的QQ邮箱
SENDER_PASSWORD = "egkynjiqcaccebdf"   # 需要修改为你的QQ邮箱授权码
RECIPIENT_EMAIL = "2335327949@qq.com"

# Web服务器配置
WEB_URL = "http://192.168.2.1:8000"
WORKSPACE_DIR = "/Users/onion/Desktop/JmeterMac2"

def find_latest_report():
    """查找最新的JMeter报告"""
    # 查找/tmp目录下的最新ZIP报告
    tmp_reports = glob.glob("/tmp/JMeter_Report_*.zip")
    if tmp_reports:
        latest_zip = max(tmp_reports, key=os.path.getctime)
        report_name = os.path.basename(latest_zip).replace('.zip', '')
        return latest_zip, report_name
    
    # 如果/tmp没有，查找web-reports目录
    web_reports = glob.glob(f"{WORKSPACE_DIR}/web-reports/reports/JMeter_Report_*.zip")
    if web_reports:
        latest_zip = max(web_reports, key=os.path.getctime)
        report_name = os.path.basename(latest_zip).replace('.zip', '')
        return latest_zip, report_name
    
    return None, None

def generate_web_urls(report_name):
    """生成Web可访问的URL"""
    web_base_url = f"{WEB_URL}/reports/{report_name}"
    
    # 查找HTML报告文件
    summary_report = ""
    detail_report = ""
    
    # 检查web-reports目录
    web_dir = f"{WORKSPACE_DIR}/web-reports/reports/{report_name}"
    if os.path.exists(web_dir):
        # 查找汇总报告
        summary_files = glob.glob(f"{web_dir}/**/html_summary_reports/*.html", recursive=True)
        if summary_files:
            summary_report = f"{web_base_url}/{report_name}/html_summary_reports/{os.path.basename(summary_files[0])}"
        
        # 查找详细报告
        detail_files = glob.glob(f"{web_dir}/**/html_detail_reports/*.html", recursive=True)
        if detail_files:
            detail_report = f"{web_base_url}/{report_name}/html_detail_reports/{os.path.basename(detail_files[0])}"
    
    return {
        'summary': summary_report,
        'detail': detail_report,
        'download': f"{web_base_url}.zip",
        'center': WEB_URL
    }

def create_email_content(report_name, web_urls):
    """创建邮件内容"""
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 邮件主题
    subject = f"📊 JMeter测试报告 - {current_time}"
    
    # 邮件正文
    body = f"""📊 Ford Smart Badge JMeter测试报告已生成

🔗 可访问的报告链接：
"""
    
    if web_urls['summary']:
        body += f"📈 汇总报告: {web_urls['summary']}\n"
    
    if web_urls['detail']:
        body += f"📋 详细报告: {web_urls['detail']}\n"
    
    body += f"""📦 下载报告: {web_urls['download']}
🏠 报告中心: {web_urls['center']}

⏰ 测试时间: {current_time}
📧 如有问题请联系: {RECIPIENT_EMAIL}

---
💡 使用说明：
• 点击链接可直接在浏览器中查看报告
• 报告中心包含所有历史报告
• 如需外网访问，请联系管理员配置

⚠️ 注意：此邮件为手动执行，非定时发送
"""
    
    return subject, body

def send_email(subject, body, attachment_path=None):
    """
    发送邮件（UTF-8编码支持）
    
    Args:
        subject: 邮件主题
        body: 邮件正文
        attachment_path: 附件路径（可选）
    """
    try:
        # 创建邮件对象，确保UTF-8编码
        msg = MIMEMultipart('mixed')
        msg['From'] = f"JMeter自动化测试 <{SENDER_EMAIL}>"
        msg['To'] = RECIPIENT_EMAIL
        
        # 使用Header确保主题的UTF-8编码
        from email.header import Header
        msg['Subject'] = Header(subject, 'utf-8')
        
        # 添加邮件正文，明确指定UTF-8编码
        msg.attach(MIMEText(body, 'plain', 'utf-8'))
        
        # 添加附件（如果存在）
        if attachment_path and os.path.exists(attachment_path):
            with open(attachment_path, "rb") as attachment:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(attachment.read())
            
            encoders.encode_base64(part)
            # 使用Header确保附件文件名的UTF-8编码
            filename = Header(os.path.basename(attachment_path), 'utf-8').encode()
            part.add_header(
                'Content-Disposition',
                f'attachment; filename={filename}'
            )
            msg.attach(part)
            print(f"✅ 附件已添加: {attachment_path}")
        
        # 连接SMTP服务器
        print(f"🔌 连接到SMTP服务器: {SMTP_SERVER}:{SMTP_PORT}")
        server = smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT)
        
        # 登录
        print(f"🔐 登录邮箱: {SENDER_EMAIL}")
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        
        # 发送邮件
        print("📧 发送邮件...")
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, RECIPIENT_EMAIL, text)
        
        # 关闭连接
        server.quit()
        
        print("✅ 邮件发送成功！")
        return True
        
    except smtplib.SMTPAuthenticationError as e:
        print(f"❌ 邮箱认证失败: {str(e)}")
        print("💡 请检查邮箱地址和授权码是否正确")
        return False
    except smtplib.SMTPConnectError as e:
        print(f"❌ 连接SMTP服务器失败: {str(e)}")
        print("💡 请检查网络连接和SMTP服务器设置")
        return False
    except smtplib.SMTPException as e:
        print(f"❌ SMTP错误: {str(e)}")
        return False
    except Exception as e:
        print(f"❌ 邮件发送失败: {str(e)}")
        return False

def main():
    """主函数"""
    print("=========================================")
    print("📧 Ford Smart Badge 邮件发送脚本")
    print("=========================================")
    
    # 检查配置
    if SENDER_EMAIL == "your_qq_email@qq.com":
        print("❌ 请先配置发送邮箱信息！")
        print("📝 编辑此脚本，修改以下变量：")
        print("   SENDER_EMAIL = '你的QQ邮箱@qq.com'")
        print("   SENDER_PASSWORD = '你的QQ邮箱授权码'")
        print("")
        print("💡 获取授权码方法：")
        print("1. 登录QQ邮箱网页版")
        print("2. 设置 -> 账户 -> POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务")
        print("3. 开启SMTP服务并获取授权码")
        return False
    
    # 查找最新报告
    latest_zip, report_name = find_latest_report()
    
    if not latest_zip or not report_name:
        print("❌ 未找到JMeter测试报告")
        return False
    
    print(f"📦 找到最新报告: {report_name}")
    
    # 生成Web URL
    web_urls = generate_web_urls(report_name)
    
    print("🔗 生成的Web URL:")
    if web_urls['summary']:
        print(f"📈 汇总报告: {web_urls['summary']}")
    if web_urls['detail']:
        print(f"📋 详细报告: {web_urls['detail']}")
    print(f"📦 下载报告: {web_urls['download']}")
    print(f"🏠 报告中心: {web_urls['center']}")
    
    # 创建邮件内容
    subject, body = create_email_content(report_name, web_urls)
    
    # 发送邮件
    success = send_email(subject, body, latest_zip)
    
    if success:
        print("")
        print("=========================================")
        print("🎉 邮件发送完成！")
        print("📧 收件人:", RECIPIENT_EMAIL)
        if latest_zip:
            print("📎 附件:", latest_zip)
        print("⚠️ 注意：此邮件为手动执行，非定时发送")
        print("=========================================")
    else:
        print("")
        print("=========================================")
        print("❌ 邮件发送失败")
        print("🔍 请检查网络连接和邮箱配置")
        print("=========================================")
    
    return success

if __name__ == "__main__":
    main()
