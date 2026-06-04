# Setup and Permissions

## What gets packaged

Package only:

- `SKILL.md`
- `scripts/feishu-minutes-picker.ps1`
- `scripts/package-meeting-deliverable.ps1`
- `scripts/batch-feishu-minutes.ps1`
- this reference file
- `references/end-to-end-deliverable-workflow.md`
- `references/limits-and-batch-mode.md`

Do not package:

- Feishu access tokens
- app secrets
- cookies
- local lark-cli profile files
- downloaded meeting audio or transcript outputs unless the user explicitly wants to share those files

## Per-user setup

Each teammate must use their own Feishu identity.

Windows recommended setup:

```powershell
npx @larksuite/cli@latest install
lark-cli config init --new
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
```

macOS recommended setup:

```bash
brew install --cask powershell
brew install ffmpeg
npx @larksuite/cli@latest install
lark-cli config init --new
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
```

If `npx` is not available, install Node.js LTS first, then rerun the install command.

If meeting recordings download as video and users want MP3 audio-only output, install `ffmpeg` and make sure `ffmpeg -version` works in PowerShell.

The bundled script can print the first-use setup commands:

```powershell
.\scripts\feishu-minutes-picker.ps1 -SetupHelp
```

If the CLI prints a verification URL, open it in the browser and complete authorization. In agent workflows, prefer:

```powershell
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export" --no-wait --json
```

Then show the verification URL and QR code to the user. After they confirm authorization:

```powershell
lark-cli auth login --device-code <device_code>
```

## Install location

Codex local skill location:

```text
%USERPROFILE%\.codex\skills\feishu-minutes-transcript
```

macOS Codex local skill location:

```text
~/.codex/skills/feishu-minutes-transcript
```

Claude Code skill support depends on the user's environment. If enabled, place this folder in the configured skills directory. If skill discovery is not available, keep the folder in the project and ask the agent to use the `SKILL.md` file directly.

## Test command

Run a short range first:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Start 2026-06-04 -End 2026-06-04 -Scope owner -Select 1 -DownloadAudio -Overwrite
```

Default list-only smoke test:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Scope both -ListOnly
```

This defaults to the latest 30 days.

One-day list test:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Date 2026-06-04 -Scope both -ListOnly
```

Keyword and CSV list test:

```powershell
.\scripts\feishu-minutes-picker.ps1 -Query "月报" -Scope both -ListOnly -ListCsv outputs\feishu-minutes-list.csv
```

Direct URL test:

```powershell
.\scripts\feishu-minutes-picker.ps1 -MinuteUrl "https://example.feishu.cn/minutes/obcn_example_token" -Overwrite
```

Expected result:

- A numbered list of minutes appears.
- A transcript folder is created under `outputs\feishu-minutes-selected`.
- An `audio` folder is created when `-DownloadAudio` is used.
- Friendly named copies are created under `outputs\feishu-minutes-selected\exports` unless disabled with `-FriendlyNames:$false`.

## Common failures

Missing scope:

```text
missing required scope(s)
```

Fix by granting the listed scope through `lark-cli auth login --scope "<scope names>"`.

No minutes found:

- Expand the date range.
- Try `-Scope both`.
- Confirm the current Feishu user has access to the minute.

Output path rejected:

- Use a relative `-OutputDir`, not an absolute path.
- Run the command from the intended project directory.
