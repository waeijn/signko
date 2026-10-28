# start_all.ps1
# Starts the backend in Docker and launches the Flutter app in Edge

$dockerRunning = $false

Write-Host "Checking Docker status..." -ForegroundColor Cyan
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $dockerRunning = $true
}

if ($dockerRunning) {
    Write-Host "Starting Docker backend..." -ForegroundColor Cyan
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Failed to start Docker backend containers." -ForegroundColor Yellow
        $dockerRunning = $false
    } else {
        Write-Host "Waiting a few seconds for the database to boot..." -ForegroundColor Cyan
        Start-Sleep -Seconds 5
    }
}

if (-not $dockerRunning) {
    Write-Host ""
    Write-Host "[WARNING] Docker is not running or the backend failed to start." -ForegroundColor Yellow
    Write-Host "Without Docker, backend features (FastAPI and PostgreSQL database) will not be available." -ForegroundColor Yellow
    Write-Host ""

    $choice = Read-Host "Do you want to proceed with launching Flutter without Docker? (y/N)"
    if ($choice -notmatch "^(y|yes)$") {
        Write-Host "Exiting. Please start Docker Desktop and run .\start_all.ps1 again." -ForegroundColor Red
        exit 1
    }
    Write-Host "Proceeding with Flutter only..." -ForegroundColor Yellow
}

$originalDir = Get-Location
try {
    Write-Host "Cleaning Flutter build cache..." -ForegroundColor Cyan
    Set-Location -Path "app"
    flutter clean

    Write-Host "Launching Flutter Web in Edge..." -ForegroundColor Cyan
    flutter run -d edge
} finally {
    Set-Location -Path $originalDir
}
