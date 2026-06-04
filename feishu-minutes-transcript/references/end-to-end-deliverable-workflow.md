# End-to-End Deliverable Workflow

Use this workflow when the user wants one final deliverable from Feishu Minutes: transcript, MP3 audio, and a simple meeting note.

## Intent Intake

If the user provides a Feishu Minutes URL, use it directly.

If the user provides a date, use:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Date yyyy-mm-dd -Scope both -ListOnly
```

If the user provides a meeting name or topic, use:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Query "keyword" -Scope both -ListOnly
```

If the user provides no locator, list latest 30 days:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Scope both -ListOnly
```

Then ask the user to choose a number only if the target meeting cannot be inferred safely.

## Export Command

Use this as the default export command for a selected meeting URL or token:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "minutes-url" -OutputDir outputs\feishu-minutes-final -DownloadAudio -ExtractAudio -AudioFormat mp3 -Overwrite
```

For a selected list item, use:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Date yyyy-mm-dd -Scope both -Select 1 -OutputDir outputs\feishu-minutes-final -DownloadAudio -ExtractAudio -AudioFormat mp3 -Overwrite
```

The script creates human-friendly files in:

```text
<OutputDir>\exports
```

## Meeting Note Generation

Read the exported transcript `.txt` from `<OutputDir>\exports`.

Create a markdown file in the same folder with the same base name plus `-meeting-notes.md`.

After reading the transcript, choose a concise business-facing meeting theme. Do not rely only on the Feishu title, because many minutes are named like "video meeting" or "new recording". The theme should describe what the meeting was actually about, for example:

```text
AI月报模板口径确认
飞书妙记导出链路测试
抖店达人归属同步评审
```

Use this structure:

```markdown
# 会议纪要：<title>

## 基本信息
- 时间：
- 来源：
- 音频：
- 逐字稿：

## 一句话结论

## 主要讨论内容

## 已确定事项

## 待办事项

## 风险与需要确认

## 适合后续追踪的关键词
```

Keep the meeting note simple and action-oriented. Do not paste long transcript excerpts.

## Final Package

Package only the final handoff files:

- friendly `.txt` transcript
- friendly `.mp3` audio
- `*-meeting-notes.md`

Do not include raw mp4 video unless the user explicitly asks for video.
Do not include tokens, local auth files, cookies, app secrets, or lark-cli profiles.

Use `scripts\package-meeting-deliverable.ps1` to create a zip:

```powershell
.\scripts\package-meeting-deliverable.ps1 -ExportDir outputs\feishu-minutes-final\exports -MeetingTheme "AI月报模板口径确认"
```

The package script names the final zip and package contents from the transcript date plus the AI-chosen theme:

```text
yyyyMMdd-HHmm_AI月报模板口径确认_final-deliverable.zip
yyyyMMdd-HHmm_AI月报模板口径确认.txt
yyyyMMdd-HHmm_AI月报模板口径确认.mp3
yyyyMMdd-HHmm_AI月报模板口径确认-meeting-notes.md
```

Final reply should normally include only:

- the zip link
- a one-line note of what it contains
