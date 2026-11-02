#include "test_runner.h"
#include "test_sensors.h"
#include "test_tinyml_pipeline.h"
#include "test_ble_pipeline.h"
#include <iostream>
#include <iomanip>

int main() {
    std::cout << "==================================================\n";
    std::cout << "      SignKo Embedded Pipeline Test Suite         \n";
    std::cout << "==================================================\n\n";

    TestSensors::runAll();
    TestTinyML::runAll();
    TestBLE::runAll();

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
