param(
    [string]$JavaHome = "C:\Program Files\Java\jdk-21"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

$env:JAVA_HOME = $JavaHome
$env:Path = "$JavaHome\bin;$env:Path"

Push-Location $repoRoot
try {
    & .\mvnw.cmd spring-boot:run
} finally {
    Pop-Location
}
