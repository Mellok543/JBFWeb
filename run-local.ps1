$ErrorActionPreference = "Stop"

Write-Host "Starting JBForsaken backend with local H2 profile..."
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PSScriptRoot\backend'; .\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local"
)

Start-Sleep -Seconds 3

Write-Host "Starting Flutter frontend..."
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PSScriptRoot\frontend'; flutter pub get; flutter run -d chrome --web-port 5173"
)
