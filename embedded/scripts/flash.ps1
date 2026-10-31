<#
.SYNOPSIS
    Flashes the SignKo ESP32 firmware to a connected board.
.DESCRIPTION
    Builds and uploads the firmware over USB Serial, with optional real-time serial monitoring.
.PARAMETER Port
    Optional serial port (e.g., COM3, COM4). Auto-detected if omitted.
.PARAMETER Monitor
    Switch to launch the interactive Serial Monitor at 115200 baud after uploading.
.EXAMPLE
    .\embedded\scripts\flash.ps1
    .\embedded\scripts\flash.ps1 -Port COM3 -Monitor
#>

[CmdletBinding()]
param(
    [string]$Port,
    [switch]$Monitor
)

$ErrorActionPreference = "Stop"

$EmbeddedDir = Split-Path -Parent $PSScriptRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      SignKo ESP32 Firmware Flasher       " -ForegroundColor Cyan
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
    $UploadArgs = @("run", "--target", "upload")
    if ($Port) {
        Write-Host "[FLASH] Target Serial Port: $Port" -ForegroundColor Green
        $UploadArgs += @("--upload-port", $Port)
    } else {
        Write-Host "[FLASH] Auto-detecting connected ESP32 COM port..." -ForegroundColor Yellow
    }

    Write-Host "[FLASH] Uploading firmware to ESP32..." -ForegroundColor Green
    & $PioCmd @UploadArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAILURE] Upload failed with exit code $LASTEXITCODE." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "[SUCCESS] Firmware flashed successfully!" -ForegroundColor Green

    if ($Monitor) {
        Write-Host ""
        Write-Host "[MONITOR] Launching Serial Monitor (115200 baud)... (Ctrl+C to exit)" -ForegroundColor Cyan
        $MonitorArgs = @("device", "monitor", "--baud", "115200")
        if ($Port) {
            $MonitorArgs += @("--port", $Port)
        }
        & $PioCmd @MonitorArgs
    }
}
finally {
    Pop-Location
}
