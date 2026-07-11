---
name: douyin-video-post-review
description: Use when Liu Tao asks to review Douyin/TikTok-style short-video performance after publishing, especially Creator Center screenshots, exported Excel/CSV tables, single or multiple video files, titles, hashtags, posting time, analysis time, AI music videos, AI women's-clothing videos, cart/no-cart videos, enterprise-account signals, 巨量引擎/千川/随心推辅助数据, or asks what to change in the next video and how to record the result back into the local SOP.
---

# Douyin Video Post Review

## Core Boundary

Use this skill for post-publish review and correction. The goal is not to write a generic data summary; the goal is to decide what the next published video should change and preserve that decision in Liu Tao's local review records.

Do not use this skill as the main workflow for:

- Product selection or product-card creation.
- Image generation or video generation.
- Pre-publish editing, music selection, cover-frame packaging, or publishing operations.
- Full paid-traffic account diagnosis.

Route those to the existing project SOPs or a separate publishing skill. This skill may still mention pre-publish fixes when the post-publish data proves the next video needs them.

## Required Workflow

1. Identify the content track:
   - AI music, no cart.
   - AI women's clothing, no cart yet.
   - AI women's clothing with cart.
   - Enterprise-account or paid-traffic assisted video.
2. Normalize the time basis:
   - Posting time.
   - Analysis time, screenshot time, file modified time, or user-provided cutoff.
   - Elapsed time from posting to analysis.
   - Data window: yesterday, last 7 days, last 30 days, custom publish-time range, or unknown.
3. Inspect available inputs:
   - Creator Center screenshots.
   - Exported Excel/CSV tables.
   - One video or multiple videos.
   - Title, hashtags, blue words, cover frame, hook, voiceover, cart status, traffic/spend data.
4. Read the relevant local SOP references before changing any SOP logic:
   - `references/sop-routing.md` for where this review fits.
   - `references/review-framework.md` for metric diagnosis and correction rules.
   - `references/output-template.md` for the final review format and record format.
5. Produce a correction-first review:
   - What happened.
   - Whether the result is normal for the elapsed time.
   - Which metric is abnormal.
   - What the likely cause is.
   - What the next video should change.
   - What should be recorded back into the product folder.

## Tooling

When the user provides exported tables or a folder of videos, prefer running:

```powershell
python "C:\Users\刘涛\Documents\Codex\liutao96-skill\douyin-video-post-review\scripts\prepare_review_inputs.py" --input "PATH"
```

The script creates a lightweight inventory of spreadsheets, screenshots, and videos. It does not make the final judgment; use it to reduce manual transcription.

## Output Rules

- Answer in Chinese and call the user Liu Tao / 刘涛.
- Lead with the decision: continue, change hook, change title/hashtags, change template, observe, pause, or do not invest traffic yet.
- Always state the time basis. If analysis time is inferred from a screenshot filename or file timestamp, say so.
- Never judge a video only by playback volume without elapsed time.
- If data is missing, continue with a partial review and list the missing data separately.
- For very weak videos, focus on correction. Avoid broad strategy unless the user asks.
- For women's clothing, preserve the existing SOP unless a change is explicitly needed. If suggesting an SOP change, label it as an SOP change and explain why.
- For paid traffic or cart data, separate natural-content signals from paid-traffic signals.
- When updating records, write into the product's `素材/09_发布记录与复盘/` folder when the product directory is known.
