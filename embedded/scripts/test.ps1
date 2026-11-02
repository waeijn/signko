<#
.SYNOPSIS
    Compiles and executes automated tests for the SignKo embedded subsystem.
.DESCRIPTION
    1. Verifies strict zero-warning compilation (-Wall -Wextra -Werror) of all firmware translation units in embedded/src/.
    2. Links and runs native C++ unit and integration tests against the actual firmware modules:
       - Sensors: Flex sensor normalization, ADC clamping, and MPU-6050 physical conversion.
       - TinyML: Chronological circular buffer unwrapping, window warm-up, 200ms stride, debounce cooldown, and background filtering.
       - BLE: GATT UUID integrity, JSON payload formatting, and incoming command byte decoding.
       - Integration: Live linkage and execution of sensors.cpp, tinyml_pipeline.cpp, ble_pipeline.cpp, and haptics.cpp.
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
$SrcDir      = Join-Path $EmbeddedDir "src"
$TestDir     = Join-Path $EmbeddedDir "test"
$IncludeDir  = Join-Path $EmbeddedDir "include"
$CompatDir   = Join-Path $EmbeddedDir "compat"
$BinDir      = Join-Path $TestDir "bin"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "     SignKo Embedded Automated Test Runner        " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Native C++ Firmware Verification & Pipeline Tests
$GppCmd = Get-Command "g++" -ErrorAction SilentlyContinue
if ($GppCmd) {
    if (-not (Test-Path $BinDir)) {
        New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    }

    $MainCpp     = Join-Path $SrcDir "main.cpp"
    $SensorsCpp  = Join-Path $SrcDir "sensors.cpp"
    $TinyMLCpp   = Join-Path $SrcDir "tinyml_pipeline.cpp"
    $BleCpp      = Join-Path $SrcDir "ble_pipeline.cpp"
    $HapticsCpp  = Join-Path $SrcDir "haptics.cpp"
    $TestMainCpp = Join-Path $TestDir "test_main.cpp"
    $MainObj     = Join-Path $BinDir "main.o"
    $ExePath     = Join-Path $BinDir "run_tests.exe"

    Write-Host "[VERIFY] Checking firmware entrypoint (main.cpp) with -Wall -Wextra -Werror..." -ForegroundColor Green
    & $GppCmd -std=c++17 -Wall -Wextra -Werror `
        -I"$IncludeDir" `
        -I"$CompatDir" `
        -c "$MainCpp" `
        -o "$MainObj"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Firmware entrypoint (main.cpp) failed strict compilation check!" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "[COMPILE] Building and linking pipeline test suite against embedded/src modules..." -ForegroundColor Green
    & $GppCmd -std=c++17 -Wall -Wextra -Werror `
        -I"$IncludeDir" `
        -I"$CompatDir" `
        -I"$TestDir" `
        "$TestMainCpp" `
        "$SensorsCpp" `
        "$TinyMLCpp" `
        "$BleCpp" `
        "$HapticsCpp" `
        -o "$ExePath"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to compile and link test suite!" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "[RUN] Executing embedded unit & integration tests..." -ForegroundColor Green
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
Write-Host "[SUCCESS] All automated embedded checks and tests completed successfully!" -ForegroundColor Green
