# Skill 设计原理深度拆解

> 从心理学、认知科学和提示工程角度分析为什么这些Skill有效

---

## 一、Skill的本质：给AI的"入职培训手册"

### 核心洞察

Skill 本质上是**程序性知识的外部化存储**。

Claude 拥有海量的陈述性知识（知道是什么），但缺乏特定领域的程序性知识（知道怎么做）。Skill 就是把"怎么做"写下来，让 Claude 在需要时"查阅手册"。

**类比**：
- 没有Skill的Claude = 聪明的新员工，什么都懂但不知道公司的具体流程
- 有Skill的Claude = 拿着SOP手册的专家，知道每一步该怎么做

---

## 二、为什么Skill有效：四大心理学/认知原理

### 1. 认知卸载 (Cognitive Offloading)

**原理**：将认知负担从工作记忆转移到外部存储

**在Skill中的体现**：
```
scripts/        → 不用每次重写代码，直接调用
references/     → 不用记住所有细节，需要时查阅
assets/         → 不用从零创建，有模板可用
```

**为什么有效**：Claude的上下文窗口有限（类似工作记忆），Skill通过外部文件扩展了"可用知识"。

### 2. 程序性脚手架 (Procedural Scaffolding)

**原理**：将复杂任务分解为可执行的步骤序列

**案例分析 - doc-coauthoring skill**：
```
阶段1: 上下文收集
  ├── 问元信息（类型、受众、影响）
  ├── 信息倾倒
  └── 澄清问题

阶段2: 精炼与结构化
  ├── 确定章节
  ├── 逐节头脑风暴
  ├── 用户筛选
  └── 迭代修改

阶段3: 读者测试
  └── 用新Claude验证
```

**为什么有效**：提供了清晰的"认知路径"，减少了AI在流程上的不确定性。

### 3. 角色锚定 (Role Anchoring)

**原理**：通过明确身份定位来约束和引导行为

**案例分析 - canvas-design skill**：
```markdown
"Create museum or magazine quality work"
"meticulously crafted, labored over with care"
"someone at the absolute top of their field"
```

**为什么有效**：
- 设定了高标准的参照锚点
- 激活了"专家模式"的行为模式
- 通过重复强调形成心理暗示

### 4. 渐进式披露 (Progressive Disclosure)

**原理**：只在需要时提供信息，避免认知过载

**Skill的三层加载机制**：
```
第1层: 元数据 (name + description)  → 始终在上下文 (~100词)
第2层: SKILL.md正文              → 触发时加载 (<5000词)
第3层: 附属资源 (scripts/references/) → 按需加载 (无限制)
```

**为什么有效**：
- 上下文窗口是稀缺资源
- 只加载相关信息，提高信噪比
- 类似人类的"需要时再学"策略

---

## 三、Skill的结构剖析

### 必需文件：SKILL.md

```yaml
---
name: skill-name                    # 技能名称
description: |                      # 触发描述（最重要！）
  做什么 + 什么时候用 + 触发关键词
---

# 正文内容（指令和指南）
```

### Frontmatter的设计要点

**description 字段是触发器**，决定了Skill何时被激活：

| 要素 | 示例 | 作用 |
|-----|------|-----|
| 功能描述 | "创建和编辑Word文档" | 说明能做什么 |
| 触发场景 | "当需要处理.docx文件时" | 说明何时触发 |
| 具体动作 | "(1)创建 (2)编辑 (3)修订" | 枚举具体用途 |

**好的description示例**：
```yaml
description: |
  Comprehensive spreadsheet creation, editing, and analysis
  with support for formulas, formatting, data analysis.
  When Claude needs to work with spreadsheets (.xlsx, .xlsm, .csv)
  for: (1) Creating new spreadsheets with formulas,
  (2) Reading or analyzing data, (3) Modifying existing files,
  (4) Data visualization, or (5) Recalculating formulas
```

### 可选资源的使用场景

| 目录 | 用途 | 何时使用 | 示例 |
|-----|------|---------|-----|
| `scripts/` | 可执行代码 | 重复性任务、需要精确性 | rotate_pdf.py, recalc.py |
| `references/` | 参考文档 | 领域知识、API文档、规范 | api_docs.md, schema.md |
| `assets/` | 输出资源 | 模板、字体、图标 | logo.png, template.html |

---

## 四、八个Skill的设计模式分类

### 模式A：工具型 (Tool-centric)

**代表**：docx, pdf, xlsx

**特征**：
- 围绕特定文件格式或工具
- 包含具体代码示例和脚本
- 强调"怎么做"的技术细节

**结构模式**：
```
skill/
├── SKILL.md          # 快速入门 + 常见操作
├── scripts/          # 可直接调用的工具脚本
└── references/       # 高级功能的详细文档
```

**设计要点**：
- 提供"开箱即用"的代码片段
- 覆盖80%常见场景
- 复杂功能分离到reference文件

---

### 模式B：流程型 (Workflow-centric)

**代表**：doc-coauthoring, skill-creator

**特征**：
- 定义多阶段工作流程
- 强调步骤顺序和转换条件
- 包含检查点和退出条件

**结构模式**：
```
阶段1 → 检查点 → 阶段2 → 检查点 → 阶段3
   ↓         ↓         ↓
 退出条件   退出条件   完成条件
```

**设计要点**：
- 每个阶段有明确的目标
- 定义"何时进入下一阶段"
- 允许用户跳过或调整流程

---

### 模式C：美学型 (Aesthetic-centric)

