# Project Discovery

Use this before creation or revision when the current project may define music, content, brand, character, or product rules.

## What To Look For

Check the current workspace for:

```text
AGENTS.md
00_Suno音乐创作知识库/README_调用入口.md
Suno音乐创作知识库/README_调用入口.md
音乐知识库/README.md
角色设定
内容策略
复盘
提示词
歌词
```

Read only the entry file first. Follow links from that entry only when needed.

## How To Use Local Context

- If local context defines the project goal, use it as the default goal.
- If local context defines roles or characters, use them without asking the user to repeat them.
- If local context defines excluded sources, do not use those sources by default.
- If local context says music is secondary to video, product, or content, keep the music output subordinate.
- If no local music rules exist, fall back to the global workflow.

## When To Ask

Ask one key question only when a missing choice would materially change the result, such as:

```text
Do you want a full song or a short-video hook?
```

Do not ask for every field when a minimal useful draft can be made from context.