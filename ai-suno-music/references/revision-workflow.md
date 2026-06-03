# Revision And Review Workflow

## Diagnose By Layer

Map the user's feedback to the layer that should change:

| Feedback | Change |
|---|---|
| Intro too long | Style Prompt: add `vocals start immediately, no intro`; Lyrics: start with `[Hook]` |
| Lyrics unclear | Shorten Chinese lines; add `clear Mandarin pronunciation, articulate Chinese vocal` |
| Too slow | Add `fast-paced`, `tight cadence`, `bouncy beat`; reduce long lyric lines |
| Too childish | Remove nursery/children cues; add `cute but not childish` or a mature mood |
| Too much like a full song | Use short hook structure; remove slow singing/ballad cues |
| Ending weak | Rewrite only the hook ending and `[End]` |
| Voice wrong | Adjust vocal descriptors or use project-specific voice/persona guidance |
| Good direction but poor quality | Suggest another generation, Remaster, or local edit instead of full rewrite |
| Needs longer song | Use Extend or expand the hook into verse/chorus after the hook works |

## Revision Output

Return:

```text
问题判断：
保留：
修改：
新版 Style Prompt：
新版 Lyrics：
下一轮怎么生成：
```

Do not rewrite the whole piece if only one layer failed.

## Review Scoring

For short-video music, score or comment on:

```text
0-3 second hook
lyric clarity
editability
role or brand fit
repeatable comment point
mood fit
not stealing attention from visuals
publish / revise / stop
```

Use plain conclusions: `continue`, `revise hook`, `change visuals`, or `stop`.

## Version Record

If the user is building a repeatable workflow, suggest a compact record:

```text
date:
project/video:
event/theme:
Style Prompt:
Lyrics:
versions generated:
best version:
problem:
next change:
publishable:
rights check:
```