param(
  [string]$Date,
  [string]$Start = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd"),
  [string]$End = (Get-Date).ToString("yyyy-MM-dd"),
  [ValidateSet("owner", "participant", "both")]
  [string]$Scope = "both",
  [string]$Query,
  [string]$Select,
  [string]$MinuteUrl,
  [string]$MinuteTokens,
  [string]$OutputDir = "outputs\feishu-minutes-selected",
  [string]$ListCsv,
  [bool]$FriendlyNames = $true,
  [switch]$SetupHelp,
  [switch]$ListOnly,
  [switch]$DownloadAudio,
  [switch]$ExtractAudio,
  [ValidateSet("m4a", "mp3")]
  [string]$AudioFormat = "mp3",
  [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

function Show-SetupHelp {
  Write-Host ""
  Write-Host "Feishu Minutes Transcript first-use setup"
  Write-Host ""
  Write-Host "1. Install Node.js LTS if npm/npx is not available."
  Write-Host "2. Install or update lark-cli:"
  Write-Host "   npx @larksuite/cli@latest install"
  Write-Host "3. Configure Feishu app credentials when first using lark-cli:"
  Write-Host "   lark-cli config init --new"
  Write-Host "4. Authorize the required minutes scopes with your own Feishu account:"
  Write-Host "   lark-cli auth login --scope `"minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export`""
  Write-Host "5. Verify lark-cli health and login:"
  Write-Host "   lark-cli doctor"
  Write-Host "   lark-cli auth status"
  Write-Host "6. Optional: install ffmpeg and keep it in PATH if you need to extract MP3 audio from mp4 meeting recordings."
  Write-Host ""
  Write-Host "This skill never packages another user's Feishu token, cookie, app secret, or downloaded meeting files."
}

function Test-LarkCliReady {
  $cmd = Get-Command lark-cli -ErrorAction SilentlyContinue
  if (-not $cmd) {
    Show-SetupHelp
    throw "lark-cli was not found in PATH. Complete the first-use setup above, then rerun this script."
  }
}

function Test-FfmpegReady {
  $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if (-not $cmd) {
    throw "ffmpeg was not found in PATH. Install ffmpeg first, then rerun with -ExtractAudio."
  }
}

if ($SetupHelp) {
  Show-SetupHelp
  exit 0
}

Test-LarkCliReady

function Invoke-LarkJson {
  param([string[]]$ArgsList)

  $raw = & lark-cli @ArgsList 2>$null
  $text = ($raw | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) {
    throw "lark-cli failed: $text"
  }
  if ([string]::IsNullOrWhiteSpace($text)) {
    throw "lark-cli returned empty output."
  }
  return $text | ConvertFrom-Json
}

function Search-Minutes {
  param([string]$Kind)

  $items = @()
  $pageToken = $null
  do {
    $argsList = @("minutes", "+search", "--start", $Start, "--end", $End, "--page-size", "30", "--format", "json")
    if (-not [string]::IsNullOrWhiteSpace($Query)) {
      $argsList += @("--query", $Query)
    }
    if ($Kind -eq "owner") {
      $argsList += @("--owner-ids", "me")
    } else {
      $argsList += @("--participant-ids", "me")
    }
    if ($pageToken) {
      $argsList += @("--page-token", $pageToken)
    }

    $result = Invoke-LarkJson -ArgsList $argsList
    if (-not $result.ok) {
      throw ($result | ConvertTo-Json -Depth 8)
    }
    if ($result.data.items) {
      $items += $result.data.items
    }
    $pageToken = $result.data.page_token
  } while ($result.data.has_more -and $pageToken)

  return $items
}

function Resolve-MinuteTokens {
  param([string]$Url, [string]$Tokens)

  $resolved = @()
  if (-not [string]::IsNullOrWhiteSpace($Tokens)) {
    $resolved += ($Tokens -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  }
  if (-not [string]::IsNullOrWhiteSpace($Url)) {
    foreach ($part in ($Url -split ",")) {
      $value = $part.Trim()
      if ($value -match "/minutes/([^/?#]+)") {
        $resolved += $Matches[1]
      } elseif ($value -match "^obcn[a-zA-Z0-9]+$") {
        $resolved += $value
      } else {
        throw "Cannot extract minute token from: $value"
      }
    }
  }

  return @($resolved | Sort-Object -Unique)
}

function Get-MinuteTitle {
  param($Item)

  $text = [System.Net.WebUtility]::HtmlDecode([string]$Item.display_info)
  $line = ($text -split "`n" | Select-Object -First 1).Trim()
  $line = ($line -replace "<[^>]+>", "").Trim()
  if ([string]::IsNullOrWhiteSpace($line)) {
    return $Item.token
  }
  return $line
}

function Get-MinuteStartTime {
  param($Item)

  $desc = [System.Net.WebUtility]::HtmlDecode([string]$Item.meta_data.description)
  if ($desc -match "开始时间:\s*(\d{4})\.(\d{2})\.(\d{2})\s+(\d{2}):(\d{2}):(\d{2})") {
    return Get-Date -Year ([int]$Matches[1]) -Month ([int]$Matches[2]) -Day ([int]$Matches[3]) -Hour ([int]$Matches[4]) -Minute ([int]$Matches[5]) -Second ([int]$Matches[6])
  }
  return [datetime]::MinValue
}

function ConvertTo-SafeFileName {
  param([string]$Text)

  $safe = [System.Net.WebUtility]::HtmlDecode($Text)
  $safe = ($safe -replace "<[^>]+>", "").Trim()
  foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
    $safe = $safe.Replace([string]$char, "_")
  }
  $safe = ($safe -replace "\s+", " ").Trim()
  if ($safe.Length -gt 80) {
    $safe = $safe.Substring(0, 80).Trim()
  }
  if ([string]::IsNullOrWhiteSpace($safe)) {
    return "untitled"
  }
  return $safe
}

function Get-TranscriptDateLabel {
  param([string]$TranscriptPath)

  if (Test-Path $TranscriptPath) {
    $firstLine = Get-Content -LiteralPath $TranscriptPath -TotalCount 1
    if ($firstLine -match "^(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})") {
      return "$($Matches[1])$($Matches[2])$($Matches[3])-$($Matches[4])$($Matches[5])"
    }
  }
  return (Get-Date).ToString("yyyyMMdd-HHmm")
}

function Copy-WithFriendlyName {
  param($NotesResult, [string]$OutDir, [string]$MediaDir)

  if (-not $FriendlyNames) {
    return
  }
  if (-not $NotesResult.data.notes) {
    return
  }

  $exportDir = Join-Path $OutDir "exports"
  if (-not (Test-Path $exportDir)) {
    New-Item -ItemType Directory -Path $exportDir | Out-Null
  }

  $noteItems = @($NotesResult.data.notes)
  foreach ($note in $noteItems) {
    $token = [string]$note.minute_token
    $shortToken = $token
    if ($shortToken.Length -gt 12) {
      $shortToken = $shortToken.Substring(0, 12)
    }
    $title = ConvertTo-SafeFileName -Text ([string]$note.title)
    $transcriptPath = [string]$note.artifacts.transcript_file
    $dateLabel = Get-TranscriptDateLabel -TranscriptPath $transcriptPath
    $baseName = ConvertTo-SafeFileName -Text ("$dateLabel" + "_" + "$title" + "_" + "$shortToken")

    if (Test-Path $transcriptPath) {
      $targetTranscript = Join-Path $exportDir ($baseName + ".txt")
      Copy-Item -LiteralPath $transcriptPath -Destination $targetTranscript -Force
      Write-Host "Friendly transcript saved: $targetTranscript"
    }

    if ((Test-Path $MediaDir) -and $noteItems.Count -eq 1) {
      $mediaFiles = Get-ChildItem -LiteralPath $MediaDir -File
      foreach ($file in $mediaFiles) {
        $ext = $file.Extension.ToLowerInvariant()
        if ($ext -in @(".mp3", ".m4a", ".aac", ".wav")) {
          $targetMedia = Join-Path $exportDir ($baseName + $ext)
        } elseif ($ext -in @(".mp4", ".mov", ".mkv", ".webm")) {
          $targetMedia = Join-Path $exportDir ($baseName + "-video" + $ext)
        } else {
          continue
        }
        Copy-Item -LiteralPath $file.FullName -Destination $targetMedia -Force
        Write-Host "Friendly media saved: $targetMedia"
      }
    }
  }
}

function Export-MinutesList {
  param($Items, [string]$CsvPath)

  if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    return
  }
  if ([System.IO.Path]::IsPathRooted($CsvPath)) {
    throw "ListCsv must be a relative path, for example: outputs\feishu-minutes-list.csv"
  }

  $parent = Split-Path -Parent $CsvPath
  if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent | Out-Null
  }

  $rows = foreach ($item in $Items) {
    [pscustomobject]@{
      title = Get-MinuteTitle -Item $item
      start_time = Get-MinuteStartTime -Item $item
      description = [System.Net.WebUtility]::HtmlDecode([string]$item.meta_data.description)
      url = [string]$item.meta_data.app_link
      token = [string]$item.token
    }
  }
  $rows | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8
  Write-Host ""
  Write-Host "List CSV saved:"
  Write-Host (Resolve-Path $CsvPath)
}

