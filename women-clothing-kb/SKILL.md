---
name: women-clothing-kb
description: Use when Liu Tao needs to query or generate from the local women's clothing short-video commerce knowledge base on a removable drive, including female fashion image prompts, video motion prompts, Doubao editing prompts, Feishu Base cases, source-file completeness checks, local media assets, video transcripts, and prompt examples for Douyin/TikTok-style clothing sales content.
---

# Women Clothing Knowledge Base

Use this skill to query Liu Tao's women's clothing short-video commerce knowledge base. The real corpus lives on the removable drive; this skill contains only routing rules and lightweight search tooling.

## Quick Workflow

1. Locate the knowledge base root.
   - Prefer `WOMEN_CLOTHING_KB_ROOT` when set.
   - Otherwise use `scripts/search_women_kb.py`, which checks common removable-drive paths.
2. Read the local rules first:
   - `AGENTS.md`
   - `00_女装提示词知识库/01_知识库总览.md`
   - `00_女装提示词知识库/14_知识库完整性审计报告.md` when completeness matters.
3. For prompt generation, query source-backed records instead of relying on summaries.
   - Image / graphic prompts: `10_完整案例库/cases.jsonl`, then `13_飞书Base案例库/feishu_base_cases.jsonl`.
   - Video motion prompts: query `cases.jsonl` for `视频动态提示词`, `视频提示词`, `生视频`, `动图&实况图`, `运镜`, `镜头跟随`.
   - Operations / course guidance: `11_视频课程库/transcripts/`.
   - Source images, Base attachments, and video frames: `16_多媒体资产调用索引/media_assets.jsonl`.
4. When answering Liu Tao, include source paths and explain whether the answer comes from prompt records, Feishu Base, media assets, or video transcripts.

## Deterministic Search

Run the bundled script from any working directory:

```powershell
python C:\Users\刘涛\.codex\skills\women-clothing-kb\scripts\search_women_kb.py --task video-prompt --query "对镜自拍 展示上衣" --limit 8
```

Common tasks:

- `--task video-prompt`: find video motion prompt examples.
- `--task image-prompt`: find image prompt examples.
- `--task media`: find images, attachments, videos, and frames.
- `--task transcript`: search video course transcripts.
- `--task audit`: show completeness and asset counts.

If the removable drive path differs on another computer, set:

```powershell
$env:WOMEN_CLOTHING_KB_ROOT="P:\projects-test\短视频带货项目\女装赛道\提示词和教程知识库"
```

## Output Rules

- Do not claim "the knowledge base says" without naming the source file or module.
- For generated prompts, separate:
  - `参考来源`
  - `可直接复制的提示词`
  - `为什么这样写`
  - `风险/边界`
- For video prompts, prefer concise motion language: subject, camera movement, action sequence, clothing preservation, duration, aspect ratio, and negative constraints.
- Treat course transcripts as operational guidance. They were produced with a local tiny model, so verify important details against the source video when precision matters.
- Treat "搬运 / 去重 / 防搬 / 黑科技" materials as risk observation, not as the recommended operating line.

## References

Read `references/kb-layout.md` when you need exact file roles, path conventions, or cross-computer setup notes.
