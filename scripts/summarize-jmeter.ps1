param(
    [Parameter(Mandatory = $true)]
    [string]$ResultFile,
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

$rows = Import-Csv -Path $ResultFile
if (-not $rows -or $rows.Count -eq 0) {
    throw "No rows found in $ResultFile"
}

$samples = foreach ($row in $rows) {
    [PSCustomObject]@{
        Timestamp = [double]$row.timeStamp
        Elapsed = [double]$row.elapsed
        Success = [System.Convert]::ToBoolean($row.success)
        Label = $row.label
        ResponseCode = $row.responseCode
    }
}

$count = $samples.Count
$avg = [Math]::Round((($samples | Measure-Object -Property Elapsed -Average).Average), 2)
$min = [Math]::Round((($samples | Measure-Object -Property Elapsed -Minimum).Minimum), 2)
$max = [Math]::Round((($samples | Measure-Object -Property Elapsed -Maximum).Maximum), 2)
$sorted = $samples | Sort-Object Elapsed
$p95Index = [Math]::Ceiling($count * 0.95) - 1
if ($p95Index -lt 0) { $p95Index = 0 }
$p95 = [Math]::Round($sorted[$p95Index].Elapsed, 2)
$failures = ($samples | Where-Object { -not $_.Success }).Count
$errorRate = [Math]::Round(($failures / $count) * 100, 2)

$startMs = ($samples | Measure-Object -Property Timestamp -Minimum).Minimum
$endMs = ($samples | ForEach-Object { $_.Timestamp + $_.Elapsed } | Measure-Object -Minimum -Maximum).Maximum
$durationSeconds = [Math]::Max((($endMs - $startMs) / 1000.0), 1)
$throughput = [Math]::Round(($count / $durationSeconds), 2)

$summary = [PSCustomObject]@{
    result_file = $ResultFile
    sample_count = $count
    average_ms = $avg
    min_ms = $min
    max_ms = $max
    p95_ms = $p95
    throughput_rps = $throughput
    error_rate_percent = $errorRate
}

$json = $summary | ConvertTo-Json

if ($OutputFile) {
    $outputDir = Split-Path -Parent $OutputFile
    if ($outputDir) {
        New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    }
    Set-Content -Path $OutputFile -Value $json
}

$json
