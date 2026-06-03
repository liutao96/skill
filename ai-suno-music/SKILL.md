---
name: ai-suno-music
description: Use when the user asks to create, revise, evaluate, troubleshoot, or learn about AI music workflows, Suno, lyrics, style prompts, song structure, BGM, short-video music, generated music iteration, version review, or music production prompts. The skill must adapt to the current project context instead of assuming a fixed persona or fixed project.
---

# AI Music Workflow

Use this skill for AI music work across projects. Do not assume one fixed identity such as pet music assistant. First infer the current project, then choose the smallest useful mode.

## Core Rule

Project context wins over the global skill.

Priority order:

```text
user's current request
-> current conversation context
-> project AGENTS.md
-> project music knowledge entry, if present
-> project character/content/product notes, if present
-> this global skill
-> ask one key question only if still blocked
```

If a project has its own music knowledge base, read its entry file before creating or answering. If no project context exists, use the generic references in this skill.

## Mode Selection

- **Creation mode**: User wants lyrics, Style Prompt, BGM, short-video music, a full song, or a music concept. Read `references/creation-workflow.md`.
- **Revision mode**: User has generated a result and wants changes such as shorter intro, clearer lyrics, stronger hook, different rhythm, better ending, or more consistent voice. Read `references/revision-workflow.md`.
- **Review mode**: User asks which version is better or whether something is publishable. Use the scoring rules in `references/revision-workflow.md`.
- **Learning mode**: User asks how Suno or an AI music concept works. Read `references/learning-assistant.md`.
- **Project discovery**: If project-specific context may matter, read `references/project-discovery.md`.
- **Core Suno reference**: For general prompt, lyrics, structure, and risk boundaries, read `references/suno-core.md`.

## Default Behavior

For creation tasks:

1. Calibrate the real target: full song, short-video hook, BGM, product background music, learning demo, or revision.
2. Use existing project context when possible. Do not force the user to repeat event, role, brand, product, or content rules if they are already in the project.
3. If context is insufficient but safe to proceed, make a reasonable minimal version and state the assumption.
4. Output copy-ready fields: `Style Prompt`, `Lyrics`, and the next generation or editing step.
5. Avoid imitating specific artists, songs, melodies, or protected works.

For learning tasks:

1. Answer in plain Chinese by default.
2. Explain the idea first, then give the practical workflow.
3. If the answer depends on current platform rules, say it must be checked against the latest official page.

For revision tasks:

1. Diagnose what changed: prompt, lyrics, structure, voice, arrangement, or post-processing.
2. Preserve what works. Do not rewrite everything unless the direction is wrong.
3. Return a revised copy-ready version and a short reason for each change.

## Project-Specific Data

Do not copy project-specific knowledge into this global skill. When a project provides a local knowledge base, treat it as the source of truth for that project.

Common local entry filenames:

```text
AGENTS.md
00_Suno音乐创作知识库/README_调用入口.md
Suno音乐创作知识库/README_调用入口.md
音乐知识库/README.md
```

If local rules exclude a source, such as low-quality transcripts or English bilingual courses, respect that exclusion.