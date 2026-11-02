#ifndef SIGNKO_TEST_BLE_PIPELINE_H
#define SIGNKO_TEST_BLE_PIPELINE_H

#include "test_runner.h"
#include <cstdio>
#include <cstring>
#include <string>

namespace TestBLE {

// UUID definitions from ble_pipeline.h and ble_service.dart
constexpr const char* EXP_SERVICE_UUID   = "0000ffe0-0000-1000-8000-00805f9b34fb";
constexpr const char* EXP_TELEMETRY_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb";
constexpr const char* EXP_HAPTIC_UUID    = "0000ffe2-0000-1000-8000-00805f9b34fb";

inline std::string formatGesturePayload(const char* label, float confidence) {
    char buffer[64];
    std::snprintf(buffer, sizeof(buffer), "{\"gesture\":\"%s\",\"confidence\":%.2f}", label, confidence);
    return std::string(buffer);
}

inline std::string formatTelemetryPayload(
    float f0, float f1, float f2, float f3, float f4,
    float ax, float ay, float az
) {
    char buffer[96];
    std::snprintf(
        buffer, sizeof(buffer),
        "{\"f\":[%.2f,%.2f,%.2f,%.2f,%.2f],\"a\":[%.1f,%.1f,%.1f]}",
        f0, f1, f2, f3, f4, ax, ay, az
    );
    return std::string(buffer);
}

enum DecodedAction {
    ACTION_NONE,
    ACTION_HAPTIC_OFF,
    ACTION_HAPTIC_SHORT,
    ACTION_HAPTIC_DOUBLE,
    ACTION_HAPTIC_LONG,
    ACTION_CALIB_OPEN,
    ACTION_CALIB_FIST
};

inline DecodedAction decodeIncomingBleByte(uint8_t cmd) {
    switch (cmd) {
        case 0x00: return ACTION_HAPTIC_OFF;
        case 0x01: return ACTION_HAPTIC_SHORT;
        case 0x02: return ACTION_HAPTIC_DOUBLE;
        case 0x03: return ACTION_HAPTIC_LONG;
        case 0x10: return ACTION_CALIB_OPEN;
        case 0x11: return ACTION_CALIB_FIST;
        default:   return ACTION_NONE;
    }
}

bool testGattServiceUuids() {
    ASSERT_EQ(36, std::strlen(EXP_SERVICE_UUID));
    ASSERT_EQ(36, std::strlen(EXP_TELEMETRY_UUID));
    ASSERT_EQ(36, std::strlen(EXP_HAPTIC_UUID));
    return true;
}

bool testGesturePayloadFormatting() {
    std::string payload = formatGesturePayload("SALAMAT", 0.96f);
    ASSERT_EQ("{\"gesture\":\"SALAMAT\",\"confidence\":0.96}", payload);

    std::string singleLetter = formatGesturePayload("A", 0.88f);
    ASSERT_EQ("{\"gesture\":\"A\",\"confidence\":0.88}", singleLetter);
    return true;
}

bool testTelemetryPayloadFormatting() {
    std::string payload = formatTelemetryPayload(
        0.10f, 0.20f, 0.30f, 0.40f, 0.50f,
        0.0f, 0.0f, 9.8f
    );
    ASSERT_EQ("{\"f\":[0.10,0.20,0.30,0.40,0.50],\"a\":[0.0,0.0,9.8]}", payload);
    return true;
}

bool testBleCommandByteDecoding() {
    ASSERT_EQ(ACTION_HAPTIC_OFF, decodeIncomingBleByte(0x00));
    ASSERT_EQ(ACTION_HAPTIC_SHORT, decodeIncomingBleByte(0x01));
    ASSERT_EQ(ACTION_HAPTIC_DOUBLE, decodeIncomingBleByte(0x02));
    ASSERT_EQ(ACTION_HAPTIC_LONG, decodeIncomingBleByte(0x03));
    ASSERT_EQ(ACTION_CALIB_OPEN, decodeIncomingBleByte(0x10));
    ASSERT_EQ(ACTION_CALIB_FIST, decodeIncomingBleByte(0x11));

    // Unknown commands are ignored safely
    ASSERT_EQ(ACTION_NONE, decodeIncomingBleByte(0xFF));
    ASSERT_EQ(ACTION_NONE, decodeIncomingBleByte(0x42));
    return true;
}

inline void runAll() {
    RUN_TEST(BLE, testGattServiceUuids);
    RUN_TEST(BLE, testGesturePayloadFormatting);
    RUN_TEST(BLE, testTelemetryPayloadFormatting);
    RUN_TEST(BLE, testBleCommandByteDecoding);
}

} // namespace TestBLE

#endif // SIGNKO_TEST_BLE_PIPELINE_H
