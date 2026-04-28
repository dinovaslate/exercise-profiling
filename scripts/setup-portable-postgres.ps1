param(
    [string]$Version = "17.9",
    [string]$Database = "advpro-2024",
    [string]$Username = "postgres",
    [string]$Password = "my-password",
    [int]$Port = 5432
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$toolsRoot = Join-Path $repoRoot "tools"
$downloadsRoot = Join-Path $toolsRoot "downloads"
$pgRoot = Join-Path $toolsRoot "postgresql"
$versionRoot = Join-Path $pgRoot $Version
$zipPath = Join-Path $downloadsRoot "postgresql-$Version-windows-x64-binaries.zip"
$dataPath = Join-Path $pgRoot "data"
$passwordFile = Join-Path $pgRoot "initdb-password.txt"

$downloadMap = @{
    "17.9" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1260148"
}

if (-not $downloadMap.ContainsKey($Version)) {
    throw "Unsupported PostgreSQL version: $Version"
}

New-Item -ItemType Directory -Force -Path $downloadsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $pgRoot | Out-Null

if (-not (Test-Path $zipPath)) {
    Invoke-WebRequest -UseBasicParsing $downloadMap[$Version] -OutFile $zipPath
}

if (-not (Test-Path $versionRoot)) {
    Expand-Archive -Path $zipPath -DestinationPath $versionRoot -Force
}

$pgBin = Join-Path $versionRoot "pgsql\\bin"

if (-not (Test-Path $dataPath)) {
    New-Item -ItemType Directory -Force -Path $dataPath | Out-Null
    Set-Content -Path $passwordFile -Value $Password
    & (Join-Path $pgBin "initdb.exe") -D $dataPath -U $Username --pwfile=$passwordFile -A scram-sha-256 -E UTF8
    Remove-Item $passwordFile -Force
}

& (Join-Path $pgBin "pg_ctl.exe") start -D $dataPath -l (Join-Path $pgRoot "postgresql.log") -o ('"-p {0}"' -f $Port) -w

$env:PGPASSWORD = $Password
& (Join-Path $pgBin "createdb.exe") -h localhost -p $Port -U $Username $Database 2>$null

Write-Host "PostgreSQL is ready on localhost:$Port with database '$Database'."
