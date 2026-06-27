# Women Clothing KB Layout

Default root:

`P:\projects-test\短视频带货项目\女装赛道\提示词和教程知识库`

Override:

`WOMEN_CLOTHING_KB_ROOT`

## Core Files

- `AGENTS.md`: local invocation rules and required read order.
- `00_女装提示词知识库/01_知识库总览.md`: current module overview.
- `00_女装提示词知识库/10_完整案例库/cases.jsonl`: structured Excel/docx/doc prompt records.
- `00_女装提示词知识库/13_飞书Base案例库/feishu_base_cases.jsonl`: Feishu Base records and attachment paths.
- `00_女装提示词知识库/15_独立图片视觉库/independent_images.json`: manually described standalone images.
- `00_女装提示词知识库/16_多媒体资产调用索引/media_assets.jsonl`: unified asset index.
- `00_女装提示词知识库/11_视频课程库/transcripts/`: local video transcripts.
- `00_女装提示词知识库/14_知识库完整性审计报告.md`: completeness audit.

## Current Expected Counts

- Source files: 98
- Structured cases: 3845
- Prompt records: 3789
- Extracted case images: 5199
- Feishu Base records: 1066
- Feishu Base attachments: 1699
- Videos: 23
- Video transcripts: 23
- Video frames: 146
- Media asset records: 7073
- Completeness gaps: 0

If these counts drift, re-run the project tools in the knowledge base:

```powershell
python tools\build_case_library.py
python tools\build_video_knowledge.py
python tools\build_media_asset_index.py
python tools\audit_knowledge_completeness.py
```

## Cross-Computer Setup

The skill should be synced through GitHub. The large knowledge base should stay on the removable drive.

On another computer:

1. Clone or copy this skill into that machine's Codex skills directory.
2. Mount the removable drive containing `提示词和教程知识库`.
3. Set `WOMEN_CLOTHING_KB_ROOT` if the drive letter is not `P:`.
4. Run `python scripts/search_women_kb.py --task audit` to verify the path and counts.
