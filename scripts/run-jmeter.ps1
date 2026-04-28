param(
    [Parameter(Mandatory = $true)]
    [string]$TestPlan,
    [Parameter(Mandatory = $true)]
    [string]$ResultFile,
    [Parameter(Mandatory = $true)]
    [string]$ReportDir,
    [Parameter(Mandatory = $true)]
    [string]$SummaryFile,
    [string]$JavaHome = "C:\Program Files\Java\jdk-21"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$jmeterBat = Join-Path $repoRoot "tools\\jmeter\\apache-jmeter-5.6.3\\bin\\jmeter.bat"

if (-not (Test-Path $jmeterBat)) {
    throw "JMeter is not installed. Run scripts/setup-jmeter.ps1 first."
}

$env:JAVA_HOME = $JavaHome
$env:Path = "$JavaHome\bin;$env:Path"

$resultPath = Join-Path $repoRoot $ResultFile
$reportPath = Join-Path $repoRoot $ReportDir
$summaryPath = Join-Path $repoRoot $SummaryFile
$testPlanPath = Join-Path $repoRoot $TestPlan

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resultPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportPath) | Out-Null
if (Test-Path $resultPath) {
    Remove-Item $resultPath -Force
}
if (Test-Path $reportPath) {
    Remove-Item $reportPath -Recurse -Force
}

& $jmeterBat -n -t $testPlanPath -l $resultPath -e -o $reportPath
& (Join-Path $PSScriptRoot "summarize-jmeter.ps1") -ResultFile $resultPath -OutputFile $summaryPath
