param(
  [string]$SkillDir = (Split-Path -Parent $PSScriptRoot),
  [string]$RemoteSkillUrl = "https://api.github.com/repos/liutao96/skill/contents/feishu-minutes-transcript/SKILL.md?ref=main",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Get-VersionFromText {
  param([string]$Text)

  $match = [regex]::Match($Text, "(?m)^version:\s*(.+?)\s*$")
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }
  return "unknown"
}

function Compare-VersionText {
  param([string]$Left, [string]$Right)

  if ($Left -eq "unknown" -or $Right -eq "unknown") {
    return 0
  }

  $leftParts = @($Left -split "\." | ForEach-Object { [int]$_ })
  $rightParts = @($Right -split "\." | ForEach-Object { [int]$_ })
  $max = [Math]::Max($leftParts.Count, $rightParts.Count)

  for ($i = 0; $i -lt $max; $i++) {
    $l = if ($i -lt $leftParts.Count) { $leftParts[$i] } else { 0 }
    $r = if ($i -lt $rightParts.Count) { $rightParts[$i] } else { 0 }
    if ($l -lt $r) { return -1 }
    if ($l -gt $r) { return 1 }
  }
  return 0
}

$localSkillFile = Join-Path $SkillDir "SKILL.md"
$localVersion = "unknown"
$latestVersion = "unknown"
$updateAvailable = $false
$ok = $true
$message = ""

try {
  if (Test-Path $localSkillFile) {
    $localVersion = Get-VersionFromText -Text (Get-Content -LiteralPath $localSkillFile -Raw)
  }

  $separator = if ($RemoteSkillUrl.Contains("?")) { "&" } else { "?" }
  $cacheBustedUrl = $RemoteSkillUrl + $separator + "_=" + ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
  $remoteBody = (Invoke-WebRequest -Uri $cacheBustedUrl -UseBasicParsing).Content
  try {
    $remoteJson = $remoteBody | ConvertFrom-Json
    if ($remoteJson.content) {
      $remoteText = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($remoteJson.content -replace "\s", "")))
    } else {
      $remoteText = $remoteBody
    }
  } catch {
    $remoteText = $remoteBody
  }
  $latestVersion = Get-VersionFromText -Text $remoteText
  $updateAvailable = (Compare-VersionText -Left $localVersion -Right $latestVersion) -lt 0

  if ($updateAvailable) {
    $message = "A newer feishu-minutes-transcript version is available."
  } else {
    $message = "feishu-minutes-transcript is up to date."
  }
} catch {
  $ok = $false
  $message = "Version check failed: $($_.Exception.Message)"
}

$result = [pscustomobject]@{
  ok = $ok
  local_version = $localVersion
  latest_version = $latestVersion
  update_available = $updateAvailable
  message = $message
}

if ($Json) {
  $result | ConvertTo-Json -Depth 4
} else {
  Write-Host $message
  Write-Host "Local version:  $localVersion"
  Write-Host "Latest version: $latestVersion"
  if ($updateAvailable) {
    Write-Host "Ask the user whether to update now. If they agree, run the installer for them."
  }
}
