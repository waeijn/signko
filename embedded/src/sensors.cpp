#include "sensors.h"
#include <algorithm>

// MPU-6050 Register Map
static constexpr uint8_t MPU6050_REG_PWR_MGMT_1   = 0x6B;
static constexpr uint8_t MPU6050_REG_GYRO_CONFIG  = 0x1B;
static constexpr uint8_t MPU6050_REG_ACCEL_CONFIG = 0x1C;
static constexpr uint8_t MPU6050_REG_ACCEL_XOUT_H = 0x3B;

// MPU-6050 16-bit Scale Factors (+/-2g and +/-250 deg/s)
static constexpr float MPU6050_ACCEL_LSB_PER_G     = 16384.0f;
static constexpr float MPU6050_GYRO_LSB_PER_DEG_S  = 131.0f;
static constexpr float STANDARD_GRAVITY_MS2        = 9.80665f;

static const uint8_t FLEX_PINS[FLEX_SENSOR_COUNT] = {
    FLEX_PIN_THUMB,
    FLEX_PIN_INDEX,
    FLEX_PIN_MIDDLE,
    FLEX_PIN_RING,
    FLEX_PIN_PINKY
};

// Default 12-bit ADC (0 - 4095) calibration for Spectra Symbol FS-L-0055-253-ST (25kOhm flat -> 45k-125kOhm bent)
// Supports both pull-down and pull-up voltage divider topologies via signed interpolation.
static CalibrationConfig currentCalibration = {
    .openHandAdc = { 1425, 1425, 1425, 1425, 1425 },
    .fistAdc     = { 3000, 3000, 3000, 3000, 3000 }
};

static bool imuConnected = false;

static uint16_t readAveragedAdc(uint8_t pin, uint8_t samples = 4) {
    uint32_t sum = 0;
    for (uint8_t i = 0; i < samples; ++i) {
        sum += analogRead(pin);
    }
    return static_cast<uint16_t>(sum / samples);
}

static bool writeMpuRegister(uint8_t reg, uint8_t value) {
    Wire.beginTransmission(MPU6050_I2C_ADDR);
    Wire.write(reg);
    Wire.write(value);
    return (Wire.endTransmission(true) == 0);
}

void initSensors() {
    // 1. Configure ESP32-S3 12-bit ADC1 resolution and 11dB attenuation (full 0V - 3.3V divider span)
    analogReadResolution(12);
    analogSetAttenuation(ADC_11db);
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        pinMode(FLEX_PINS[i], INPUT);
    }

    // 2. Initialize 400 kHz I2C bus and wake up MPU-6050 (GY-521)
    Wire.begin(IMU_I2C_SDA, IMU_I2C_SCL, IMU_I2C_CLOCK_HZ);
    Wire.setClock(IMU_I2C_CLOCK_HZ);

    if (writeMpuRegister(MPU6050_REG_PWR_MGMT_1, 0x00)) {
        // Configure +/-2g full-scale accelerometer and +/-250 deg/s gyroscope
        writeMpuRegister(MPU6050_REG_ACCEL_CONFIG, 0x00);
        writeMpuRegister(MPU6050_REG_GYRO_CONFIG, 0x00);
        imuConnected = true;
        Serial.println("[SENSORS] ESP32-S3 ADC1 flex array & MPU-6050 (0x68 @ 400kHz) online.");
    } else {
        imuConnected = false;
        Serial.println("[SENSORS] ESP32-S3 ADC1 flex array initialized (MPU-6050 not detected; using fallback).");
    }
}

bool readSensorSample(SensorSample& sample) {
    sample.timestamp = millis();

    // 1. Read and normalize all 5 Spectra Symbol FS-L-0055-253-ST flex sensors
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        uint16_t raw = readAveragedAdc(FLEX_PINS[i]);
        sample.rawFlex[i] = raw;

        int32_t openVal = static_cast<int32_t>(currentCalibration.openHandAdc[i]);
        int32_t fistVal = static_cast<int32_t>(currentCalibration.fistAdc[i]);
        int32_t span    = fistVal - openVal;

        if (span != 0) {
            float normalized = static_cast<float>(static_cast<int32_t>(raw) - openVal) / static_cast<float>(span);
            sample.flex[i] = std::max(0.0f, std::min(1.0f, normalized));
        } else {
            sample.flex[i] = 0.0f;
        }
    }

    // 2. Burst-read 14 bytes from MPU-6050 (Accel X/Y/Z, Temp, Gyro X/Y/Z)
    if (imuConnected) {
        Wire.beginTransmission(MPU6050_I2C_ADDR);
        Wire.write(MPU6050_REG_ACCEL_XOUT_H);
        if (Wire.endTransmission(false) == 0 &&
            Wire.requestFrom(static_cast<uint8_t>(MPU6050_I2C_ADDR), static_cast<uint8_t>(14), static_cast<uint8_t>(1)) == 14) {

            int16_t rawAx = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();
            int16_t rawAy = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();
            int16_t rawAz = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();
            (void)Wire.read(); (void)Wire.read(); // Skip internal temperature (2 bytes)
            int16_t rawGx = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();
            int16_t rawGy = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();
            int16_t rawGz = (static_cast<int16_t>(Wire.read()) << 8) | Wire.read();

            sample.accel[0] = (static_cast<float>(rawAx) / MPU6050_ACCEL_LSB_PER_G) * STANDARD_GRAVITY_MS2;
            sample.accel[1] = (static_cast<float>(rawAy) / MPU6050_ACCEL_LSB_PER_G) * STANDARD_GRAVITY_MS2;
            sample.accel[2] = (static_cast<float>(rawAz) / MPU6050_ACCEL_LSB_PER_G) * STANDARD_GRAVITY_MS2;

            sample.gyro[0]  = static_cast<float>(rawGx) / MPU6050_GYRO_LSB_PER_DEG_S;
            sample.gyro[1]  = static_cast<float>(rawGy) / MPU6050_GYRO_LSB_PER_DEG_S;
            sample.gyro[2]  = static_cast<float>(rawGz) / MPU6050_GYRO_LSB_PER_DEG_S;
            return true;
        }
    }

    // Fallback baseline if MPU-6050 is disconnected during bench testing
    sample.accel[0] = 0.0f;
    sample.accel[1] = 0.0f;
    sample.accel[2] = STANDARD_GRAVITY_MS2;
    sample.gyro[0]  = 0.0f;
    sample.gyro[1]  = 0.0f;
    sample.gyro[2]  = 0.0f;

    return true;
}

bool isImuOnline() {
    return imuConnected;
}

void calibrateOpenHand() {
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        currentCalibration.openHandAdc[i] = readAveragedAdc(FLEX_PINS[i], 16);
    }
    Serial.println("[CALIB] Open Hand (Rest Pose ~25kOhm) baseline captured.");
}

void calibrateFist() {
    for (uint8_t i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        currentCalibration.fistAdc[i] = readAveragedAdc(FLEX_PINS[i], 16);
    }
    Serial.println("[CALIB] Fist Pose (Bent ~45k-125kOhm) baseline captured.");
}

const CalibrationConfig& getCalibrationConfig() {
    return currentCalibration;
}

void setCalibrationConfig(const CalibrationConfig& config) {
    currentCalibration = config;
}
