# SignKo Glove Hardware Wiring & Assembly Guide

This guide provides step-by-step physical connection schematics for assembling the SignKo wearable smart glove using the **ESP32-S3-N16R8** development board, **Spectra Symbol** flex sensors, **MPU-6050** IMU, **5.0V vibration actuator**, and the **1500mAh Li-Po / TP4056 / Boost Converter** power system.

---

## 1. Master Pin-to-Pin Interconnect Table

| Component | Component Pin | Connects To | Voltage / Signal | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Thumb Flex** | Terminal 1<br>Terminal 2 | ESP32-S3 `3.3V`<br>`GPIO 4` + $47\text{ k}\Omega$ to `GND` | Analog `ADC1_CH3`<br>($1.15\text{V}\text{--}2.4\text{V}$) | 2.2" Spectra Symbol `FS-L-0055-253-ST` |
| **Index Flex** | Terminal 1<br>Terminal 2 | ESP32-S3 `3.3V`<br>`GPIO 5` + $47\text{ k}\Omega$ to `GND` | Analog `ADC1_CH4` | 2.2" Spectra Symbol `FS-L-0055-253-ST` |
| **Middle Flex** | Terminal 1<br>Terminal 2 | ESP32-S3 `3.3V`<br>`GPIO 6` + $47\text{ k}\Omega$ to `GND` | Analog `ADC1_CH5` | 2.2" Spectra Symbol `FS-L-0055-253-ST` |
| **Ring Flex** | Terminal 1<br>Terminal 2 | ESP32-S3 `3.3V`<br>`GPIO 7` + $47\text{ k}\Omega$ to `GND` | Analog `ADC1_CH6` | 2.2" Spectra Symbol `FS-L-0055-253-ST` |
| **Pinky Flex** | Terminal 1<br>Terminal 2 | ESP32-S3 `3.3V`<br>`GPIO 1` + $47\text{ k}\Omega$ to `GND` | Analog `ADC1_CH0` | 2.2" Spectra Symbol `FS-L-0055-253-ST` |
| **MPU-6050 (GY-521)** | `VCC`<br>`GND`<br>`SDA`<br>`SCL`<br>`AD0` | ESP32-S3 `3.3V`<br>Common `GND`<br>ESP32-S3 `GPIO 8`<br>ESP32-S3 `GPIO 9`<br>Common `GND` | Power (3.3V)<br>Ground<br>I²C Data (400 kHz)<br>I²C Clock (400 kHz)<br>Address Select | Gyroscope & Accelerometer<br>I²C Address: `0x68` (since AD0 is tied LOW) |
| **5V Vibration Module** | `VCC`<br>`GND`<br>`IN` | Boost Converter `5.0V OUT+`<br>Common `GND`<br>ESP32-S3 `GPIO 14` | Power (5.0V)<br>Ground<br>Digital / PWM Control | Onboard MOSFET driver (`HIGH` = ON, `LOW` = OFF) |
| **TP4056 Charger** | `B+` / `B-`<br>`OUT+` / `OUT-`<br>`USB-C` | 1500mAh Li-Po Red/Black<br>Boost Converter `IN+` / `IN-`<br>5V USB Charging cable | Battery Terminals<br>Load output (3.0V–4.2V)<br>Charging input | Single-cell Li-Po charger with protection |
| **DC-DC Boost Converter**| `IN+` / `IN-`<br>`OUT+` / `OUT-` | TP4056 `OUT+` / `OUT-`<br>ESP32-S3 `5V` (or `VIN`) & Common `GND` | Battery level input<br>Regulated **5.0V DC** rail | Trimmer potentiometer preset to **5.0V DC** |

---

## 2. Flex Sensor Voltage Divider Circuit

Each finger bend sensor utilizes a voltage divider topology with a fixed $47\text{ k}\Omega$ resistor ($1/4\text{W}$, 1% or 5% tolerance):

```text
       ESP32-S3 3.3V Rail
              │
              ▼
      ┌───────────────┐
      │ Spectra Symbol│  (25kΩ Flat -> 125kΩ Bent)
      │  Flex Sensor  │
      └───────┬───────┘
              │
              ├────────────────────────► To ESP32-S3 ADC1 Pin
              │                         (GPIO 4, 5, 6, 7, or 1)
              ▼
      ┌───────────────┐
      │  Fixed 47kΩ   │
      │   Resistor    │
      └───────┬───────┘
              │
              ▼
          Common GND
```

### Voltage to ADC Mapping
* **Flat Pose ($R_{\text{flex}} \approx 25\text{ k}\Omega$)**:
  $$V_{\text{ADC}} = 3.3\text{V} \times \frac{47\text{ k}\Omega}{25\text{ k}\Omega + 47\text{ k}\Omega} \approx 2.15\text{V}$$
* **Clenched Fist Pose ($R_{\text{flex}} \approx 125\text{ k}\Omega$)**:
  $$V_{\text{ADC}} = 3.3\text{V} \times \frac{47\text{ k}\Omega}{125\text{ k}\Omega + 47\text{ k}\Omega} \approx 0.90\text{V}$$

*(Note: The firmware automatically handles both pull-up and pull-down configurations seamlessly during the interactive 4-step mobile calibration process).*

---

## 3. Power Subsystem Wiring

```text
[USB Type-C Wall Charger (5V)]
              │
              ▼
    ┌───────────────────┐
    │  TP4056 Charger   │  B+ ────────► [Li-Po Red (+)] 3.7V 1500mAh
    │ (With Protection) │  B- ────────► [Li-Po Black (-)]
    └─────────┬─────────┘
              │ OUT+ / OUT- (3.0V - 4.2V discharge)
              ▼
    ┌───────────────────┐
    │ Mini DC-DC Boost  │ (Adjust potentiometer until output = 5.00V)
    │     Converter     │
    └─────────┬─────────┘
              │ 5.0V Regulated Rail
              ├──────────────────────────────────► 5V Vibration Module VCC
              ▼
    ┌───────────────────┐
    │  ESP32-S3-N16R8   │
    │   (5V / VIN Pin)  │
    └─────────┬─────────┘
              │ 3.3V Onboard LDO Rail
              ├──────────────────────────────────► MPU-6050 VCC
              └──────────────────────────────────► 5x Flex Sensor Dividers
```

> [!CAUTION]
> **Common Ground Requirement**: The ground terminals (`GND`) of the TP4056 output, Mini Boost Converter, ESP32-S3, MPU-6050, flex divider resistors, and the vibration motor module **must all be tied together** to establish a single common reference plane. Never connect any external device to `GPIO 26–37`.
