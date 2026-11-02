# SignKo Hardware Specifications & Wiring Reference

This document details the complete hardware Bill of Materials (BOM), electrical characteristics, power topology, and GPIO pin assignments for the SignKo wearable smart gloves.

---

## 1. Microcontroller Unit (MCU)

| Parameter | Specification |
| :--- | :--- |
| **Part Number** | **ESP32-S3-N16R8** |
| **Module** | `ESP32-S3-WROOM-1` (ESP32-S3 Dual-Core Xtensa LX7 SoC @ 240 MHz) |
| **Wireless** | 2.4 GHz Wi-Fi (802.11 b/g/n) + Bluetooth Low Energy (BLE 5.0) |
| **Flash Memory** | **16 MB** Quad SPI (`N16`) |
| **PSRAM** | **8 MB** Octal SPI (`R8` — `qio_opi` memory mode) |
| **Pin Count** | 44 Pins (Separate or Soldered Header; compatible with Core Board / Expansion Board A & B) |
| **USB Interface** | Dual USB Type-C (UART Bridge + Native USB OTG/CDC) |
| **Brand / Weight** | UICPAL (New) / ~0.1 kg |

> [!IMPORTANT]
> On the **ESP32-S3-N16R8**, **GPIOs 26–32** are used internally by the 16 MB SPI Flash and **GPIOs 33–37** are reserved for the 8 MB Octal SPI PSRAM (`opi`). Never connect external sensors or actuators to GPIOs 26–37. Additionally, only **ADC1 (GPIOs 1–10)** should be used for analog flex reading while BLE is active, as ADC2 conflicts with the wireless radio.

---

## 2. Flex Sensors (Finger Bend Detection)

| Parameter | Specification |
| :--- | :--- |
| **Brand** | **Spectra Symbol** |
| **Model** | `FS-L-0055-253-ST` |
| **Sensor Type** | Resistive Flex / Bend Sensor (5 per glove: Thumb, Index, Middle, Ring, Pinky) |
| **Sensing Length** | 2.2 inches (55.37 mm active length) |
| **Total Dimensions** | 73.66 mm × 6.35 mm × 0.43 mm (0.017 inches thick) |
| **Flat Resistance** | $25\text{ k}\Omega \pm 30\%$ |
| **Bend Resistance** | $45\text{ k}\Omega \text{ – } 125\text{ k}\Omega$ (increases with bend angle/radius) |
| **Output** | Variable analog resistance |
| **Power Rating** | 0.5 W continuous; 1.0 W peak |
| **Life Cycle** | $> 1\text{ million}$ bend cycles |
| **Operating Temp** | $-35^\circ\text{C}$ to $+80^\circ\text{C}$ |
| **Connector Pitch** | 0.1 inches (2.54 mm) |

### Voltage Divider Circuit
Each flex sensor is wired in a voltage divider powered from the regulated **3.3V** rail of the ESP32-S3 with a fixed $47\text{ k}\Omega$ resistor ($R_{\text{fixed}}$):

$$V_{\text{ADC}} = 3.3\text{V} \times \frac{R_{\text{flex}}}{R_{\text{fixed}} + R_{\text{flex}}}$$

- **Flat Hand ($R_{\text{flex}} \approx 25\text{ k}\Omega$)**: $V_{\text{ADC}} \approx 1.15\text{V}$ ($\text{ADC} \approx 1425 / 4095$)
- **Full Bend ($R_{\text{flex}} \approx 100\text{–}125\text{ k}\Omega$)**: $V_{\text{ADC}} \approx 2.24\text{–}2.40\text{V}$ ($\text{ADC} \approx 2780\text{–}3000 / 4095$)

---

## 3. Inertial Measurement Unit (IMU)

| Parameter | Specification |
| :--- | :--- |
| **Brand / Manufacturer** | **TDK InvenSense** |
| **Model / Breakout** | `MPU-6050` (`GY-521` Breakout Board) |
| **Sensor Type** | 6-Axis MEMS Motion Tracking Sensor |
| **Accelerometer** | 3-Axis (X, Y, Z) — Programmable range: $\pm 2g, \pm 4g, \pm 8g, \pm 16g$ |
| **Gyroscope** | 3-Axis (X, Y, Z) — Programmable range: $\pm 250, \pm 500, \pm 1000, \pm 2000^\circ/\text{s}$ |
| **ADC Resolution** | 16-bit internal ADC per axis |
| **Communication** | I²C Bus up to **400 kHz** (Fast Mode) |
| **I²C Address** | `0x68` (`AD0 = LOW`, default) / `0x69` (`AD0 = HIGH`) |
| **Operating Voltage** | 2.375V–3.46V (IC); 3.3V–5V via `GY-521` onboard LDO regulator |
| **Current Draw** | ~3.9 mA (active 6-axis mode) |
| **Additional Features** | Digital Motion Processor (DMP), 1024-byte FIFO buffer, internal temperature sensor |
| **Operating Temp** | $-40^\circ\text{C}$ to $+85^\circ\text{C}$ |

---

## 4. Haptic Vibration Actuator

