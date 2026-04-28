param(
    [Parameter(Mandatory = $true)]
    [int]$ProcessId,
    [Parameter(Mandatory = $true)]
    [string]$RecordingName,
    [Parameter(Mandatory = $true)]
    [string]$Endpoint,
    [Parameter(Mandatory = $true)]
    [int]$Iterations,
    [Parameter(Mandatory = $true)]
    [string]$OutputPrefix,
    [string]$JavaHome = "C:\Program Files\Java\jdk-21",
    [int]$TimeoutSec = 180
)

$ErrorActionPreference = "Stop"

$jcmd = Join-Path $JavaHome "bin\\jcmd.exe"
$jfr = Join-Path $JavaHome "bin\\jfr.exe"

& $jcmd $ProcessId JFR.start name=$RecordingName settings=profile | Out-Null

for ($i = 0; $i -lt $Iterations; $i++) {
    Invoke-WebRequest -UseBasicParsing $Endpoint -TimeoutSec $TimeoutSec | Out-Null
}

& $jcmd $ProcessId JFR.stop name=$RecordingName filename="$OutputPrefix.jfr" | Out-Null
& $jfr summary "$OutputPrefix.jfr" > "$OutputPrefix-summary.txt"
& $jfr print --events jdk.ExecutionSample --stack-depth 12 "$OutputPrefix.jfr" > "$OutputPrefix-execution.txt"
