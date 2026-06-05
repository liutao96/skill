param(
  [string]$SkillDir = "$env:USERPROFILE\.codex\skills",
  [switch]$NoRestartReminder
)

$ErrorActionPreference = "Stop"

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

if (Test-Path $target) {
  Remove-Item -LiteralPath $target -Recurse -Force
}

Copy-Item -LiteralPath $skillSource -Destination $target -Recurse

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
