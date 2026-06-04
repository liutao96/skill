param(
  [Parameter(Mandatory = $true)]
  [string]$ExportDir,
  [string]$MeetingDate,
  [string]$MeetingTheme,
  [string]$ZipPath
)

$ErrorActionPreference = "Stop"

function ConvertTo-SafeFileName {
  param([string]$Text)

  foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
    $Text = $Text.Replace([string]$char, "_")
  }
  $Text = ($Text -replace "\s+", " ").Trim()
  if ($Text.Length -gt 80) {
    $Text = $Text.Substring(0, 80).Trim()
  }
  if ([string]::IsNullOrWhiteSpace($Text)) {
    return "meeting"
  }
  return $Text
}

function Get-DateLabelFromTranscript {
  param([string]$TranscriptPath)

  if (Test-Path $TranscriptPath) {
    $firstLine = Get-Content -LiteralPath $TranscriptPath -TotalCount 1
    if ($firstLine -match "^(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})") {
      return "$($Matches[1])$($Matches[2])$($Matches[3])-$($Matches[4])$($Matches[5])"
    }
  }
  return (Get-Date).ToString("yyyyMMdd-HHmm")
}

if (-not (Test-Path $ExportDir)) {
  throw "ExportDir does not exist: $ExportDir"
}

$files = Get-ChildItem -LiteralPath $ExportDir -File | Where-Object {
  $_.Extension.ToLowerInvariant() -in @(".txt", ".mp3", ".md")
}

if ($files.Count -eq 0) {
  throw "No deliverable files found. Expected .txt, .mp3, or .md files in: $ExportDir"
}

$transcript = $files | Where-Object { $_.Extension.ToLowerInvariant() -eq ".txt" } | Select-Object -First 1
$mp3 = $files | Where-Object { $_.Extension.ToLowerInvariant() -eq ".mp3" } | Select-Object -First 1
$notes = $files | Where-Object { $_.Extension.ToLowerInvariant() -eq ".md" } | Select-Object -First 1

if ([string]::IsNullOrWhiteSpace($MeetingDate)) {
  if ($transcript) {
    $MeetingDate = Get-DateLabelFromTranscript -TranscriptPath $transcript.FullName
  } else {
    $MeetingDate = Get-Date -Format "yyyyMMdd-HHmm"
  }
}

if ([string]::IsNullOrWhiteSpace($MeetingTheme)) {
  if ($notes) {
    $firstHeading = Get-Content -LiteralPath $notes.FullName -TotalCount 10 | Where-Object { $_ -match "^#\s+" } | Select-Object -First 1
    if ($firstHeading) {
      $MeetingTheme = ($firstHeading -replace "^#\s*", "" -replace "^会议纪要[:：]\s*", "").Trim()
    }
  }
  if ([string]::IsNullOrWhiteSpace($MeetingTheme)) {
    $MeetingTheme = "meeting"
  }
}

$safeTheme = ConvertTo-SafeFileName -Text $MeetingTheme
$baseName = ConvertTo-SafeFileName -Text ("$MeetingDate" + "_" + "$safeTheme")

if ([string]::IsNullOrWhiteSpace($ZipPath)) {
  $ZipPath = Join-Path (Split-Path -Parent $ExportDir) ($baseName + "_final-deliverable.zip")
}

if (Test-Path $ZipPath) {
  Remove-Item -LiteralPath $ZipPath -Force
}

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("feishu-minutes-package-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
  if ($transcript) {
    Copy-Item -LiteralPath $transcript.FullName -Destination (Join-Path $tempDir ($baseName + ".txt")) -Force
  }
  if ($mp3) {
    Copy-Item -LiteralPath $mp3.FullName -Destination (Join-Path $tempDir ($baseName + ".mp3")) -Force
  }
  if ($notes) {
    Copy-Item -LiteralPath $notes.FullName -Destination (Join-Path $tempDir ($baseName + "-meeting-notes.md")) -Force
  }

  $otherFiles = $files | Where-Object {
    ($transcript -eq $null -or $_.FullName -ne $transcript.FullName) -and
    ($mp3 -eq $null -or $_.FullName -ne $mp3.FullName) -and
    ($notes -eq $null -or $_.FullName -ne $notes.FullName)
  }
  foreach ($file in $otherFiles) {
    Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $tempDir (ConvertTo-SafeFileName -Text $file.Name)) -Force
  }
  $tempFiles = Get-ChildItem -LiteralPath $tempDir -File
  Compress-Archive -LiteralPath $tempFiles.FullName -DestinationPath $ZipPath -Force
} finally {
  if (Test-Path $tempDir) {
    Remove-Item -LiteralPath $tempDir -Recurse -Force
  }
}

Write-Host "Deliverable zip saved:"
Write-Host (Resolve-Path $ZipPath)