function Convert-DownloadedMediaToAudio {
  param([string]$MediaDir, [string]$Format)

  if (-not (Test-Path $MediaDir)) {
    return
  }

  Test-FfmpegReady
  $sourceFiles = Get-ChildItem -LiteralPath $MediaDir -Recurse -File | Where-Object {
    if ($Format -eq "mp3") {
      $_.Extension.ToLowerInvariant() -in @(".mp4", ".mov", ".mkv", ".webm", ".m4a", ".aac", ".wav")
    } else {
      $_.Extension.ToLowerInvariant() -in @(".mp4", ".mov", ".mkv", ".webm")
    }
  }

  if ($sourceFiles.Count -eq 0) {
    Write-Host "No convertible media files found for audio extraction."
    return
  }

  Write-Host "Extracting audio from downloaded media file(s)..."
  foreach ($file in $sourceFiles) {
    if ($file.Extension.ToLowerInvariant() -eq "." + $Format) {
      Write-Host "Audio already in target format, skipped: $($file.FullName)"
      continue
    }

    $target = Join-Path $file.DirectoryName ($file.BaseName + "." + $Format)
    if ((Test-Path $target) -and -not $Overwrite) {
      Write-Host "Audio already exists, skipped: $target"
      continue
    }

    if ($Format -eq "m4a") {
      & ffmpeg -y -loglevel error -i $file.FullName -vn -c:a copy $target | Out-Null
    } else {
      & ffmpeg -y -loglevel error -i $file.FullName -vn -codec:a libmp3lame -q:a 2 $target | Out-Null
    }

    if ($LASTEXITCODE -ne 0) {
      throw "ffmpeg failed to extract audio from: $($file.FullName)"
    }
    Write-Host "Audio saved: $target"
  }
}

