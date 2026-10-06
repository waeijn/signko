# setup.ps1
# Automates the initial setup for new developers cloning the SignKo repository.

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "       SignKo Environment Setup          " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH. Please install Docker Desktop."
    exit 1
}

if (!(Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed or not in PATH. Please install the Flutter SDK."
    exit 1
}

Write-Host "Dependencies found. Proceeding..." -ForegroundColor Green
Write-Host ""

# 1.5. Setup Environment Variables
Write-Host "Checking environment variables..." -ForegroundColor Yellow
if (!(Test-Path ".env")) {
    Write-Host "No .env file found. Creating one from .env.example..." -ForegroundColor Cyan
    Copy-Item ".env.example" ".env"
} else {
    Write-Host ".env file already exists." -ForegroundColor Green
}
Write-Host ""

# 2. Setup Flutter frontend
Write-Host "Fetching Flutter dependencies..." -ForegroundColor Yellow
Set-Location "app"
flutter pub get
Set-Location ".."
Write-Host "Flutter setup complete." -ForegroundColor Green
Write-Host ""

# 3. Setup Docker backend
Write-Host "Building Docker containers for the backend..." -ForegroundColor Yellow
docker-compose build
docker-compose up -d
Write-Host "Backend containers are running." -ForegroundColor Green
Write-Host ""

# 4. Seed Database
Write-Host "Waiting 10 seconds for PostgreSQL to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Write-Host "Seeding database with initial users..." -ForegroundColor Yellow
.\seed_db.ps1
Write-Host ""

# 5. Finish
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Setup Complete!                         " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "To start development in the future, just run:" -ForegroundColor White
Write-Host "  .\start_all.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "The app will now be available on Flutter Web (Edge/Chrome)." -ForegroundColor White
Write-Host "The backend is running at http://localhost:8000" -ForegroundColor White
