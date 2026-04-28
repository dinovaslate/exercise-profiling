param(
    [string]$Version = "17.9"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$pgRoot = Join-Path $repoRoot "tools\\postgresql"
$pgBin = Join-Path $pgRoot "$Version\\pgsql\\bin"
$dataPath = Join-Path $pgRoot "data"

if (-not (Test-Path $pgBin)) {
    throw "Portable PostgreSQL not found."
}

& (Join-Path $pgBin "pg_ctl.exe") stop -D $dataPath -m fast -w
Write-Host "PostgreSQL stopped."
