#include "sensors.h"
#include <algorithm>

static const uint8_t FLEX_PINS[FLEX_SENSOR_COUNT] = {
    FLEX_PIN_THUMB,
    FLEX_PIN_INDEX,
    FLEX_PIN_MIDDLE,
    FLEX_PIN_RING,
    FLEX_PIN_PINKY
};

// Default calibration baseline: 12-bit ADC (0 - 4095)
static CalibrationConfig currentCalibration = {
    .openHandAdc = { 1500, 1500, 1500, 1500, 1500 },
    .fistAdc     = { 3200, 3200, 3200, 3200, 3200 }
};

static uint16_t readAveragedAdc(uint8_t pin, uint8_t samples = 4) {
    uint32_t sum = 0;
    for (uint8_t i = 0; i < samples; ++i) {
        sum += analogRead(pin);
    }
    return static_cast<uint16_t>(sum / samples);
}

void initSensors() {
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        pinMode(FLEX_PINS[i], INPUT);
    }
    Serial.println("[SENSORS] Flex ADC pins and IMU bus initialized.");
}

bool readSensorSample(SensorSample& sample) {
    sample.timestamp = millis();

    // 1. Read flex sensors and normalize
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        uint16_t raw = readAveragedAdc(FLEX_PINS[i]);
        sample.rawFlex[i] = raw;

        uint16_t openVal = currentCalibration.openHandAdc[i];
        uint16_t fistVal = currentCalibration.fistAdc[i];

        if (fistVal > openVal) {
            float normalized = static_cast<float>(raw - openVal) / static_cast<float>(fistVal - openVal);
            sample.flex[i] = std::max(0.0f, std::min(1.0f, normalized));
        } else {
            sample.flex[i] = 0.0f;
        }
    }

    // 2. IMU Reading (Placeholder: Accelerometer & Gyroscope)
    // Replace with I2C MPU-6050 / BNO085 driver calls when hardware is attached
    sample.accel[0] = 0.0f;   // ax (m/s^2)
    sample.accel[1] = 0.0f;   // ay (m/s^2)
    sample.accel[2] = 9.81f;  // az (gravity baseline: 1g)
    sample.gyro[0]  = 0.0f;   // gx (deg/s)
    sample.gyro[1]  = 0.0f;   // gy (deg/s)
    sample.gyro[2]  = 0.0f;   // gz (deg/s)

    return true;
}

void calibrateOpenHand() {
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        currentCalibration.openHandAdc[i] = readAveragedAdc(FLEX_PINS[i], 16);
    }
    Serial.println("[CALIB] Open Hand (Rest Pose) baseline captured.");
}

void calibrateFist() {
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        currentCalibration.fistAdc[i] = readAveragedAdc(FLEX_PINS[i], 16);
    }
    Serial.println("[CALIB] Fist Pose baseline captured.");
}

const CalibrationConfig& getCalibrationConfig() {
    return currentCalibration;
}

void setCalibrationConfig(const CalibrationConfig& config) {
    currentCalibration = config;
}
