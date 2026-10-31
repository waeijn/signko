<#
.SYNOPSIS
    Compiles the SignKo ESP32 firmware using PlatformIO.
.DESCRIPTION
    Verifies PlatformIO CLI availability and executes a clean build of the embedded firmware.
.EXAMPLE
    .\embedded\scripts\build.ps1
    .\embedded\scripts\build.ps1 -Clean
#>

[CmdletBinding()]
param(
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

$EmbeddedDir = Split-Path -Parent $PSScriptRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      SignKo ESP32 Firmware Builder       " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Resolve PlatformIO executable
$PioCmd = Get-Command "pio" -ErrorAction SilentlyContinue
if (-not $PioCmd) {
    $DefaultPioPath = Join-Path $env:USERPROFILE ".platformio\penv\Scripts\pio.exe"
    if (Test-Path $DefaultPioPath) {
        $PioCmd = $DefaultPioPath
    }
}

if (-not $PioCmd) {
    Write-Host "[ERROR] PlatformIO CLI ('pio') was not found in PATH or at default location." -ForegroundColor Red
    Write-Host "Please ensure PlatformIO is installed via VS Code extension or with:" -ForegroundColor Yellow
    Write-Host "  pip install -U platformio" -ForegroundColor White
    exit 1
}

Push-Location $EmbeddedDir
try {
    if ($Clean) {
        Write-Host "[BUILD] Cleaning previous build artifacts..." -ForegroundColor Yellow
        & $PioCmd run --target clean
    }

    Write-Host "[BUILD] Compiling ESP32 firmware target (esp32dev)..." -ForegroundColor Green
    & $PioCmd run

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[SUCCESS] Firmware compiled successfully!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[FAILURE] Build failed with exit code $LASTEXITCODE." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
