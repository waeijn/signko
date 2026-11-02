#include "test_runner.h"
#include "test_sensors.h"
#include "test_tinyml_pipeline.h"
#include "test_ble_pipeline.h"
#include "sensors.h"
#include "tinyml_pipeline.h"
#include "ble_pipeline.h"
#include "haptics.h"
#include <iostream>
#include <iomanip>

namespace TestFirmwareIntegration {

static void dummyGestureCallback(const char*, float) {}

bool testSensorsModuleIntegration() {
    initSensors();

    // Verify default calibration and custom calibration round-trip
    CalibrationConfig customCfg = {
        .openHandAdc = { 1000, 1000, 1000, 1000, 1000 },
        .fistAdc     = { 3000, 3000, 3000, 3000, 3000 }
    };
    setCalibrationConfig(customCfg);

    const CalibrationConfig& activeCfg = getCalibrationConfig();
    for (int i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        ASSERT_EQ(1000, activeCfg.openHandAdc[i]);
        ASSERT_EQ(3000, activeCfg.fistAdc[i]);
    }

    // With stub analogRead returning 2048: (2048 - 1000) / (3000 - 1000) = 1048 / 2000 = 0.524f
    SensorSample sample = {};
    ASSERT_TRUE(readSensorSample(sample));
    for (int i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        ASSERT_EQ(2048, sample.rawFlex[i]);
        ASSERT_FLOAT_NEAR(0.524f, sample.flex[i], 0.001f);
    }

    // Verify live calibration capture updates calibration struct
    calibrateOpenHand();
    ASSERT_EQ(2048, getCalibrationConfig().openHandAdc[0]);
    return true;
}

bool testPipelinesInitializationIntegration() {
    initHaptics();
    triggerHaptic(HAPTIC_SHORT_PULSE);
    triggerHaptic(HAPTIC_OFF);

    initTinyMLPipeline(dummyGestureCallback);
    ASSERT_TRUE(isTinyMLPipelineReady());

    SensorSample sample = {};
    enqueueSensorSample(sample);

    initBLEPipeline();
    ASSERT_FALSE(isDeviceConnected());
    notifyGesture("A", 0.95f);
    notifyTelemetry(sample);
    return true;
}

inline void runAll() {
    RUN_TEST(Integration, testSensorsModuleIntegration);
    RUN_TEST(Integration, testPipelinesInitializationIntegration);
}

} // namespace TestFirmwareIntegration

int main() {
    std::cout << "==================================================\n";
    std::cout << "      SignKo Embedded Pipeline Test Suite         \n";
    std::cout << "==================================================\n\n";

    TestSensors::runAll();
    TestTinyML::runAll();
    TestBLE::runAll();
    TestFirmwareIntegration::runAll();

    size_t passed = 0;
    size_t failed = 0;

    for (const auto& res : g_testResults) {
        if (res.passed) {
            passed++;
        } else {
            failed++;
        }
    }

    std::cout << "\n==================================================\n";
    std::cout << "Test Summary: " << (passed + failed) << " total tests\n";
    std::cout << "  Passed : " << passed << "\n";
    std::cout << "  Failed : " << failed << "\n";
    std::cout << "==================================================\n";

    if (failed == 0) {
        std::cout << "[RESULT] ALL EMBEDDED PIPELINE TESTS PASSED!\n";
        return 0;
    } else {
        std::cout << "[RESULT] SOME TESTS FAILED!\n";
        return 1;
    }
}
