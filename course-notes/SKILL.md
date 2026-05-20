---
name: course-notes
description: 课程笔记整理与飞书沉淀工作流。Use when the user says trigger phrases such as "course-notes", "course-notes-skill", "课程笔记", "记课", "帮我记一下", "整理到笔记", "这张图记一下", "总结到课程笔记", or sends course screenshots, text, audio transcripts, short video notes, course outlines, prompts, parameters, or questions that should be summarized, classified, and optionally written into Feishu docs/wiki. Also use when designing or maintaining a course knowledge-base structure, module notes, lesson note templates, or a temporary inbox for later cleanup.
---

# Course Notes

## Core Goal

Help 刘涛 turn scattered course inputs into usable learning notes: quick capture during study, structured summaries after study, and clean Feishu knowledge-base organization when confirmed.

Default language: Chinese. Address the user as 刘涛.

## Operating Rules

- Start with goal calibration: identify whether the user wants advice, a draft summary, local notes, or Feishu write-back.
- Do not create, overwrite, delete, move, or share Feishu documents unless the user clearly asks for that action.
- For Feishu operations, use profile `personal-feishu-all` unless the user explicitly says otherwise.
- Treat course identity as part of the note context. Do not assume every future note belongs to the AIGC course.
- Keep raw input and structured notes conceptually separate. Raw input is what the user sent; structured notes are the cleaned learning output.
- If classification is uncertain, put content into `99_知识点收集箱` instead of forcing it into a module.
- Prefer a practical note over a beautiful note while the user is actively watching a lesson.
- Preserve reusable prompts, parameters, commands, URLs, and tool names exactly when possible.
- Avoid exposing secrets, cookies, private links, paid course material beyond the user's own note summary, or unnecessary verbatim long excerpts.

## Multi-Course Architecture

Use this generic structure for each course or book unless the user gives a different target:

```text
个人知识库 / 课程学习库
└─ {课程名称}｜学习总览
   ├─ 00_课程名称、原始目录与学习进度
   ├─ 01_{核心模块一}
   ├─ 02_{核心模块二}
   ├─ 03_{核心模块三}
   └─ 99_知识点收集箱
```

Design principle:

- Use a knowledge base or wiki as the container.
- Use docs as the actual note pages.
- Always preserve the original course/book name and original catalog/TOC in `00_课程名称、原始目录与学习进度` before or alongside module notes.
- When the user sends a course catalog screenshot or book table of contents, transcribe it in the original order and mark uncertain OCR items as `待复核`.
- Do not create one document per lesson at the beginning.
- Use one module document for several related lessons.
- Split a module only when it becomes too long to scan.

## Course Context Rules

Before summarizing or writing notes, identify the active course or book:

1. If the user names a course, use that course.
2. If the user says "这门课", "继续记课", or sends content that clearly matches the last active course, continue that course.
3. If multiple courses are possible, ask one short question: "这条内容归到哪门课？"
4. If the user starts a new course, propose a minimal module map before creating Feishu docs.

For each course or book, maintain:

- course title
- original catalog / table of contents in source order
- course source or platform when known
- module map
- current lesson
- Feishu target docs if already created
- unresolved inbox items

Do not mix notes from different courses in the same module document.

## Input Handling

### Text

Use text as the most reliable source. Extract:

- main conclusion
- steps
- prompts or parameters
- examples
- questions
- business application

### Screenshot or Long Image

Read the image in segments when it is long. Identify:

- title or lesson position
- visible steps
- prompts, parameters, UI settings
- warnings or teacher emphasis
- whether the image belongs to a known module

If OCR is partial, say which part is uncertain.

### Audio

If the user provides audio or a transcript, summarize from transcript when available. If no transcript tool is available, ask for transcript or a shorter audio segment instead of inventing details.

### Video

Do not ask for full lesson video by default. Recommend screenshots, copied subtitles, short clips, or the user's own spoken summary. If a short video is provided and can be inspected, summarize only what is visible/audible.

## Classification Rules

First classify by active course, then by that course's module map. If no module map exists yet, infer a temporary one from the course outline and confirm before creating docs.

For the current AIGC video course, use these module cues:

- `MJ 出图与提示词`: Midjourney, 提示词, 参数, 反推, 图片权重, 宽高比, 混沌值, 角色一致性.
- `AI 短视频工作流`: 爆款视频, 分镜, 山海经, 萌宠, 案例拆解, 后期剪辑, 视频生成流程.
- `自媒体运营与变现`: 账号定位, 流量, 平台推荐, 万粉账号, 平台奖励, 商单, 私域, 变现.
- `AI 短剧制作`: 剧本, 分镜, 角色一致性, 口型, 配音, 配乐, 合成, 短剧流程.
- `AI 商业项目案例`: 商业写真, 广告, 宣传片, 地产片, 展会视频, Sora, AI 影视, 虚拟歌手.
- `99_知识点收集箱`: unclear content, cross-module notes, follow-up questions, or content waiting for review.

For other courses, create a course-specific module map with 3-7 modules. Use simple names that match the course outline, not generic AI labels.

## Note Output Template

Use this compact shape while the user is learning:

```markdown
### 课程小节
模块：
小节：

### 一句话结论

### 核心步骤
1.
2.
3.

### 可复用提示词 / 参数

### 截图或案例说明

### 我的业务应用

### 疑问 / 待验证

### 课后动作
- [ ]
```

For detailed templates and examples, read `references/note-templates.md`.

## Feishu Write-Back Workflow

When the user asks to write into Feishu:

1. Confirm target: existing document, module document, or `99_知识点收集箱`.
2. Use `lark-doc`, `lark-wiki`, and `lark-shared` skills as needed.
3. Use `lark-cli --profile personal-feishu-all ...`.
4. If target docs do not exist, ask before creating them.
5. After writing, report:
   - document title
   - section title
   - what was added
   - any uncertain OCR or classification

Do not change sharing permissions unless the user explicitly requests it.

## Response Style

For advice-only requests, give the architecture and tradeoffs.

For capture requests, output:

```text
已整理：
- 归属模块：
- 写入建议：
- 摘要：
- 待确认：
```

For completed Feishu writes, output:

```text
已写入：
- 文档：
- 章节：
- 内容：
- 验证：
```

## Iteration Rule

When 刘涛 says this Skill should be optimized, update this skill only after identifying the concrete behavior to improve, such as classification, template fields, Feishu structure, or write-back workflow. Keep changes small and record only reusable rules.
