# stop_all.ps1
# Stops the Flutter app and shuts down the Docker backend containers

Write-Host "Stopping Docker backend containers..." -ForegroundColor Cyan
docker compose down

Write-Host "Done. Note: If you have a Flutter app running, you will need to stop it manually in your terminal (press 'q' or 'Ctrl+C') or close your IDE debugger." -ForegroundColor Yellow
