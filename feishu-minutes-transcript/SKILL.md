---
name: feishu-minutes-transcript
version: 2026.06.05.3
description: Use when the user wants to list Feishu/Lark Minutes, meeting recordings, meeting notes, or transcripts; choose which minutes to convert; download transcript text, AI artifacts, or audio files; batch process Feishu minutes through lark-cli; or package this workflow for teammates using Codex or Claude Code.
---

# Feishu Minutes Transcript

## Goal

Use this skill to turn Feishu Minutes into selectable local transcript and audio outputs:

```text
search minutes -> show numbered list -> user selects records -> export transcript -> optionally download audio
```

Do not scrape Feishu web pages. Use `lark-cli` and the current user's Feishu authorization.

## Requirements

- `lark-cli` is required for Feishu API access. The script treats it as a soft dependency: if it is missing, it prints first-use setup commands instead of failing silently.
- If `lark-cli` is already installed, do not reinstall it. Use the existing CLI and only grant missing Feishu scopes when needed.
- `ffmpeg` is needed only for MP3 extraction. If it is missing, explain that MP3 conversion requires installing ffmpeg on the current OS.
- Each user must authorize their own Feishu account. Do not reuse another person's token or app secret.
- Required transcript scopes:
  - `minutes:minutes:readonly`
  - `minutes:minutes.artifacts:read`
  - `minutes:minutes.transcript:export`
- Required media download scope:
  - `minutes:minutes.media:export`
- Search requires:
  - `minutes:minutes.search:read`

For setup and permission details, read `references/setup-and-permissions.md` only when installing, debugging auth, or sharing with teammates.

For one final handoff package containing transcript, MP3, and meeting notes, read `references/end-to-end-deliverable-workflow.md`.

For unsupported cases, install scope, batch mode, and macOS notes, read `references/limits-and-batch-mode.md`.

## Version Check

At the start of any real workflow, before listing or downloading minutes, run the bundled version check script from this skill folder:

```powershell
.\scripts\check-skill-version.ps1 -Json
```

If it reports `update_available: true`, tell the user in natural language that a newer version is available and ask whether to update now. Do not ask the user to copy commands. If the user agrees, run the GitHub installer for them, then tell them to restart Codex or Claude Code after the update finishes.

If version check fails because the network is unavailable, continue the user's current task and mention that update checking could not be completed.

This usage-time update prompt exists only in version `2026.06.05.3` and later. Older installed copies need one update first.

## Quick Start

Show first-use setup commands:

```powershell
.\scripts\feishu-minutes-picker.ps1 -SetupHelp
```

Run the bundled script from the skill folder or copy it into the working project. By default, the script lists the latest 30 days when no date arguments are provided:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Scope both -ListOnly
```

List one exact day:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Date 2026-06-04 -Scope both -ListOnly
```

List a custom date range:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Start 2026-05-04 -End 2026-06-04 -Scope both -ListOnly
```

Search by keyword and export the list to CSV:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Query "月报" -Scope both -ListOnly -ListCsv outputs\feishu-minutes-list.csv
```

Convert a Feishu Minutes URL directly:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -DownloadAudio
```

If Feishu downloads a meeting recording as video, extract an audio-only MP3 file:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -DownloadAudio -ExtractAudio
```

Use M4A only when the user explicitly wants to preserve the original AAC audio stream without transcoding:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -DownloadAudio -ExtractAudio -AudioFormat m4a
```

The script lists matching minutes, then accepts:

```text
1
1,3,5
1-4
all
```

By default, the script keeps the raw lark-cli output and also creates friendly named files under `<OutputDir>\exports`, using:

```text
yyyyMMdd-HHmm_meeting-title_token-prefix.txt
yyyyMMdd-HHmm_meeting-title_token-prefix.mp3
```

Disable friendly copies only when preserving the raw lark-cli layout matters:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -DownloadAudio -ExtractAudio -FriendlyNames:$false
```

Use non-interactive selection when the user already knows what to process:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Start 2026-06-04 -End 2026-06-04 -Scope owner -Select 1 -DownloadAudio -Overwrite
```

## Workflow

1. Calibrate the user's intent:
   - If they want to find available meetings, search minutes first.
   - If they already gave a Feishu Minutes URL, extract the token from `/minutes/<minute_token>`.
   - If they ask for one day, use `-Date yyyy-mm-dd`.
   - If they ask for recent records without dates, use the script default latest 30 days.
   - If they ask for a topic, title, or keyword, add `-Query`.
   - If they ask for full transcript text, use transcript export.
   - If they ask for recording/audio, use media download.
   - If the downloaded media is video but the user wants audio, add `-ExtractAudio`; default output is `.mp3`.
2. Prefer read-only discovery before downloading large files.
3. Use the script for selectable or batch workflows.
4. Save outputs to a workspace-local directory unless the user names another safe target.
5. Prefer the friendly named files in `<OutputDir>\exports` for handoff to humans.
6. Never print tokens, app secrets, cookies, or credentials.
7. Never install unrelated skills. This workflow installs only `feishu-minutes-transcript`.

## One Final Deliverable

When the user asks to "call/use this skill", "give me the final result only", "export transcript and MP3", "make meeting notes", or similar, use the end-to-end workflow:

1. If a Feishu Minutes URL is provided, export it directly.
2. If a date, keyword, or meeting name is provided, list matching minutes and choose only when the target is clear.
3. If no locator is provided, list latest 30 days and ask for one selection.
4. Export transcript and MP3:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "minutes-url" -OutputDir outputs\feishu-minutes-final -DownloadAudio -ExtractAudio -AudioFormat mp3 -Overwrite
```

