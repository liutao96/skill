# Claude Code Skills 中文说明

> 最后更新: 2026-01-24

## 已安装的 Skills 一览

| Skill 名称 | 用途 | 触发场景 |
|-----------|------|---------|
| [canvas-design](#canvas-design) | 视觉艺术创作 | 创建海报、艺术品、设计稿 |
| [doc-coauthoring](#doc-coauthoring) | 文档协作写作 | 写技术文档、PRD、决策文档 |
| [docx](#docx) | Word文档处理 | 创建/编辑/分析 .docx 文件 |
| [frontend-design](#frontend-design) | 前端界面设计 | 构建网站、组件、仪表盘 |
| [mcp-builder](#mcp-builder) | MCP服务器开发 | 创建MCP服务器集成外部API |
| [pdf](#pdf) | PDF文档处理 | 创建/编辑/提取PDF内容 |
| [skill-creator](#skill-creator) | 创建新Skill | 开发自定义skill扩展能力 |
| [xlsx](#xlsx) | Excel表格处理 | 创建/编辑/分析电子表格 |

---

## 详细说明

### canvas-design
**视觉艺术创作**

用于生成高品质的 .png 和 .pdf 设计作品，如海报、艺术品等。

**工作流程:**
1. 创建设计哲学 (.md文件) - 定义美学方向
2. 画布表达 (.pdf/.png) - 将哲学转化为视觉作品

**特点:**
- 包含 80+ 精选设计字体
- 强调大师级工艺和独特美学
- 避免千篇一律的AI风格

**示例指令:** "帮我设计一张音乐节海报"

---

### doc-coauthoring
**文档协作写作**

提供结构化的文档创建工作流，适合撰写技术文档、提案、决策文档等。

**三阶段流程:**
1. **上下文收集** - 收集背景、约束、利益相关者关注点
2. **精炼与结构化** - 逐节构建：头脑风暴→筛选→起草→迭代
3. **读者测试** - 用全新Claude测试文档发现盲点

**示例指令:** "帮我写一份技术设计文档"

---

### docx
**Word文档处理**

完整的 .docx 文件操作能力。

**核心功能:**
- 读取/分析文档 - 使用 pandoc 提取文本
- 创建新文档 - 使用 docx-js 库
- 编辑现有文档 - 支持跟踪修改(redlining)
- 处理批注和格式

**依赖工具:** pandoc, docx-js (npm), lxml (Python)

**示例指令:** "把这份Word文档转成Markdown"

---

### frontend-design
**前端界面设计**

创建独特、生产级的前端界面，避免千篇一律的设计。

**适用场景:**
- 网站、落地页
- React/Vue组件
- 仪表盘
- HTML/CSS布局

**设计原则:**
- 大胆的美学方向 (极简、复古、奢华等)
- 独特字体选择 (避免Arial、Inter)
- 动效设计 (CSS动画、滚动触发)
- 创意布局 (不对称、重叠、打破网格)

**示例指令:** "帮我设计一个个人作品集网站"

---

### mcp-builder
**MCP服务器开发**

创建高质量的 Model Context Protocol 服务器，让LLM能与外部服务交互。

**四阶段开发:**
1. 深度研究与规划 - 学习MCP协议和API
2. 实现 - 项目结构和工具开发
3. 审查与测试 - 代码质量和验证
4. 创建评估 - 测试服务器效果

**推荐技术栈:**
- TypeScript (推荐) 或 Python
- Zod / Pydantic 做Schema验证

**示例指令:** "帮我创建一个GitHub MCP服务器"

---

### pdf
**PDF文档处理**

完整的 PDF 操作工具包。

**核心功能:**
- 文本/表格提取
- 创建新PDF
- 合并/拆分文档
- 表单填写
- OCR扫描文档
- 水印/加密

**依赖工具:** pypdf, pdfplumber, reportlab, pytesseract

**示例指令:** "把这几个PDF合并成一个"

---

### skill-creator
**创建新Skill**

用于创建其他skill的元skill。

**Skill创建流程:**
1. 理解skill的具体使用示例
2. 规划可复用内容 (scripts/references/assets)
3. 运行 `init_skill.py` 初始化
4. 编辑 SKILL.md 和资源文件
5. 运行 `package_skill.py` 打包
6. 基于实际使用迭代改进

**包含脚本:**
- `init_skill.py` - 初始化新skill模板
- `package_skill.py` - 打包为 .skill 分发文件
- `quick_validate.py` - 快速验证skill

**示例指令:** "帮我创建一个处理CSV的skill"

---

### xlsx
**Excel表格处理**

完整的电子表格操作能力。

**核心功能:**
- 创建带公式和格式的Excel文件
- 读取/分析数据 (pandas)
- 编辑现有文件保留公式
- 公式重新计算
- 错误检测 (#REF!, #DIV/0! 等)

**财务模型规范:**
- 蓝色文字 = 输入值
- 黑色文字 = 公式
- 绿色文字 = 工作表链接
- 黄色背景 = 需要关注的假设

**依赖工具:** openpyxl, pandas, LibreOffice

**示例指令:** "帮我创建一个财务预算模板"

---

## 如何使用

Skills 会根据你的请求自动触发。你也可以直接提及skill名称来使用特定功能。

**查看所有skills:**
```bash
ls ~/.claude/skills/
```

**查看某个skill的详细文档:**
```bash
cat ~/.claude/skills/<skill名称>/SKILL.md
```

---

## 安装更多 Skills

官方skills仓库: https://github.com/anthropics/skills

安装方法:
```bash
# 克隆特定skill
cd /tmp
git clone --depth 1 --filter=blob:none --sparse https://github.com/anthropics/skills.git
cd skills
git sparse-checkout set skills/<skill名称>
cp -r skills/<skill名称> ~/.claude/skills/
```
