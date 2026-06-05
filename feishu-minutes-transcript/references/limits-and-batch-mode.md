# Limits and Batch Mode

## Hard Limits

This skill cannot:

- bypass Feishu permissions or read minutes the current user cannot access;
- use Liu Tao's Feishu login, token, cookie, app secret, or local lark-cli profile for another user;
- get a Feishu transcript if the minute has no transcript or the user lacks transcript export permission;
- infer exact speaker identity when Feishu transcript only says generic speaker labels;
- guarantee audio extraction without `ffmpeg`;
- install all Lark/Feishu skills or unrelated skills;
- upload generated notes back to Feishu Docs unless a separate write workflow is added and the user authorizes it;
- produce a reliable final meeting note for many different meetings merged into one transcript.

When any of these limits is hit, explain the concrete blocker and the next action: grant scope, ask for access, install ffmpeg, or process one meeting at a time.

## Install Scope

Install only this skill folder:

```text
feishu-minutes-transcript
```

Do not run broad skill installers such as "install all lark skills" for this workflow. `lark-cli` is an external CLI dependency, not a skill bundle dependency.

The Skill does not include `lark-cli`, `ffmpeg`, Node.js, Homebrew, or PowerShell. These are local tools. If they are already installed, use them directly; if missing, install only the missing tool.

## Batch Mode

Batch mode is supported for discovery and export, but final notes should stay one meeting per deliverable package.

Recommended batch workflow:

1. List by date range or keyword.
2. Let the user select multiple numbers, for example `1,3,5`.
3. Export transcript and MP3 for all selected minutes.
4. For final deliverables, read and package each meeting separately.

Scripted batch export:

```powershell
.\scripts\batch-feishu-minutes.ps1 -MinuteUrls "url1,url2" -OutputDir outputs\feishu-minutes-batch -DownloadAudio -ExtractAudio -Overwrite
```

or:

```powershell
.\scripts\batch-feishu-minutes.ps1 -MinuteTokens "token1,token2" -OutputDir outputs\feishu-minutes-batch -DownloadAudio -ExtractAudio -Overwrite
```

Do not combine multiple unrelated meetings into one meeting note unless the user explicitly asks for a combined digest.

## macOS Notes

macOS users need:

- PowerShell 7 (`pwsh`) to run the bundled `.ps1` scripts;
- `lark-cli`;
- `ffmpeg` for MP3 conversion.

Typical setup:

```bash
brew install --cask powershell
brew install ffmpeg
npx @larksuite/cli@latest install
```

Skip any command for a tool that is already installed.

Then run scripts with `pwsh`, for example:

```bash
pwsh ./scripts/feishu-minutes-picker.ps1 -SetupHelp
```