**代表**：frontend-design, canvas-design

**特征**：
- 强调创意方向和美学标准
- 使用"反例"来排除不想要的结果
- 重复强调质量标准

**关键技巧**：

```markdown
# 正面引导
"Create museum or magazine quality work"
"meticulously crafted"
"at the absolute top of their field"

# 反面排除
"NEVER use generic AI-generated aesthetics"
"Avoid overused font families (Inter, Roboto, Arial)"
"avoid generic 'AI slop' aesthetics"
```

**设计要点**：
- 设定极高的质量锚点
- 明确排除"AI味"的特征
- 提供具体的美学词汇和方向

---

### 模式D：构建型 (Builder-centric)

**代表**：mcp-builder, skill-creator

**特征**：
- 教如何创建某类产物
- 包含完整的项目结构指南
- 提供评估和验证机制

**结构模式**：
```
1. 研究和规划
2. 实现
3. 审查和测试
4. 评估
```

**设计要点**：
- 从"为什么"到"怎么做"
- 包含质量检查清单
- 提供迭代改进的指导

---

## 五、复刻Skill需要理解的核心要点

### 1. 理解"自由度"的概念

| 自由度 | 适用场景 | 表现形式 |
|-------|---------|---------|
| **高自由度** | 创意任务、多种方案都可行 | 文字描述、原则指导 |
| **中自由度** | 有最佳实践但允许变化 | 伪代码、带参数的模板 |
| **低自由度** | 易出错、必须精确 | 具体脚本、严格步骤 |

**设计原则**：
```
窄桥悬崖 → 低自由度（严格护栏）
开阔田野 → 高自由度（自由探索）
```

### 2. 理解"触发机制"

Skill的触发完全依赖 `description` 字段：

```yaml
# ❌ 太模糊，难以触发
description: "帮助处理文档"

# ✅ 具体明确，容易触发
description: |
  处理Word文档(.docx)，包括：
  (1) 创建新文档
  (2) 编辑现有文档
  (3) 添加修订痕迹
  (4) 提取文本内容
  当用户提到"Word"、"docx"、"文档编辑"时触发
```

### 3. 理解"上下文经济学"

```
上下文窗口 = 稀缺资源

原则：
- 只添加Claude不知道的信息
- 用简洁示例代替冗长解释
- 详细内容放到reference文件
- 质疑每一段："这值得占用token吗？"
```

### 4. 理解"角色强化"技巧

通过重复和强调来锚定行为：

```markdown
# canvas-design 中的角色强化示例

"meticulously crafted"           # 第1次强调
"labored over with care"         # 第2次强调
"product of countless hours"     # 第3次强调
"top of their field"             # 第4次强调
"master-level execution"         # 第5次强调

# 结果：Claude真的会表现得更"专业"
```

---

## 六、从零创建Skill的完整流程

### 步骤1：定义使用场景

回答这些问题：
```
- 这个Skill要解决什么问题？
- 用户会怎么描述这个需求？（触发词）
- 有哪些具体的使用案例？
- 没有这个Skill时，Claude会在哪里犯错？
```

### 步骤2：规划内容结构

```
1. 识别重复性工作 → scripts/
2. 识别需要查阅的知识 → references/
3. 识别需要复用的模板 → assets/
4. 剩下的核心流程 → SKILL.md
```

### 步骤3：编写SKILL.md

```yaml
---
name: my-skill
description: |
  [功能概述]
  [触发场景列表]
  [关键触发词]
---

# 标题

## 核心流程
[主要步骤]

## 关键指南
[必须遵循的原则]

## 资源引用
[何时查阅哪个文件]
```

### 步骤4：测试和迭代

```
1. 用真实任务测试
2. 观察哪里出错或不够好
3. 分析是缺少知识还是流程不清
4. 更新相应部分
5. 重复测试
```

---

## 七、实战模板：创建一个简单Skill

假设要创建一个"会议纪要"Skill：

```yaml
---
name: meeting-notes
description: |
  将会议录音或文字转写整理成结构化的会议纪要。
  当用户提到"会议纪要"、"整理会议"、"会议记录"、
  "meeting notes"时触发。支持：
  (1) 从录音转写整理
  (2) 从文字稿整理
  (3) 提取行动项和决策
---

# 会议纪要整理指南

## 输出格式

```markdown
# [会议主题]
日期：YYYY-MM-DD
参会人：[列表]

## 议题摘要
[3-5个要点]

## 讨论详情
### 议题1
- 讨论内容
- 结论

## 决策事项
- [ ] 决策1

## 行动项
| 负责人 | 任务 | 截止日期 |
|-------|-----|---------|
| @xxx  | xxx | YYYY-MM-DD |

## 下次会议
日期：
议题：
```

## 整理原则

1. **简洁**：删除寒暄、重复、跑题内容
2. **结构化**：按议题组织，不按时间流水
3. **可执行**：行动项必须有负责人和截止日
4. **中立**：只记录事实，不加入主观判断
```

---

## 八、总结：Skill设计的黄金法则

```
1. Description决定触发 → 写清楚、写具体
2. 上下文是稀缺资源 → 精简、分层加载
3. Claude已经很聪明 → 只补充它不知道的
4. 用示例代替解释 → Show, don't tell
5. 重复强化角色 → 设定高标准锚点
6. 定义清晰流程 → 减少不确定性
7. 提供护栏和检查点 → 在关键处约束
8. 持续迭代改进 → 从实际使用中学习
```
