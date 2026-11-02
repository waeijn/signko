# SignKo ESP32-S3 Firmware (`embedded/`)

This directory contains the production embedded firmware for the SignKo wearable smart gloves. It runs on the **ESP32-S3-N16R8** microcontroller, managing multi-sensor acquisition, on-device TinyML gesture classification (Edge Impulse), Bluetooth Low Energy (BLE 5.0) GATT communication, and haptic actuator feedback.

---

## Hardware Architecture

| Component | Model / IC | Interface / Pinout | Role |
| :--- | :--- | :--- | :--- |
| **Microcontroller** | **ESP32-S3-N16R8** (`WROOM-1`) | 16MB Quad Flash + 8MB Octal PSRAM | Core computation & BLE server |
| **Flex Sensors (x5)** | **Spectra Symbol `FS-L-0055-253-ST`** | `ADC1` (`GPIO 4, 5, 6, 7, 1`) | Finger flexion bend measurement ($25\text{ k}\Omega\text{--}125\text{ k}\Omega$) |
| **6-Axis IMU** | **TDK InvenSense `MPU-6050`** (`GY-521`) | 400 kHz I²C (`SDA=GPIO 8`, `SCL=GPIO 9`) | 3-axis accel ($\pm 2g$) & 3-axis gyro ($\pm 250^\circ/\text{s}$) |
| **Haptic Actuator** | **5.0V Vibration Module** | Digital Out (`GPIO 14`) | Incoming message & gesture confirmation pulses |
| **Power Supply** | **1500mAh 1S Li-Po (3.7V)** | TP4056 Charger $\rightarrow$ Boost Converter | Regulated 5.0V system rail |

> [!IMPORTANT]
> **Reserved Pins Warning**: On the `ESP32-S3-N16R8`, **GPIOs 26–32** are used internally by the 16MB SPI Flash and **GPIOs 33–37** are reserved for the 8MB Octal PSRAM. Never connect external sensors to these pins.
> Only **ADC1 (GPIOs 1–10)** channels are used for flex sensors so analog reads never conflict with active BLE transmission.

---

## Dual-Core FreeRTOS Task Layout

To guarantee zero latency drops on the BLE radio and non-blocking sensor sampling, work is distributed across the ESP32-S3 dual-core processor:

```text
┌──────────────────────────────────────────────┐
│             ESP32-S3 Dual-Core LX7           │
├──────────────────────┬───────────────────────┤
│    Core 0 (Radio)    │  Core 1 (Application) │
├──────────────────────┼───────────────────────┤
│ • BLE 5.0 GATT Stack │ • 50 Hz Sensor Loop   │
│ • GAP Advertising    │ • TinyML Window Task  │
│ • Notify Dispatch    │ • Haptic Worker Task  │
└──────────────────────┴───────────────────────┘
```

1. **Sensor Loop (`Core 1`, 50 Hz / 20 ms)**: Samples the 5 Spectra Symbol flex sensors via ADC1 and bursts 14 bytes from the MPU-6050 over 400 kHz I²C.
2. **TinyML Task (`Core 1`, 5 Hz / 200 ms stride)**: Unwraps the 50-frame (1000 ms) sliding window chronologically, runs the 1D CNN classifier, and filters background classes (`idle`, `_noise`).
3. **Haptic Task (`Core 1`, Event-driven)**: Consumes vibration pattern commands asynchronously from a FreeRTOS queue (`HapticWorker`).
4. **BLE Stack (`Core 0`)**: Handles connection events, GATT character notifications, and incoming remote calibration commands.

---

## Quick-Start Scripts

Automated PowerShell scripts in [`scripts/`](file:///c:/Users/ASUS/Documents/dev-projects/signko/embedded/scripts) streamline daily embedded development:

### 1. Run Automated Tests
Executes the native C++ unit and integration test suite (16 tests verifying sensor math, buffer unwrapping, BLE protocols, and strict `-Werror` compilation):

```powershell
.\embedded\scripts\test.ps1
```

### 2. Build Firmware
Verifies PlatformIO CLI availability and executes a clean build targeting `esp32-s3-devkitc-1`:

```powershell
.\embedded\scripts\build.ps1
# Or clean build:
.\embedded\scripts\build.ps1 -Clean
```

### 3. Flash to ESP32-S3 & Launch Serial Monitor
Builds and uploads firmware to the connected board, optionally launching the interactive 115200 baud serial monitor:

```powershell
# Auto-detect port and flash:
.\embedded\scripts\flash.ps1

# Specify COM port and monitor output:
.\embedded\scripts\flash.ps1 -Port COM3 -Monitor
```

---

## Edge Impulse TinyML Deployment

1. Train your 1D CNN gesture classification model on [Edge Impulse](https://www.edgeimpulse.com).
2. Go to **Deployment** $\rightarrow$ select **C++ Library** $\rightarrow$ click **Build**.
3. Extract the downloaded `.zip` directly into [`embedded/lib/signko_inferencing/`](file:///c:/Users/ASUS/Documents/dev-projects/signko/embedded/lib/signko_inferencing).
4. Rebuild the firmware:
   ```powershell
   .\embedded\scripts\build.ps1
   ```
   The firmware automatically detects `signko_inferencing.h` via `#if __has_include("signko_inferencing.h")` and replaces the bring-up heuristic with the actual trained 1D CNN model.

---

## Directory Layout

```text
embedded/
├── compat/                     # Local VS Code IntelliSense mock stubs (ESP32-S3 / FreeRTOS)
├── include/                    # Project C++ header declarations
│   ├── ble_pipeline.h          # BLE GATT server and telemetry dispatch
│   ├── haptics.h               # Vibration actuator patterns (GPIO 14)
│   ├── sdk_compat.h            # Architecture compatibility include bridge
│   ├── sensors.h               # ADC1 flex sensors + MPU-6050 I2C definitions
│   └── tinyml_pipeline.h       # 50 Hz sliding window & inference task
├── lib/
│   └── signko_inferencing/     # Edge Impulse TinyML exported C++ library
├── scripts/
│   ├── build.ps1               # PlatformIO compilation script
│   ├── flash.ps1               # PlatformIO flashing & monitor script
│   └── test.ps1                # Native C++ automated test runner
├── src/                        # Implementation source files
│   ├── ble_pipeline.cpp
│   ├── haptics.cpp
│   ├── main.cpp                # System orchestrator
│   ├── sensors.cpp
│   └── tinyml_pipeline.cpp
├── test/                       # Automated unit and integration test suite
│   ├── test_ble_pipeline.h
│   ├── test_main.cpp
│   ├── test_runner.h
│   ├── test_sensors.h
│   └── test_tinyml_pipeline.h
└── platformio.ini              # ESP32-S3-N16R8 (16MB Flash, 8MB Octal PSRAM) configuration
```
