param(
  [string]$SkillDir = "$env:USERPROFILE\.codex\skills",
  [string]$RepoZipUrl = "https://codeload.github.com/liutao96/skill/zip/refs/heads/main",
  [switch]$SkipDependencySetup,
  [switch]$SkipFeishuAuth,
  [switch]$NoRestartReminder
)

$ErrorActionPreference = "Stop"

$RequiredScopes = "minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"

function Refresh-CurrentPath {
  $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = @($machinePath, $userPath) -join ";"
}

function Test-HasCommand {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WithWinget {
  param(
    [string]$CommandName,
    [string]$PackageId,
    [string]$DisplayName
  )

  if (Test-HasCommand $CommandName) {
    Write-Host "$DisplayName is already installed."
    return $true
  }

  if (-not (Test-HasCommand "winget")) {
    Write-Host "winget was not found. Install $DisplayName manually, then rerun this installer."
    return $false
  }

  Write-Host "Installing $DisplayName with winget..."
  & winget install --id $PackageId --exact --source winget --accept-source-agreements --accept-package-agreements
  Refresh-CurrentPath

  if (Test-HasCommand $CommandName) {
    Write-Host "$DisplayName installed."
    return $true
  }

  Write-Host "$DisplayName install command finished, but $CommandName is still not in PATH. Close and reopen PowerShell, then rerun this installer."
  return $false
}

function Complete-DependencySetup {
  $ok = $true

  if (-not (Test-HasCommand "npx")) {
    $ok = (Install-WithWinget -CommandName "npx" -PackageId "OpenJS.NodeJS.LTS" -DisplayName "Node.js LTS") -and $ok
  } else {
    Write-Host "Node.js/npx is already installed."
  }

  if (-not (Test-HasCommand "lark-cli")) {
    if (-not (Test-HasCommand "npx")) {
      Write-Host "Cannot install lark-cli because npx is still missing."
      $ok = $false
    } else {
      Write-Host "Installing lark-cli..."
      & npx @larksuite/cli@latest install
      Refresh-CurrentPath
      if (Test-HasCommand "lark-cli") {
        Write-Host "lark-cli installed."
      } else {
        Write-Host "lark-cli install command finished, but lark-cli is still not in PATH. Close and reopen PowerShell, then rerun this installer."
        $ok = $false
      }
    }
  } else {
    Write-Host "lark-cli is already installed."
  }

  if (-not (Test-HasCommand "ffmpeg")) {
    $ok = (Install-WithWinget -CommandName "ffmpeg" -PackageId "Gyan.FFmpeg" -DisplayName "ffmpeg") -and $ok
  } else {
    Write-Host "ffmpeg is already installed."
  }

  if (-not $ok) {
    throw "Some dependencies are still missing. Fix the messages above, then rerun this installer before restarting Codex."
  }
}

function Complete-FeishuAuth {
  if (-not (Test-HasCommand "lark-cli")) {
    throw "lark-cli is missing, so Feishu authorization cannot start."
  }

  Write-Host ""
  Write-Host "Checking lark-cli configuration..."
  & lark-cli auth status *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "lark-cli is not configured yet. Complete the browser/app setup that opens next."
    & lark-cli config init --new
    if ($LASTEXITCODE -ne 0) {
      throw "lark-cli config init did not complete."
    }
  } else {
    Write-Host "lark-cli already has an auth profile."
  }

  Write-Host ""
  Write-Host "Starting Feishu authorization. Complete it with your own Feishu account in the browser."
  & lark-cli auth login --scope $RequiredScopes
  if ($LASTEXITCODE -ne 0) {
    throw "Feishu authorization did not complete."
  }

  Write-Host ""
  Write-Host "Verifying lark-cli..."
  & lark-cli doctor
  if ($LASTEXITCODE -ne 0) {
    throw "lark-cli doctor failed."
  }
  & lark-cli auth status
  if ($LASTEXITCODE -ne 0) {
    throw "lark-cli auth status failed."
  }
}

