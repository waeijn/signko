#ifndef SIGNKO_SENSORS_H
#define SIGNKO_SENSORS_H

#include "sdk_compat.h"

// Number of flex sensors per glove (Thumb, Index, Middle, Ring, Pinky)
#define FLEX_SENSOR_COUNT 5

// ESP32 ADC1 Pins for Flex Sensors
// Note: Only ADC1 channels can be read while Wi-Fi/BLE is active.
#ifndef FLEX_PIN_THUMB
#define FLEX_PIN_THUMB 36  // ADC1_CH0 (VP)
#endif
#ifndef FLEX_PIN_INDEX
#define FLEX_PIN_INDEX 39  // ADC1_CH3 (VN)
#endif
#ifndef FLEX_PIN_MIDDLE
#define FLEX_PIN_MIDDLE 34 // ADC1_CH6
#endif
#ifndef FLEX_PIN_RING
#define FLEX_PIN_RING 35   // ADC1_CH7
#endif
#ifndef FLEX_PIN_PINKY
#define FLEX_PIN_PINKY 32  // ADC1_CH4
#endif

// IMU I2C Pins (MPU-6050 / BNO085)
#ifndef IMU_I2C_SDA
#define IMU_I2C_SDA 21
#endif
#ifndef IMU_I2C_SCL
#define IMU_I2C_SCL 22
#endif

struct SensorSample {
    float flex[FLEX_SENSOR_COUNT];     // Normalized finger flexion: 0.0 (rest/flat) to 1.0 (clenched)
    uint16_t rawFlex[FLEX_SENSOR_COUNT]; // Raw ADC readings (0 - 4095 on 12-bit ADC)
    float accel[3];                    // ax, ay, az in m/s^2
    float gyro[3];                     // gx, gy, gz in deg/s
    uint32_t timestamp;                // Acquisition timestamp (ms)
};

struct CalibrationConfig {
    uint16_t openHandAdc[FLEX_SENSOR_COUNT]; // Baseline ADC when hand is fully open
    uint16_t fistAdc[FLEX_SENSOR_COUNT];     // Baseline ADC when hand is in full fist
};

// Initializes ADC pins and I2C bus for sensors
void initSensors();

// Reads all 5 flex sensors and IMU into a single SensorSample
bool readSensorSample(SensorSample& sample);

// Calibrates open-hand baseline values (Rest Pose)
void calibrateOpenHand();

// Calibrates closed-fist baseline values (Fist Pose)
void calibrateFist();

// Retrieves current calibration configuration
const CalibrationConfig& getCalibrationConfig();

// Overrides calibration configuration (e.g. loaded from EEPROM / NVS)
void setCalibrationConfig(const CalibrationConfig& config);

#endif // SIGNKO_SENSORS_H