function Expand-Selection {
  param([string]$InputText, [int]$Max)

  $inputText = $InputText.Trim()
  if ($inputText -eq "all") {
    return 1..$Max
  }

  $selected = New-Object System.Collections.Generic.List[int]
  foreach ($part in ($inputText -split ",")) {
    $part = $part.Trim()
    if ($part -match "^(\d+)-(\d+)$") {
      $from = [int]$Matches[1]
      $to = [int]$Matches[2]
      if ($from -gt $to) { throw "Invalid range: $part" }
      foreach ($n in $from..$to) { $selected.Add($n) }
    } elseif ($part -match "^\d+$") {
      $selected.Add([int]$part)
    } else {
      throw "Invalid selection: $part"
    }
  }

  $unique = $selected | Sort-Object -Unique
  foreach ($n in $unique) {
    if ($n -lt 1 -or $n -gt $Max) {
      throw "Selection out of range: $n"
    }
  }
  return $unique
}

if ([System.IO.Path]::IsPathRooted($OutputDir)) {
  throw "OutputDir must be a relative path for lark-cli, for example: outputs\feishu-minutes-selected"
}

if (-not [string]::IsNullOrWhiteSpace($Date)) {
  $Start = $Date
  $End = $Date
}

$directTokens = Resolve-MinuteTokens -Url $MinuteUrl -Tokens $MinuteTokens
if ($directTokens.Count -gt 0) {
  $tokens = $directTokens -join ","
  Write-Host ""
  Write-Host "Using provided minute token(s): $tokens"
  if ($ListOnly) {
    Write-Host "ListOnly is set. No transcript or audio files were downloaded."
    exit 0
  }
} else {
  Write-Host ""
  Write-Host "Searching Feishu Minutes from $Start to $End ..."

  $all = @()
  if ($Scope -in @("owner", "both")) {
    $all += Search-Minutes -Kind "owner"
  }
  if ($Scope -in @("participant", "both")) {
    $all += Search-Minutes -Kind "participant"
  }

  $seen = @{}
  $minutes = @()
  foreach ($item in $all) {
    if (-not $seen.ContainsKey($item.token)) {
      $seen[$item.token] = $true
      $minutes += $item
    }
  }

  $minutes = @($minutes | Sort-Object -Property @{ Expression = { Get-MinuteStartTime -Item $_ }; Descending = $true })

  if ($minutes.Count -eq 0) {
    Write-Host "No minutes found in this date range."
    exit 0
  }

  Write-Host ""
  Write-Host "Found $($minutes.Count) minute record(s):"
  for ($i = 0; $i -lt $minutes.Count; $i++) {
    $item = $minutes[$i]
    $title = Get-MinuteTitle -Item $item
    $desc = [System.Net.WebUtility]::HtmlDecode([string]$item.meta_data.description)
    Write-Host ("[{0}] {1}" -f ($i + 1), $title)
    Write-Host ("    {0}" -f $desc)
    Write-Host ("    {0}" -f $item.meta_data.app_link)
  }

  Export-MinutesList -Items $minutes -CsvPath $ListCsv

  Write-Host ""
  if ($ListOnly) {
    Write-Host "ListOnly is set. No transcript or audio files were downloaded."
    exit 0
  }

  $answer = $Select
  if ([string]::IsNullOrWhiteSpace($answer)) {
    $answer = Read-Host "Enter numbers to convert, for example 1,3-5, or all"
  }
  $indexes = Expand-Selection -InputText $answer -Max $minutes.Count
  $selected = foreach ($n in $indexes) { $minutes[$n - 1] }
  $tokens = ($selected | ForEach-Object { $_.token }) -join ","
}

