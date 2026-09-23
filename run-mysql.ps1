$ErrorActionPreference = "Stop"

Write-Host "Starting MySQL..."
docker compose up -d mysql

Write-Host "Starting backend with dev profile..."
$mvn = if (Get-Command mvn -ErrorAction SilentlyContinue) {
    "mvn"
} elseif (Test-Path "C:\Program Files\apache-maven-3.9.16\bin\mvn.cmd") {
    "C:\Program Files\apache-maven-3.9.16\bin\mvn.cmd"
} else {
    throw "Maven not found. Install Maven or add mvn to PATH."
}
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "$env:DB_HOST='127.0.0.1'; $env:DB_PORT='3306'; $env:DB_NAME='jbforsaken_web'; $env:DB_USER='jbforsaken'; $env:DB_PASSWORD='jbforsaken_dev'; $env:JWT_SECRET='local-development-secret-key-at-least-32-bytes-long!!'; cd '$PSScriptRoot\backend'; & '$mvn' spring-boot:run '-Dspring-boot.run.profiles=dev'"
)

Start-Sleep -Seconds 5

Write-Host "Starting Flutter frontend..."
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PSScriptRoot\frontend'; flutter pub get; flutter run -d chrome --web-port 5173"
)
