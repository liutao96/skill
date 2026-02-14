# Claude Skills 技能仓库

这是我的 Claude Code 技能集合，包含 14 个技能，用于在多台电脑间同步使用。

## 📦 已安装的技能

### 数据处理类
- **xlsx** - Excel 电子表格处理工具
- **docx** - Word 文档处理工具
- **pdf** - PDF 文档处理工具

### 设计创作类
- **canvas-design** - 视觉艺术作品创建工具
- **frontend-design** - 前端界面设计工具

### 文档协作类
- **doc-coauthoring** - 文档协同撰写工具

### 数据库类
- **PolarDB_Query** - PolarDB (MySQL) 数据库查询工具
- **postgresql-helper** - PostgreSQL 文档助手
- **aliyun-server-manager** - 阿里云服务器管理工具（自定义）

### 开发工具类
- **mcp-builder** - MCP 服务器创建指南
- **github-to-skills** - GitHub 仓库转技能工具

### 技能管理类
- **skill-creator** - 技能创建开发指南
- **skill-manager** - 技能生命周期管理器
- **skill-evolution-manager** - 技能优化迭代工具

## 🚀 在新电脑上安装

### 1. 确保已安装 Claude Code

参考官方文档安装 Claude Code CLI 工具。

### 2. 克隆此仓库到技能目录

```bash
# 删除默认的空技能目录（如果存在）
rm -rf ~/.claude/skills

# 克隆技能仓库
cd ~/.claude
git clone https://github.com/liutao96/skill.git skills
```

### 3. 重启 Claude Code

```bash
# 关闭当前会话并重新打开，技能将自动加载
```

## 🔄 同步更新

### 在当前电脑上推送更新

```bash
cd ~/.claude/skills
git add .
git commit -m "更新技能配置"
git push
```

### 在其他电脑上拉取更新

```bash
cd ~/.claude/skills
git pull
```

## 📝 添加新技能

1. 将新技能文件夹放入 `~/.claude/skills/` 目录
2. 提交并推送到 GitHub

```bash
cd ~/.claude/skills
git add .
git commit -m "添加新技能: 技能名称"
git push
```

## ⚠️ 注意事项

- 本仓库建议设为**私有**，以保护自定义配置和敏感信息
- `.gitignore` 已配置忽略敏感文件（.env, secrets/ 等）
- 如果技能包含数据库配置或 API 密钥，请勿提交到 Git

## 📚 相关文档

- [Claude Code 官方文档](https://github.com/anthropics/claude-code)
- [技能设计原理](./SKILL设计原理深度拆解.md)
- [中文说明](./README-中文说明.md)

---

最后更新: 2026-02-14
