param(
  [string]$SkillDir = "$env:USERPROFILE\.codex\skills",
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
  return (Test-HasCommand $CommandName)
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
      $ok = (Test-HasCommand "lark-cli") -and $ok
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

$skillSource = Split-Path -Parent $PSScriptRoot
$skillName = Split-Path -Leaf $skillSource
$target = Join-Path $SkillDir $skillName

if (-not (Test-Path (Join-Path $skillSource "SKILL.md"))) {
  throw "Cannot find SKILL.md in the parent folder of this installer."
}

if ($skillName -ne "feishu-minutes-transcript") {
  throw "This installer only supports feishu-minutes-transcript, got: $skillName"
}

if (-not (Test-Path $SkillDir)) {
  New-Item -ItemType Directory -Path $SkillDir | Out-Null
}

$wasInstalled = Test-Path $target
if ($wasInstalled) {
  Remove-Item -LiteralPath $target -Recurse -Force
}

Copy-Item -LiteralPath $skillSource -Destination $target -Recurse

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

if (-not $NoRestartReminder) {
  Write-Host ""
  Write-Host "This installer does not install any other skills."
  Write-Host "To update an existing installation later, rerun this same installer."
}