| Parameter | Specification |
| :--- | :--- |
| **Module Type** | **5V DC Vibration Motor Module** (MOSFET driver onboard) |
| **Rated Voltage** | 5.0V DC |
| **Operating Voltage** | 3.0V – 5.3V DC (Starting voltage: 3.7V DC) |
| **Rated Speed** | 9,000 RPM minimum |
| **Current Draw** | 60 mA rated / up to 90 mA starting current |
| **Insulation Resistance** | $10\text{ M}\Omega$ |
| **Dimensions** | 23.0 mm × 20.8 mm |

---

## 5. Power & Charging Subsystem

### A. Rechargeable Battery
| Parameter | Specification |
| :--- | :--- |
| **Battery Type** | **Lithium-Polymer (Li-Po)**, Single Cell (`1S`) |
| **Capacity** | **1500 mAh** (5.55 Wh) |
| **Nominal Voltage** | 3.7V DC |
| **Fully Charged Voltage** | 4.2V DC |
| **Discharge Cutoff** | ~3.0V DC |
| **Charging Method** | Constant Current / Constant Voltage (CC/CV) @ 0.5C–1C |

### B. Charging & Protection Module (`TP4056`)
| Parameter | Specification |
| :--- | :--- |
| **IC Model** | **TP4056** Single-Cell Li-Ion/Li-Po Charger |
| **Charging Interface** | USB Type-C (4.5V–5.5V DC input; 5.0V recommended) |
| **Charging Output** | 4.2V $\pm 1\%$, up to 1A CC/CV (termination at ~10% of programmed current) |
| **Protection Features** | Overcharge, over-discharge, and overcurrent protection |
| **Status Indicators** | Red LED (Charging) / Blue or Green LED (Fully Charged) |

### C. Step-Up Voltage Regulator (`Mini DC-to-DC Boost Converter`)
| Parameter | Specification |
| :--- | :--- |
| **Module Type** | **Mini DC-to-DC Step-Up (Boost) Converter** |
| **Input Voltage** | 3.0V–4.2V DC (from TP4056 `OUT+` / `OUT-` load terminals) |
| **Output Voltage** | Regulated **5.0V DC** (adjustable 5V–12V DC range) |
| **Efficiency** | 85%–95% |
| **Purpose** | Steps up the 3.7V Li-Po battery to a stable **5.0V DC** rail for the ESP32-S3 `5V/VIN` pin and the 5.0V Vibration Module (`VCC`). |

### Power Topology Diagram

```text
[USB-C 5V Input]
       │
       ▼
┌──────────────────────┐      ┌──────────────────────┐
│   TP4056 Charger     │◄────►│ 3.7V 1500mAh Li-Po   │
│  (With Protection)   │      │    (1S, 5.55Wh)      │
└──────────┬───────────┘      └──────────────────────┘
           │ Load OUT (3.0V - 4.2V)
           ▼
┌──────────────────────┐
│  Mini DC-DC Boost    │
│ Converter (Set 5.0V) │
└──────────┬───────────┘
           │ Regulated 5.0V Rail
           ├─────────────────────────────► [5V Vibration Module VCC]
           ▼
┌──────────────────────┐
│   ESP32-S3-N16R8     │ (5V/VIN Pin -> Onboard 3.3V LDO)
└──────────┬───────────┘
           │ Regulated 3.3V Rail
           ├─────────────────────────────► [5x Spectra Symbol Flex Dividers]
           └─────────────────────────────► [MPU-6050 (GY-521) VCC]
```

---

## 6. ESP32-S3-N16R8 Complete GPIO Pinout Table

| Peripheral / Signal | ESP32-S3 Pin | Hardware Function | Notes |
| :--- | :--- | :--- | :--- |
| **Thumb Flex Sensor** | `GPIO 4` | `ADC1_CH3` | Spectra Symbol 2.2" voltage divider |
| **Index Flex Sensor** | `GPIO 5` | `ADC1_CH4` | Spectra Symbol 2.2" voltage divider |
| **Middle Flex Sensor** | `GPIO 6` | `ADC1_CH5` | Spectra Symbol 2.2" voltage divider |
| **Ring Flex Sensor** | `GPIO 7` | `ADC1_CH6` | Spectra Symbol 2.2" voltage divider |
| **Pinky Flex Sensor** | `GPIO 1` | `ADC1_CH0` | Spectra Symbol 2.2" voltage divider |
| **Battery Monitor (Optional)** | `GPIO 2` | `ADC1_CH1` | 1:2 resistor divider from Li-Po `BAT+` |
| **MPU-6050 SDA** | `GPIO 8` | `I2C_SDA` | 400 kHz Fast-Mode I²C (`0x68`) |
| **MPU-6050 SCL** | `GPIO 9` | `I2C_SCL` | 400 kHz Fast-Mode I²C (`0x68`) |
| **Vibration Module IN** | `GPIO 14` | Digital PWM/GPIO Out | Drives onboard MOSFET gate (`HIGH` = ON) |
| **Internal SPI Flash** | `GPIO 26–32` | *Reserved* | Do not connect (16 MB Quad Flash) |
| **Internal Octal PSRAM** | `GPIO 33–37` | *Reserved* | Do not connect (8 MB Octal PSRAM) |
