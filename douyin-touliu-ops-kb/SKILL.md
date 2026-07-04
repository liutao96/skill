---
name: douyin-touliu-ops-kb
description: Use when Liu Tao asks about Douyin short-video commerce operations from the local course knowledge base, including account cold start, product selection, hooks and first 3 seconds, video or image-text publishing, product cart mounting, DOU+/抖加, 随心推, 巨量千川投流, ROI, ad plan diagnosis, material testing, daily operation review, or whether a course tactic is safe to execute. Use this skill to retrieve and ground answers in the local Douyin operations knowledge base before giving strategic or operational advice.
---

# 抖音投流运营知识库

## Core Rule

Use the local knowledge base as the evidence layer, then add operational judgment. Do not answer paid traffic, ROI, 千川, 随心推, 抖加, account cold start, or course-tactic questions from memory alone when the local knowledge base is available.

Default knowledge-base root on this machine:

`P:\projects-test\短视频带货项目\投流和流程运营教程\抖音运营知识库`

The search script is portable. It checks `DOUYIN_TOULIU_KB_ROOT`, the current project folder, parent folders near the script, and common removable-drive letters `P:`, `F:`, `E:`, `D:`, `G:`. Do not recreate the knowledge base unless the user asks.

## Answer Contract

When answering, separate these layers:

1. `课程原文/知识库依据`: what the course notes, Q&A cards, transcripts, or OCR say.
2. `运营判断`: how to apply it to Liu Tao's current account, product, budget, and publishing stage.
3. `风险与待核实`: what may be outdated, platform-rule-sensitive, or needs current backend verification.
4. `下一步动作`: concrete action, metric, stop-loss line, or review step.

For paid traffic, always mention that real spend decisions must consider product price, commission, refund risk, gross margin, account stage, and current backend rules.

## Retrieval Workflow

Start broad, then verify:

1. Read `references/kb-map.md` when you need the current directory map, content coverage, or risk rules.
2. Search with `scripts/search_douyin_kb.py "<query>" --limit 8`.
3. Prefer `05_日常运营问答库` and `04_主题索引` for quick operational answers.
4. Use `03_课程精华总结` for course-level reasoning and checklists.
5. Use `01_课程逐字稿` when the user asks for original wording or when the summary is ambiguous.
6. Use `02_画面OCR与截图` when the question depends on a backend button, screen operation, field name, or setting path.
7. Mention if no relevant local evidence was found, then answer from general judgment only if safe.

Useful command:

```powershell
python "C:\Users\刘涛\.codex\skills\douyin-touliu-ops-kb\scripts\search_douyin_kb.py" "随心推 测品 ROI" --limit 8
```

When the drive letter changes on another computer, set:

```powershell
[Environment]::SetEnvironmentVariable("DOUYIN_TOULIU_KB_ROOT", "F:\projects-test\短视频带货项目\投流和流程运营教程\抖音运营知识库", "User")
```

## Capability Map

Use this skill for:

- Account setup, positioning, tags, cold start, homepage optimization, fan growth.
- Product selection, benchmark accounts, product data, commission, pre-hot product observation.
- Short-video and image-text creation, opening hooks, first 3 seconds, publishing, cart mounting.
- DOU+/抖加 logic, low-quality fan risk, interaction, homepage visit, targeting,追投.
- 随心推 testing, manual bid, smart bid,续费追投, material removal, daily data review.
- 巨量千川 plan setup, ROI, cost control,放量, material upload, authorization, plan diagnosis.
- Review frameworks for spend, orders, GMV, ROI, estimated commission, refund risk, and content signal.

## Hard Boundaries

Treat these as high-risk and do not recommend direct execution:

- 搬运, 防搬运, 炸素材, 隐藏榜单, repeated low-effort remixing, non-original bulk publishing, unauthorized use of达人素材,肖像,品牌,商标.
- Any tactic that appears to bypass platform review, copyright, authorization, or account governance.

When these appear in course materials, explain them as historical course content or risk cases. Reframe execution toward authorized material, original template testing, and compliant creative variation.

## Currentness Rule

Douyin, DOU+, 巨量千川, 随心推, and Douyin e-commerce backend rules change. If the user asks for today's backend location, current policy, current API behavior, or current official rule, verify against current official sources or clearly say the local course may be stale.

## Installation Model

The GitHub copy contains only the lightweight skill. The real 6GB+ course videos, screenshots, transcripts, and summaries remain in the project folder or removable drive. If this skill is copied from GitHub to another computer, also make the project folder available locally and either keep the same relative project structure or set `DOUYIN_TOULIU_KB_ROOT`.

## Output Style

Answer Liu Tao in Chinese. Be direct and practical. For strategy questions, give a real judgment, not just a course summary. For execution questions, include a small checklist or next-step sequence.
