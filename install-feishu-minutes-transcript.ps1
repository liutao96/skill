param(
  [string]$SkillDir = "$env:USERPROFILE\.codex\skills",
  [string]$RepoZipUrl = "https://codeload.github.com/liutao96/skill/zip/refs/heads/main",
  [switch]$NoRestartReminder
)

$ErrorActionPreference = "Stop"

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

  if (Test-Path $target) {
    Remove-Item -LiteralPath $target -Recurse -Force
  }

  Copy-Item -LiteralPath $source -Destination $target -Recurse

  Write-Host "Installed only this skill:"
  Write-Host $target
  Write-Host ""
  Write-Host "Next steps:"
  Write-Host "1. Restart Codex or Claude Code so it reloads skills."
  Write-Host "2. Run the setup checker:"
  Write-Host "   $target\scripts\feishu-minutes-picker.ps1 -SetupHelp"

  if (-not $NoRestartReminder) {
    Write-Host ""
    Write-Host "This installer does not install any other skills."
  }
} finally {
  if ($download -and (Test-Path $download.TempRoot)) {
    Remove-Item -LiteralPath $download.TempRoot -Recurse -Force
  }
}
