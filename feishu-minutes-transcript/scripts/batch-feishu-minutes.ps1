param(
  [string]$MinuteUrls,
  [string]$MinuteTokens,
  [string]$OutputDir = "outputs\feishu-minutes-batch",
  [switch]$DownloadAudio,
  [switch]$ExtractAudio,
  [ValidateSet("m4a", "mp3")]
  [string]$AudioFormat = "mp3",
  [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

function Resolve-MinuteTokens {
  param([string]$Urls, [string]$Tokens)

  $resolved = @()
  if (-not [string]::IsNullOrWhiteSpace($Tokens)) {
    $resolved += ($Tokens -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  }
  if (-not [string]::IsNullOrWhiteSpace($Urls)) {
    foreach ($part in ($Urls -split ",")) {
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

$tokens = @(Resolve-MinuteTokens -Urls $MinuteUrls -Tokens $MinuteTokens)
if ($tokens.Count -eq 0) {
  throw "Provide -MinuteUrls or -MinuteTokens."
}

$scriptPath = Join-Path $PSScriptRoot "feishu-minutes-picker.ps1"
if (-not (Test-Path $scriptPath)) {
  throw "Cannot find feishu-minutes-picker.ps1 next to this script."
}

if ([System.IO.Path]::IsPathRooted($OutputDir)) {
  throw "OutputDir must be a relative path for lark-cli, for example: outputs\feishu-minutes-batch"
}

Write-Host "Processing $($tokens.Count) minute(s) separately..."
for ($i = 0; $i -lt $tokens.Count; $i++) {
  $token = $tokens[$i]
  $itemOutput = Join-Path $OutputDir ("minute-" + ($i + 1).ToString("000") + "-" + $token.Substring(0, [Math]::Min(12, $token.Length)))
  Write-Host ""
  Write-Host "[$($i + 1)/$($tokens.Count)] $token"

  if ($DownloadAudio -and $ExtractAudio -and $Overwrite) {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -DownloadAudio -ExtractAudio -AudioFormat $AudioFormat -Overwrite
  } elseif ($DownloadAudio -and $ExtractAudio) {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -DownloadAudio -ExtractAudio -AudioFormat $AudioFormat
  } elseif ($DownloadAudio -and $Overwrite) {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -DownloadAudio -AudioFormat $AudioFormat -Overwrite
  } elseif ($DownloadAudio) {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -DownloadAudio -AudioFormat $AudioFormat
  } elseif ($Overwrite) {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -AudioFormat $AudioFormat -Overwrite
  } else {
    & $scriptPath -MinuteTokens $token -OutputDir $itemOutput -AudioFormat $AudioFormat
  }
  if ($LASTEXITCODE -ne 0) {
    throw "Failed while processing minute token: $token"
  }
}

Write-Host ""
Write-Host "Batch export complete:"
Write-Host (Resolve-Path $OutputDir -ErrorAction SilentlyContinue)
