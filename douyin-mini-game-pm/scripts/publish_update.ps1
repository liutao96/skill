param(
  [string]$Message = "Update douyin mini game PM skill",
  [string]$RepoDir = "P:\projects-test\AIgame\.github-skill-repo",
  [string]$SkillName = "douyin-mini-game-pm",
  [string]$Remote = "origin",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$SkillDir = Resolve-Path (Join-Path $PSScriptRoot "..")

$RepoDir = Resolve-Path $RepoDir

Push-Location $RepoDir
try {
  if (-not (Test-Path ".git")) {
    throw "RepoDir is not a Git repository: $RepoDir"
  }

  $validate = Join-Path $env:USERPROFILE ".codex\skills\.system\skill-creator\scripts\quick_validate.py"
  if (Test-Path $validate) {
    $env:PYTHONUTF8 = "1"
    python $validate $SkillDir
  }

  $Target = Join-Path $RepoDir $SkillName
  if (Test-Path $Target) {
    Remove-Item -LiteralPath $Target -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path $Target | Out-Null
  Copy-Item -LiteralPath (Join-Path $SkillDir "*") -Destination $Target -Recurse -Force

  git status --short
  git add $SkillName
  git commit -m $Message
  git push $Remote $Branch
}
finally {
  Pop-Location
}
