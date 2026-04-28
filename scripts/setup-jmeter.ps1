param(
    [string]$Version = "5.6.3"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$toolsRoot = Join-Path $repoRoot "tools"
$downloadsRoot = Join-Path $toolsRoot "downloads"
$jmeterRoot = Join-Path $toolsRoot "jmeter"
$zipPath = Join-Path $downloadsRoot "apache-jmeter-$Version.zip"
$extractPath = Join-Path $jmeterRoot "apache-jmeter-$Version"

New-Item -ItemType Directory -Force -Path $downloadsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $jmeterRoot | Out-Null

if (-not (Test-Path $zipPath)) {
    Invoke-WebRequest -UseBasicParsing "https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-$Version.zip" -OutFile $zipPath
}

if (-not (Test-Path $extractPath)) {
    Expand-Archive -Path $zipPath -DestinationPath $jmeterRoot -Force
}

Write-Host "JMeter is ready at $extractPath"
