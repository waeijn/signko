#ifndef SIGNKO_SENSORS_H
#define SIGNKO_SENSORS_H

#include "sdk_compat.h"

// Number of Spectra Symbol FS-L-0055-253-ST (2.2") flex sensors per glove
// Electrical specs: Flat = 25kOhm (+/-30%), Bent = 45kOhm to 125kOhm
#define FLEX_SENSOR_COUNT 5
#define FLEX_FLAT_RESISTANCE_OHMS 25000.0f
#define FLEX_MAX_BEND_RESISTANCE_OHMS 125000.0f

// ESP32-S3-N16R8 Safe ADC1 Pins (GPIOs 1-10 are ADC1; avoids GPIOs 26-37 used by 16MB Flash & 8MB Octal PSRAM)
// Note: Only ADC1 channels can be sampled reliably while BLE/Wi-Fi is active.
#ifndef FLEX_PIN_THUMB
#define FLEX_PIN_THUMB 4   // GPIO4  (ADC1_CH3)
#endif
#ifndef FLEX_PIN_INDEX
#define FLEX_PIN_INDEX 5   // GPIO5  (ADC1_CH4)
#endif
#ifndef FLEX_PIN_MIDDLE
#define FLEX_PIN_MIDDLE 6  // GPIO6  (ADC1_CH5)
#endif
#ifndef FLEX_PIN_RING
#define FLEX_PIN_RING 7    // GPIO7  (ADC1_CH6)
#endif
#ifndef FLEX_PIN_PINKY
#define FLEX_PIN_PINKY 1   // GPIO1  (ADC1_CH0)
#endif

// Optional 1S Li-Po Battery (3.0V - 4.2V, 1500mAh) Voltage Divider Sense Pin
#ifndef BATTERY_ADC_PIN
#define BATTERY_ADC_PIN 2  // GPIO2  (ADC1_CH1)
#endif

// TDK InvenSense MPU-6050 (GY-521 Breakout) I2C Configuration on ESP32-S3
#ifndef IMU_I2C_SDA
#define IMU_I2C_SDA 8      // GPIO8  (ESP32-S3 Default I2C SDA)
#endif
#ifndef IMU_I2C_SCL
#define IMU_I2C_SCL 9      // GPIO9  (ESP32-S3 Default I2C SCL)
#endif
#ifndef IMU_I2C_CLOCK_HZ
#define IMU_I2C_CLOCK_HZ 400000UL // 400 kHz Fast-Mode I2C
#endif
#ifndef MPU6050_I2C_ADDR
#define MPU6050_I2C_ADDR 0x68     // 0x68 (AD0 = LOW) or 0x69 (AD0 = HIGH)
#endif

struct SensorSample {
    float flex[FLEX_SENSOR_COUNT];       // Normalized finger flexion: 0.0 (flat ~25kOhm) to 1.0 (bent ~125kOhm)
    uint16_t rawFlex[FLEX_SENSOR_COUNT]; // Raw 12-bit ADC readings (0 - 4095)
    float accel[3];                      // MPU-6050 3-Axis Accelerometer: ax, ay, az in m/s^2
    float gyro[3];                       // MPU-6050 3-Axis Gyroscope: gx, gy, gz in deg/s
    uint32_t timestamp;                  // Acquisition timestamp (ms)
};

struct CalibrationConfig {
    uint16_t openHandAdc[FLEX_SENSOR_COUNT]; // Baseline ADC when hand is fully open (~25kOhm flat)
    uint16_t fistAdc[FLEX_SENSOR_COUNT];     // Baseline ADC when hand is in full fist (~45k-125kOhm bent)
};

// Initializes ESP32-S3 ADC1 pins and wakes up the MPU-6050 over 400 kHz I2C
void initSensors();

// Reads all 5 Spectra Symbol flex sensors and the 6-axis MPU-6050 IMU into a single SensorSample
bool readSensorSample(SensorSample& sample);

// Returns true if the MPU-6050 responded on the I2C bus
bool isImuOnline();

// Calibrates open-hand baseline values (Rest Pose)
void calibrateOpenHand();

// Calibrates closed-fist baseline values (Fist Pose)
void calibrateFist();

// Retrieves current calibration configuration
const CalibrationConfig& getCalibrationConfig();

// Overrides calibration configuration (e.g. loaded from NVS)
void setCalibrationConfig(const CalibrationConfig& config);

#endif // SIGNKO_SENSORS_H
