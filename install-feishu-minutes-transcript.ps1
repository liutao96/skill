param(
  [string]$SkillDir = "$env:USERPROFILE\.codex\skills",
  [switch]$NoRestartReminder
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $repoRoot "feishu-minutes-transcript"
$target = Join-Path $SkillDir "feishu-minutes-transcript"

if (-not (Test-Path (Join-Path $source "SKILL.md"))) {
  throw "Cannot find feishu-minutes-transcript\SKILL.md next to this installer."
}

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
Write-Host "2. Run the first-use helper:"
Write-Host "   $target\scripts\feishu-minutes-picker.ps1 -SetupHelp"

if (-not $NoRestartReminder) {
  Write-Host ""
  Write-Host "This installer does not install any other skills."
}