function Find-LocalSkillSource {
  $repoRoot = $PSScriptRoot
  if ([string]::IsNullOrWhiteSpace($repoRoot)) {
    return $null
  }
  $candidate = Join-Path $repoRoot "feishu-minutes-transcript"
  if (Test-Path (Join-Path $candidate "SKILL.md")) {
    return $candidate
  }
  return $null
}

function Download-SkillSource {
  param([string]$Url)

  $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("feishu-minutes-skill-" + [System.Guid]::NewGuid().ToString("N"))
  $zipPath = Join-Path $tempRoot "repo.zip"
  $extractDir = Join-Path $tempRoot "repo"
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

  Write-Host "Downloading feishu-minutes-transcript from GitHub..."
  Invoke-WebRequest -Uri $Url -OutFile $zipPath -UseBasicParsing
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

  $source = Get-ChildItem -LiteralPath $extractDir -Directory -Recurse |
    Where-Object { $_.Name -eq "feishu-minutes-transcript" -and (Test-Path (Join-Path $_.FullName "SKILL.md")) } |
    Select-Object -First 1

  if (-not $source) {
    throw "Cannot find feishu-minutes-transcript/SKILL.md in downloaded repository."
  }

  return [pscustomobject]@{
    Source = $source.FullName
    TempRoot = $tempRoot
  }
}

function Get-InstalledSkillVersion {
  param([string]$InstalledSkillDir)

  $skillFile = Join-Path $InstalledSkillDir "SKILL.md"
  if (-not (Test-Path $skillFile)) {
    return "unknown"
  }
  $match = Select-String -LiteralPath $skillFile -Pattern "^version:\s*(.+)$" | Select-Object -First 1
  if ($match) {
    return $match.Matches[0].Groups[1].Value.Trim()
  }
  return "unknown"
}

$download = $null
$source = Find-LocalSkillSource
if (-not $source) {
  $download = Download-SkillSource -Url $RepoZipUrl
  $source = $download.Source
}

$target = Join-Path $SkillDir "feishu-minutes-transcript"

try {
  if (-not (Test-Path $SkillDir)) {
    New-Item -ItemType Directory -Path $SkillDir | Out-Null
  }

  $wasInstalled = Test-Path $target
  if ($wasInstalled) {
    Remove-Item -LiteralPath $target -Recurse -Force
  }

  Copy-Item -LiteralPath $source -Destination $target -Recurse

  $installedVersion = Get-InstalledSkillVersion -InstalledSkillDir $target
  if ($wasInstalled) {
    Write-Host "Updated only this skill:"
  } else {
    Write-Host "Installed only this skill:"
  }
  Write-Host $target
  Write-Host "Version: $installedVersion"
  Write-Host ""

  if (-not $SkipDependencySetup) {
    Complete-DependencySetup
  } else {
    Write-Host "Dependency setup skipped by -SkipDependencySetup."
  }

  if (-not $SkipFeishuAuth) {
    Complete-FeishuAuth
  } else {
    Write-Host "Feishu authorization skipped by -SkipFeishuAuth."
  }

  Write-Host ""
  if ($SkipDependencySetup -or $SkipFeishuAuth) {
    Write-Host "Skill installation is complete, but dependency setup or Feishu authorization was skipped."
    Write-Host "Complete the skipped steps before restarting Codex or Claude Code."
  } else {
    Write-Host "Installation, dependencies, and Feishu authorization are complete."
    Write-Host "Now restart Codex or Claude Code so it reloads this skill."
  }
  Write-Host ""
  Write-Host "Installed skill path:"
  Write-Host $target
  Write-Host "Version: $installedVersion"

  if (-not $NoRestartReminder) {
    Write-Host ""
    Write-Host "This installer does not install any other skills."
    Write-Host "To update an existing installation later, rerun this same one-command installer."
  }
} finally {
  if ($download -and (Test-Path $download.TempRoot)) {
    Remove-Item -LiteralPath $download.TempRoot -Recurse -Force
  }
}
