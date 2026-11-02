#ifndef SIGNKO_TEST_SENSORS_H
#define SIGNKO_TEST_SENSORS_H

#include "test_runner.h"
#include <algorithm>
#include <cstdint>

namespace TestSensors {

// Replicates the normalization logic from sensors.cpp for unit verification
inline float normalizeFlex(uint16_t raw, uint16_t openVal, uint16_t fistVal) {
    int32_t span = static_cast<int32_t>(fistVal) - static_cast<int32_t>(openVal);
    if (span != 0) {
        float normalized = static_cast<float>(static_cast<int32_t>(raw) - static_cast<int32_t>(openVal)) / static_cast<float>(span);
        return std::max(0.0f, std::min(1.0f, normalized));
    }
    return 0.0f;
}

// Replicates MPU-6050 conversion from raw 16-bit registers to physical units
inline float rawToAccelMs2(int16_t raw) {
    constexpr float MPU6050_ACCEL_LSB_PER_G = 16384.0f;
    constexpr float STANDARD_GRAVITY_MS2 = 9.80665f;
    return (static_cast<float>(raw) / MPU6050_ACCEL_LSB_PER_G) * STANDARD_GRAVITY_MS2;
}

inline float rawToGyroDegS(int16_t raw) {
    constexpr float MPU6050_GYRO_LSB_PER_DEG_S = 131.0f;
    return static_cast<float>(raw) / MPU6050_GYRO_LSB_PER_DEG_S;
}

bool testFlexNormalizationMidpoint() {
    uint16_t openVal = 1400;
    uint16_t fistVal = 3000;
    uint16_t midVal = 2200; // Exact midpoint (span = 1600, delta = 800)

    float normalized = normalizeFlex(midVal, openVal, fistVal);
    ASSERT_FLOAT_NEAR(0.5f, normalized, 0.001f);
    return true;
}

bool testFlexNormalizationClamping() {
    uint16_t openVal = 1500;
    uint16_t fistVal = 3000;

    // Below baseline (should clamp to 0.0)
    ASSERT_FLOAT_NEAR(0.0f, normalizeFlex(1200, openVal, fistVal), 0.001f);
    ASSERT_FLOAT_NEAR(0.0f, normalizeFlex(openVal, openVal, fistVal), 0.001f);

    // Above maximum bend (should clamp to 1.0)
    ASSERT_FLOAT_NEAR(1.0f, normalizeFlex(3500, openVal, fistVal), 0.001f);
    ASSERT_FLOAT_NEAR(1.0f, normalizeFlex(fistVal, openVal, fistVal), 0.001f);
    return true;
}

bool testFlexZeroSpanSafety() {
    // Both open and fist equal (uncalibrated or faulted)
    float result = normalizeFlex(2000, 2000, 2000);
    ASSERT_FLOAT_NEAR(0.0f, result, 0.001f);
    return true;
}

bool testMpu6050AccelConversion() {
    // 0 raw -> 0 m/s^2
    ASSERT_FLOAT_NEAR(0.0f, rawToAccelMs2(0), 0.001f);

    // 16384 raw (+1g on Z axis) -> 9.80665 m/s^2
    ASSERT_FLOAT_NEAR(9.80665f, rawToAccelMs2(16384), 0.001f);

    // -16384 raw (-1g on Z axis) -> -9.80665 m/s^2
    ASSERT_FLOAT_NEAR(-9.80665f, rawToAccelMs2(-16384), 0.001f);

    // Full scale (+2g = +32768) -> ~19.6133 m/s^2
    ASSERT_FLOAT_NEAR(19.6133f, rawToAccelMs2(32767), 0.01f);
    return true;
}

bool testMpu6050GyroConversion() {
    // 0 raw -> 0 deg/s
    ASSERT_FLOAT_NEAR(0.0f, rawToGyroDegS(0), 0.001f);

    // 131 raw -> 1.0 deg/s
    ASSERT_FLOAT_NEAR(1.0f, rawToGyroDegS(131), 0.001f);

    // 32750 raw -> 250 deg/s
    ASSERT_FLOAT_NEAR(250.0f, rawToGyroDegS(32750), 0.1f);
    return true;
}

inline void runAll() {
    RUN_TEST(Sensors, testFlexNormalizationMidpoint);
    RUN_TEST(Sensors, testFlexNormalizationClamping);
    RUN_TEST(Sensors, testFlexZeroSpanSafety);
    RUN_TEST(Sensors, testMpu6050AccelConversion);
    RUN_TEST(Sensors, testMpu6050GyroConversion);
}

} // namespace TestSensors

#endif // SIGNKO_TEST_SENSORS_H
