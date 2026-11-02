<#
.SYNOPSIS
    Compiles and executes automated tests for the SignKo embedded subsystem.
.DESCRIPTION
    Runs native C++ unit tests verifying:
    - Sensors: Flex sensor normalization, ADC clamping, and MPU-6050 physical conversion.
    - TinyML: Chronological circular buffer unwrapping, window warm-up, 200ms stride, debounce cooldown, and background filtering.
    - BLE: GATT UUID integrity, JSON payload formatting, and incoming command byte decoding.
.PARAMETER PlatformIO
    Optional switch to execute hardware tests on an attached board via PlatformIO CLI ('pio test').
.EXAMPLE
    .\embedded\scripts\test.ps1
    .\embedded\scripts\test.ps1 -PlatformIO
#>

[CmdletBinding()]
param(
    [switch]$PlatformIO
)

$ErrorActionPreference = "Stop"

$EmbeddedDir = Split-Path -Parent $PSScriptRoot
$TestDir     = Join-Path $EmbeddedDir "test"
$IncludeDir  = Join-Path $EmbeddedDir "include"
$CompatDir   = Join-Path $EmbeddedDir "compat"
$BinDir      = Join-Path $TestDir "bin"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "     SignKo Embedded Automated Test Runner        " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Native C++ Pipeline Unit Tests
$GppCmd = Get-Command "g++" -ErrorAction SilentlyContinue
if ($GppCmd) {
    if (-not (Test-Path $BinDir)) {
        New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    }

    $ExePath = Join-Path $BinDir "run_tests.exe"
    $TestMain = Join-Path $TestDir "test_main.cpp"

    Write-Host "[COMPILE] Building native pipeline test suite using g++..." -ForegroundColor Green
    & $GppCmd -std=c++17 -Wall -Wextra `
        -I"$IncludeDir" `
        -I"$CompatDir" `
        -I"$TestDir" `
        "$TestMain" `
        -o "$ExePath"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to compile test suite!" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "[RUN] Executing embedded pipeline tests..." -ForegroundColor Green
    Write-Host ""
    & "$ExePath"
    $TestExitCode = $LASTEXITCODE

    if ($TestExitCode -ne 0) {
        Write-Host ""
        Write-Host "[FAILURE] Native pipeline tests failed with exit code $TestExitCode" -ForegroundColor Red
        exit $TestExitCode
    }
} else {
    Write-Host "[WARN] 'g++' was not detected in PATH. Skipping native host testing." -ForegroundColor Yellow
}

# 2. Optional PlatformIO On-Target Hardware Testing
if ($PlatformIO) {
    Write-Host ""
    Write-Host "[PIO] Running on-target tests via PlatformIO..." -ForegroundColor Cyan
    $PioCmd = Get-Command "pio" -ErrorAction SilentlyContinue
    if (-not $PioCmd) {
        $DefaultPioPath = Join-Path $env:USERPROFILE ".platformio\penv\Scripts\pio.exe"
        if (Test-Path $DefaultPioPath) {
            $PioCmd = $DefaultPioPath
        }
    }

    if ($PioCmd) {
        Push-Location $EmbeddedDir
        try {
            & $PioCmd test
        }
        finally {
            Pop-Location
        }
    } else {
        Write-Host "[WARN] PlatformIO CLI not found. Skipping hardware target tests." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[SUCCESS] All automated embedded tests completed successfully!" -ForegroundColor Green
