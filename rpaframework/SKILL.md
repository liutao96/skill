---
name: rpaframework
description: RPA Framework - 用于机器人流程自动化的开源Python库，支持浏览器自动化、Excel处理、PDF操作、邮件发送等RPA任务
# EXTENDED METADATA (MANDATORY)
github_url: https://github.com/robocorp/rpaframework.git
github_hash: unknown
version: 28.0.0
created_at: 2026-03-05
entry_point: scripts/wrapper.py
dependencies: ["rpaframework", "robotframework"]
---

# RPA Framework 技能

## 简介

RPA Framework 是一个用于机器人流程自动化（RPA）的开源 Python 库，由 Robocorp 开发。它提供了丰富的关键字库，可用于自动化各种桌面和 Web 应用程序。

## 主要功能

### 核心库
- **RPA.Browser.Selenium** - 使用 Selenium 进行 Web 浏览器自动化
- **RPA.Browser.Playwright** - 使用 Playwright 进行现代 Web 自动化
- **RPA.Excel.Files** - 读写 Excel 文件（.xlsx, .xls）
- **RPA.PDF** - PDF 文档操作和处理
- **RPA.Email.ImapSmtp** - 发送和接收电子邮件
- **RPA.FileSystem** - 文件系统操作
- **RPA.Tables** - 表格数据处理
- **RPA.HTTP** - HTTP 请求和 API 调用
- **RPA.Desktop** - 桌面应用程序自动化
- **RPA.Database** - 数据库操作
- **RPA.Cloud.Google** - Google Cloud 服务集成
- **RPA.Cloud.AWS** - AWS 服务集成
- **RPA.SAP** - SAP GUI 自动化
- **RPA.Windows** - Windows 应用程序自动化
- **RPA.Outlook.Application** - Microsoft Outlook 自动化

## 使用方法

### Python 方式

```python
from RPA.Browser.Selenium import Selenium
from RPA.Excel.Files import Files

# 浏览器自动化
browser = Selenium()
browser.open_available_browser("https://example.com")
browser.input_text("id:username", "myuser")
browser.input_text("id:password", "mypass")
browser.click_button("id:submit")

# Excel 处理
excel = Files()
excel.open_workbook("data.xlsx")
sheet = excel.read_worksheet_as_table("Sheet1")
excel.close_workbook()
```

### Robot Framework 方式

```robot
*** Settings ***
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files

*** Tasks ***
处理网页和Excel
    Open Available Browser    https://example.com
    Input Text    id:username    myuser
    Input Text    id:password    mypass
    Click Button    id:submit

    Open Workbook    data.xlsx
    ${table}=    Read Worksheet As Table
    Close Workbook
```

## 安装

```bash
# 安装完整版（包含所有库）
pip install rpaframework

# 安装精简版（核心库）
pip install rpaframework-core

# 安装特定库
pip install rpaframework-assistant
pip install rpaframework-google
pip install rpaframework-aws
pip install rpaframework-recognition
```

## 依赖要求

- Python 3.9+
- Windows/Linux/macOS 支持
- 某些库需要额外依赖（如浏览器驱动、OCR 引擎等）

## 文档链接

- 官方文档: https://robocorp.com/docs/libraries/rpa-framework
- PyPI: https://pypi.org/project/rpaframework/
- GitHub: https://github.com/robocorp/rpaframework

## 注意事项

1. RPA Framework 设计用于 Robocorp Cloud，但也可以独立使用
2. 某些功能需要安装额外的二进制依赖（如 Tesseract OCR）
3. Windows 桌面自动化需要在 Windows 环境运行
4. SAP 自动化需要 SAP GUI 安装

## 触发关键词

当用户提到以下任何内容时，使用此技能：
- RPA 自动化
- 浏览器自动化
- Excel 处理
- PDF 操作
- 邮件自动化
- 桌面应用自动化
- Robocorp
- RPA Framework
- 数据提取/抓取
- UI 自动化