5. Read the friendly transcript from `<OutputDir>\exports`.
6. Decide the final business-facing meeting theme from the transcript content, not only from the Feishu title.
7. Create a simple `*-meeting-notes.md` in the same exports folder.
8. Package the final files with the transcript date plus the AI-chosen theme:

```powershell
.\scripts\package-meeting-deliverable.ps1 -ExportDir outputs\feishu-minutes-final\exports -MeetingTheme "meeting-theme"
```

9. Final reply should prefer one zip link and a short contents note, not a long process log.

For multiple selected meetings, create one final ZIP per meeting unless the user explicitly requests a combined digest.

Batch export by token or URL is available:

```powershell
.\scripts\batch-feishu-minutes.ps1 -MinuteUrls "url1,url2" -OutputDir outputs\feishu-minutes-batch -DownloadAudio -ExtractAudio -Overwrite
```

This creates one output folder per meeting. Generate final meeting notes and final ZIPs one meeting at a time.

## Direct Commands

Search owned minutes:

```powershell
lark-cli minutes +search --owner-ids me --start 2026-06-01 --end 2026-06-04 --page-size 200 --format json
```

Search participated minutes:

```powershell
lark-cli minutes +search --participant-ids me --start 2026-06-01 --end 2026-06-04 --page-size 200 --format json
```

Export transcript and artifacts by minute token:

```powershell
lark-cli vc +notes --minute-tokens obcn_example_token --output-dir outputs\feishu-minutes --format json
```

Download audio or video:

```powershell
lark-cli minutes +download --minute-tokens obcn_example_token --output-dir outputs\feishu-minutes\audio --format json
```

Extract audio from a downloaded video manually:

```powershell
ffmpeg -y -i input.mp4 -vn -c:a copy output.m4a
```

## Sharing With Teammates

Give teammates the one-command installer. It should be run in a normal terminal first, before restarting Codex or Claude Code.

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/liutao96/skill/main/install-feishu-minutes-transcript.ps1 | iex
```

macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/liutao96/skill/main/install-feishu-minutes-transcript.sh | bash
```

The installer flow is:

```text
install only this Skill -> install missing tools -> complete Feishu authorization -> restart Codex/Claude Code
```

If the Skill is already installed, rerun the same one-command installer to update it. The installer replaces only `feishu-minutes-transcript`, keeps the user's own Feishu authorization in `lark-cli`, and prints the installed version.

Package this skill folder manually only when GitHub access is unavailable. Use these rules:

1. Install only this skill folder, not unrelated skill bundles.
2. Install `lark-cli` locally, or run `.\scripts\feishu-minutes-picker.ps1 -SetupHelp` to see commands.
3. Configure their own Feishu app/profile if not already configured.
4. Place this folder into their skills directory, for example:
   - Codex: `%USERPROFILE%\.codex\skills\feishu-minutes-transcript`
   - Claude Code: the user's configured skills directory, if enabled in their environment
5. Run Feishu authorization using their own account.
6. Restart Codex or Claude Code after Skill install, dependencies, and Feishu authorization are complete.
7. Test with a short minute before processing long meetings.

The skill does not include Feishu credentials. That is intentional and required for security.

If only this skill folder was downloaded, install it with:

```powershell
.\scripts\install-this-skill.ps1
```

On macOS:

```bash
./scripts/install-this-skill.sh
```

If installing directly from GitHub without cloning the repository, use the one-command installer above. These commands install only `feishu-minutes-transcript`; they do not install unrelated skills.

## First-Use Setup

The official lark-cli quick install command is:

```powershell
npx @larksuite/cli@latest install
```

Then configure and authorize:

```powershell
lark-cli config init --new
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
lark-cli doctor
lark-cli auth status
```

For MP3 audio extraction from video recordings, ensure `ffmpeg` is installed and available in `PATH`.

For macOS, install PowerShell 7 and run scripts with `pwsh`.

For AI-agent workflows, if a command prints a browser verification URL, show the URL and a QR code to the user, wait for authorization, then continue. Do not package local lark-cli profiles or credentials into the skill.

## Validation

After changes, test the script with a short date range and one known short minute:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Start 2026-06-04 -End 2026-06-04 -Scope owner -Select 1 -DownloadAudio -Overwrite
```

Test direct URL conversion:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -Overwrite
```

Confirm:

- The minutes list is shown.
- `-ListOnly` lists records without downloading anything.
- Default list mode uses the latest 30 days.
- `-Date` limits search to one day.
- `-Query` filters by keyword when Feishu search supports it.
- `-ListCsv` exports the displayed list for review.
- `-MinuteUrl` and `-MinuteTokens` skip list selection and export directly.
- The selected transcript is downloaded.
- Audio is downloaded when `-DownloadAudio` is set.
- Video recordings are converted to audio-only files when `-ExtractAudio` is set.
- Friendly named copies are created under `<OutputDir>\exports` unless `-FriendlyNames:$false` is set.
- `scripts\package-meeting-deliverable.ps1` packages `.txt`, `.mp3`, and `.md` handoff files into one zip.
- `scripts\batch-feishu-minutes.ps1` exports multiple minutes into separate folders.
- Missing scope errors are explained as permission setup issues, not treated as script bugs.
