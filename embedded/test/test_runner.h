#ifndef SIGNKO_TEST_RUNNER_H
#define SIGNKO_TEST_RUNNER_H

#include <iostream>
#include <string>
#include <cmath>
#include <vector>

struct TestResult {
    std::string suiteName;
    std::string testName;
    bool passed;
    std::string message;
};

static std::vector<TestResult> g_testResults;

#define ASSERT_TRUE(condition) \
    do { \
        if (!(condition)) { \
            std::cerr << "  [FAIL] " << __FILE__ << ":" << __LINE__ << " - Assertion failed: " #condition << "\n"; \
            return false; \
        } \
    } while (0)

#define ASSERT_FALSE(condition) \
    do { \
        if (condition) { \
            std::cerr << "  [FAIL] " << __FILE__ << ":" << __LINE__ << " - Expected false: " #condition << "\n"; \
            return false; \
        } \
    } while (0)

#define ASSERT_EQ(expected, actual) \
    do { \
        if ((expected) != (actual)) { \
            std::cerr << "  [FAIL] " << __FILE__ << ":" << __LINE__ << " - Expected " << (expected) << " but got " << (actual) << "\n"; \
            return false; \
        } \
    } while (0)

#define ASSERT_FLOAT_NEAR(expected, actual, tolerance) \
    do { \
        if (std::fabs((expected) - (actual)) > (tolerance)) { \
            std::cerr << "  [FAIL] " << __FILE__ << ":" << __LINE__ << " - Expected ~" << (expected) << " (+/-" << (tolerance) << ") but got " << (actual) << "\n"; \
            return false; \
        } \
    } while (0)

#define RUN_TEST(suite, testFunc) \
    do { \
        std::cout << "[RUN ] " #suite "::" #testFunc << "\n"; \
        bool success = testFunc(); \
        g_testResults.push_back({ #suite, #testFunc, success, success ? "OK" : "Assertion Failed" }); \
        if (success) { \
            std::cout << "[PASS] " #suite "::" #testFunc << "\n"; \
        } else { \
            std::cout << "[FAIL] " #suite "::" #testFunc << "\n"; \
        } \
    } while (0)

#endif // SIGNKO_TEST_RUNNER_H
