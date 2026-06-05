# Setup and Permissions

## What gets packaged

Package only:

- `SKILL.md`
- `scripts/feishu-minutes-picker.ps1`
- `scripts/package-meeting-deliverable.ps1`
- `scripts/batch-feishu-minutes.ps1`
- `scripts/install-this-skill.ps1`
- `scripts/install-this-skill.sh`
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

The Skill itself is cross-platform. The external tools are not bundled inside the Skill:

- `lark-cli` is required to access Feishu Minutes.
- `ffmpeg` is required only when converting downloaded media to MP3.
- PowerShell is required to run the bundled `.ps1` scripts; Windows usually has PowerShell, while macOS should install PowerShell 7.

If a user already has `lark-cli` installed, do not ask them to install it again. Run `lark-cli auth status` and grant missing scopes only when needed.

Windows recommended setup:

```powershell
# Run only if lark-cli is not already installed:
npx @larksuite/cli@latest install

# First-time configuration or when switching Feishu app/profile:
lark-cli config init --new

# Grant or refresh required scopes:
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
```

macOS recommended setup:

```bash
brew install --cask powershell
brew install ffmpeg

# Run only if lark-cli is not already installed:
npx @larksuite/cli@latest install

# First-time configuration or when switching Feishu app/profile:
lark-cli config init --new

# Grant or refresh required scopes:
lark-cli auth login --scope "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
```

If `npx` is not available, install Node.js LTS first, then rerun the install command.

If meeting recordings download as video and users want MP3 audio-only output, install `ffmpeg` and make sure `ffmpeg -version` works in PowerShell.

The bundled script can print the first-use setup commands:

```powershell
.\scripts\feishu-minutes-picker.ps1 -SetupHelp
```

`-SetupHelp` checks whether `npx`, `lark-cli`, `ffmpeg`, and `pwsh` are already available. It should tell the user to install only the missing tools.

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

## Install this skill only

If the user has only the `feishu-minutes-transcript` folder, run the installer inside this skill folder.

Windows:

```powershell
.\scripts\install-this-skill.ps1
```

macOS:

```bash
chmod +x ./scripts/install-this-skill.sh
./scripts/install-this-skill.sh
```

These installers copy only the `feishu-minutes-transcript` folder. They do not install any other skills from the repository.

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
