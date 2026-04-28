param(
    [string]$Version = "17.9",
    [int]$Port = 5432
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$pgRoot = Join-Path $repoRoot "tools\\postgresql"
$pgBin = Join-Path $pgRoot "$Version\\pgsql\\bin"
$dataPath = Join-Path $pgRoot "data"
$logPath = Join-Path $pgRoot "postgresql.log"

if (-not (Test-Path $pgBin)) {
    throw "Portable PostgreSQL not found. Run scripts/setup-portable-postgres.ps1 first."
}

& (Join-Path $pgBin "pg_ctl.exe") start -D $dataPath -l $logPath -o ('"-p {0}"' -f $Port) -w
Write-Host "PostgreSQL started on localhost:$Port."
