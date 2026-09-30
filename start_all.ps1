# start_all.ps1
# Starts the backend in Docker and launches the Flutter app in Edge

Write-Host "Starting Docker backend..." -ForegroundColor Cyan
docker compose up -d

Write-Host "Waiting a few seconds for the database to boot..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host "Cleaning Flutter build cache..." -ForegroundColor Cyan
Set-Location -Path "app"
flutter clean

Write-Host "Launching Flutter Web in Edge..." -ForegroundColor Cyan
flutter run -d edge

# Return to root directory when done
Set-Location -Path ".."
