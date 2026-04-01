#!/usr/bin/env python3
"""
RPA Framework 技能包装器
提供常用的 RPA 自动化任务辅助功能
"""

import sys
import subprocess
from pathlib import Path

def check_installation():
    """检查 rpaframework 是否已安装"""
    try:
        import RPA
        return True
    except ImportError:
        return False

def install_rpaframework():
    """安装 rpaframework"""
    print("正在安装 rpaframework...")
    subprocess.run([sys.executable, "-m", "pip", "install", "rpaframework"], check=True)
    print("安装完成!")

def show_examples():
    """显示常用代码示例"""
    examples = """
# ===== RPA Framework 常用代码示例 =====

## 1. 浏览器自动化 (Selenium)
from RPA.Browser.Selenium import Selenium

browser = Selenium()
browser.open_available_browser("https://example.com")
browser.maximize_browser_window()
browser.input_text("id:username", "admin")
browser.input_text("id:password", "secret")
browser.click_button("css:button[type='submit']")
screenshot = browser.capture_page_screenshot()
browser.close_browser()

## 2. Excel 处理
from RPA.Excel.Files import Files

excel = Files()
excel.create_workbook("output.xlsx")
excel.append_rows_to_worksheet(
    [["Name", "Age", "City"],
     ["张三", 25, "北京"],
     ["李四", 30, "上海"]],
    header=True
)
excel.save_workbook()

## 3. PDF 操作
from RPA.PDF import PDF

pdf = PDF()
pdf.open_pdf("document.pdf")
text = pdf.get_text_from_pdf()
pdf.close_pdf()

## 4. 邮件发送
from RPA.Email.ImapSmtp import ImapSmtp

mail = ImapSmtp(smtp_server="smtp.gmail.com", smtp_port=587)
mail.authorize(account="your@email.com", password="your_password")
mail.send_message(
    sender="your@email.com",
    recipients=["recipient@email.com"],
    subject="测试邮件",
    body="这是邮件内容"
)

## 5. 文件系统操作
from RPA.FileSystem import FileSystem

fs = FileSystem()
files = fs.find_files("*.pdf")
for file in files:
    print(f"Found: {file}")

## 6. HTTP 请求
from RPA.HTTP import HTTP

http = HTTP()
http.download(
    url="https://example.com/file.pdf",
    target_file="downloads/file.pdf",
    overwrite=True
)
"""
    print(examples)

def main():
    if len(sys.argv) < 2:
        print("""RPA Framework 技能

用法:
  wrapper.py check      - 检查安装状态
  wrapper.py install    - 安装 rpaframework
  wrapper.py examples   - 显示代码示例
  wrapper.py version    - 显示版本信息
        """)
        return

    command = sys.argv[1].lower()

    if command == "check":
        if check_installation():
            print("✅ rpaframework 已安装")
            try:
                import RPA
                print(f"位置: {RPA.__file__}")
            except:
                pass
        else:
            print("❌ rpaframework 未安装")
            print("运行: wrapper.py install")

    elif command == "install":
        install_rpaframework()

    elif command == "examples":
        show_examples()

    elif command == "version":
        if check_installation():
            try:
                import RPA
                print(f"RPA Framework 已安装")
            except:
                pass
        print("RPA Framework PyPI 版本: 28.0.0+")

    else:
        print(f"未知命令: {command}")

if __name__ == "__main__":
    main()
