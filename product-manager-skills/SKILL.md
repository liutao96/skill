---
name: product-manager-skills
description: 46个经过实战测试的产品管理框架，训练AI代理像专业人士一样执行产品管理工作。包含PRD编写、优先级排序、客户发现、故事拆分等框架。
github_url: https://github.com/deanpeters/Product-Manager-Skills
github_hash: 1e8ff6247c02c9d77da03a823bb8c9da3ed00884
version: v0.5
created_at: 2026-03-05
entry_point: scripts/wrapper.py
dependencies: []
---

# Product Manager Skills

**Train AI agents to do product management work like a pro.**

Frame problems, hunt opportunities, scaffold validation experiments, and kill bad bets fast. With battle-tested frameworks from Teresa Torres, Geoffrey Moore, Amazon, MITRE, and much more from product management's greatest hits.

## 46 Ready-to-Use PM Frameworks

这些技能教授 AI 代理如何专业地执行产品管理工作，无需你每次都解释流程。

### 核心能力
- ✅ 如何构建 PRD（产品需求文档）
- ✅ 向利益相关者提问什么问题
- ✅ 使用哪种优先级框架（以及何时使用）
- ✅ 如何运行客户发现访谈
- ✅ 如何使用经过验证的模式拆分大型需求

## 技能类型

### Component Skills（组件型）
单一功能，可组合使用：
- `altitude-horizon-framework` - 海拔-视野框架（职业晋升核心思维模型）
- `finance-based-pricing-advisor` - 基于财务的定价顾问
- `tam-sam-som-calculator` - 市场规模计算器
- `user-story` - 用户故事模板

### Interactive Skills（交互型）
引导式对话，逐步 facilitation：
- `director-readiness-advisor` - 总监晋升准备顾问
- `vp-cpo-readiness-advisor` - VP/CPO 晋升准备顾问
- `workshop-facilitation` - 研讨会引导协议

### Workflow Skills（工作流型）
多步骤端到端流程：
- `executive-onboarding-playbook` - 高管入职手册（30-60-90天诊断）

## 使用方法

当需要产品管理相关的专业框架时，引用此技能。AI 代理将：

1. **识别合适的框架** - 根据你的场景选择最佳工具
2. **应用专业实践** - 使用 Teresa Torres、Geoffrey Moore 等人的成熟方法
3. **引导你完成流程** - 问正确的问题，提供结构化输出
4. **保持战略高度** - 专注于决策质量而非重复性工作

## 示例场景

```
"帮我写一个 PRD"
"使用连续发现框架验证这个机会"
"分析这个市场的 TAM/SAM/SOM"
"准备我的产品经理到总监的晋升"
"引导一个 OKR 规划研讨会"
```

## 本地测试（可选）

仓库包含 Streamlit 界面用于本地测试：

```bash
pip install -r app/requirements.txt
streamlit run app/main.py
```

## 资源链接

- **完整文档**: [Building PM Skills](https://github.com/deanpeters/Product-Manager-Skills/blob/main/docs/Building%20PM%20Skills.md)
- **添加技能工具**: `scripts/add-a-skill.sh`
- **搜索技能**: `scripts/find-a-skill.sh`
- **测试技能**: `scripts/test-a-skill.sh`

## 版权

CC BY-NC-SA 4.0 - 由 Dean Peters 创建

## 更新记录

- **v0.5 (Feb 27, 2026)** - Streamlit Beta + 职业领导力技能套件
- **v0.4 (Feb 10, 2026)** - 引导协议修复
- **v0.3** - 初始发布