Write-Host ""
Write-Host "Downloading transcripts..."
$noteArgs = @("vc", "+notes", "--minute-tokens", $tokens, "--output-dir", $OutputDir, "--format", "json")
if ($Overwrite) { $noteArgs += "--overwrite" }
$notes = Invoke-LarkJson -ArgsList $noteArgs
if (-not $notes.ok) {
  throw ($notes | ConvertTo-Json -Depth 10)
}

if ($DownloadAudio) {
  Write-Host "Downloading audio files..."
  $mediaDir = Join-Path $OutputDir "audio"
  $audioArgs = @("minutes", "+download", "--minute-tokens", $tokens, "--output-dir", $mediaDir, "--format", "json")
  if ($Overwrite) { $audioArgs += "--overwrite" }
  $audio = Invoke-LarkJson -ArgsList $audioArgs
  if (-not $audio.ok) {
    throw ($audio | ConvertTo-Json -Depth 10)
  }
  if ($ExtractAudio) {
    Convert-DownloadedMediaToAudio -MediaDir $mediaDir -Format $AudioFormat
  }
}

Copy-WithFriendlyName -NotesResult $notes -OutDir $OutputDir -MediaDir (Join-Path $OutputDir "audio")

Write-Host ""
Write-Host "Done. Output directory:"
Write-Host (Resolve-Path $OutputDir -ErrorAction SilentlyContinue)
if (-not (Test-Path $OutputDir)) {
  Write-Host $OutputDir
}
