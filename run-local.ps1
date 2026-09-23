param(
    [string]$AdminSteamId = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Starting JBForsaken backend with local H2 profile..."
$mvn = if (Get-Command mvn -ErrorAction SilentlyContinue) {
    "mvn"
} elseif (Test-Path "C:\Program Files\apache-maven-3.9.16\bin\mvn.cmd") {
    "C:\Program Files\apache-maven-3.9.16\bin\mvn.cmd"
} else {
    throw "Maven not found. Install Maven or add mvn to PATH."
}

$adminPrefix = ""
if (-not [string]::IsNullOrWhiteSpace($AdminSteamId)) {
    $adminPrefix = "$env:ADMIN_STEAM_IDS='$AdminSteamId'; "
    Write-Host "Local admin SteamID64: $AdminSteamId"
} else {
    Write-Host "Admin panel will be read-only/inaccessible until ADMIN_STEAM_IDS is set."
    Write-Host "Example: .\run-local.ps1 -AdminSteamId 76561198XXXXXXXXX"
}

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "$adminPrefix cd '$PSScriptRoot\backend'; & '$mvn' spring-boot:run '-Dspring-boot.run.profiles=local'"
)

Start-Sleep -Seconds 3

Write-Host "Starting Flutter frontend..."
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PSScriptRoot\frontend'; flutter pub get; flutter run -d chrome --web-port 5173"
)
