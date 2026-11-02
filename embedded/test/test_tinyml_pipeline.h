#ifndef SIGNKO_TEST_TINYML_PIPELINE_H
#define SIGNKO_TEST_TINYML_PIPELINE_H

#include "test_runner.h"
#include <cstring>
#include <vector>

namespace TestTinyML {

constexpr size_t FEATURES_PER_FRAME = 11;
constexpr size_t WINDOW_FRAMES      = 50;
constexpr size_t BUFFER_SIZE        = FEATURES_PER_FRAME * WINDOW_FRAMES; // 550
constexpr size_t STRIDE_FRAMES      = 10;
constexpr uint32_t DEBOUNCE_MS      = 1200;

// Replicates the chronological unwrapping algorithm from tinyml_pipeline.cpp
inline void unwrapCircularBuffer(
    const float* featureWindow,
    uint16_t currentFrameIndex,
    size_t offset,
    size_t length,
    float* out_ptr
) {
    size_t startIdx = (static_cast<size_t>(currentFrameIndex) * FEATURES_PER_FRAME + offset) % BUFFER_SIZE;
    for (size_t i = 0; i < length; ++i) {
        out_ptr[i] = featureWindow[(startIdx + i) % BUFFER_SIZE];
    }
}

inline bool isBackgroundLabel(const char* label) {
    return (strcmp(label, "idle") == 0 ||
            strcmp(label, "IDLE") == 0 ||
            strcmp(label, "_noise") == 0 ||
            strcmp(label, "unknown") == 0);
}

bool testChronologicalUnwrappingNoWrap() {
    // Window filled exactly from frame 0 to 49, currentFrameIndex is 0 (oldest is frame 0)
    float buffer[BUFFER_SIZE];
    for (size_t f = 0; f < WINDOW_FRAMES; ++f) {
        for (size_t feat = 0; feat < FEATURES_PER_FRAME; ++feat) {
            buffer[f * FEATURES_PER_FRAME + feat] = static_cast<float>(f);
        }
    }

    float unwrapped[BUFFER_SIZE];
    unwrapCircularBuffer(buffer, 0, 0, BUFFER_SIZE, unwrapped);

    // Verify first feature of each frame strictly ascends: 0, 1, 2, ..., 49
    for (size_t f = 0; f < WINDOW_FRAMES; ++f) {
        ASSERT_FLOAT_NEAR(static_cast<float>(f), unwrapped[f * FEATURES_PER_FRAME], 0.001f);
    }
    return true;
}

bool testChronologicalUnwrappingWithArbitraryWrap() {
    // Current pointer is at frame 25. Oldest frame is frame 25, newest is frame 24.
    float buffer[BUFFER_SIZE];
    uint16_t currentFrameIndex = 25;

    // Simulate time-stamped frames: chronological timestamp 0 to 49
    for (size_t timeStep = 0; timeStep < WINDOW_FRAMES; ++timeStep) {
        size_t writeFrame = (currentFrameIndex + timeStep) % WINDOW_FRAMES;
        for (size_t feat = 0; feat < FEATURES_PER_FRAME; ++feat) {
            buffer[writeFrame * FEATURES_PER_FRAME + feat] = static_cast<float>(timeStep);
        }
    }

    float unwrapped[BUFFER_SIZE];
    unwrapCircularBuffer(buffer, currentFrameIndex, 0, BUFFER_SIZE, unwrapped);

    // After unwrapping, frame 0 must have timestamp 0, frame 49 must have timestamp 49
    for (size_t f = 0; f < WINDOW_FRAMES; ++f) {
        ASSERT_FLOAT_NEAR(static_cast<float>(f), unwrapped[f * FEATURES_PER_FRAME], 0.001f);
    }
    return true;
}

bool testWindowWarmUpGating() {
    // Before 50 frames, inference should not trigger
    for (uint32_t frames = 0; frames < WINDOW_FRAMES; ++frames) {
        bool shouldRun = (frames >= WINDOW_FRAMES) && (frames % STRIDE_FRAMES == 0);
        ASSERT_FALSE(shouldRun);
    }

    // At exactly frame 50 (warm-up complete & multiple of 10)
    bool shouldRunAt50 = (50 >= WINDOW_FRAMES) && (50 % STRIDE_FRAMES == 0);
    ASSERT_TRUE(shouldRunAt50);

    // At frame 55 (warm, but not a stride boundary)
    bool shouldRunAt55 = (55 >= WINDOW_FRAMES) && (55 % STRIDE_FRAMES == 0);
    ASSERT_FALSE(shouldRunAt55);

    // At frame 60 (stride boundary)
    bool shouldRunAt60 = (60 >= WINDOW_FRAMES) && (60 % STRIDE_FRAMES == 0);
    ASSERT_TRUE(shouldRunAt60);
    return true;
}

bool testDebounceCooldown() {
    uint32_t lastGestureTime = 5000;

    // 500ms later (< 1200ms cooldown) -> rejected
    uint32_t now1 = 5500;
    bool allowed1 = (now1 - lastGestureTime >= DEBOUNCE_MS);
    ASSERT_FALSE(allowed1);

    // 1199ms later (< 1200ms cooldown) -> rejected
    uint32_t now2 = 6199;
    bool allowed2 = (now2 - lastGestureTime >= DEBOUNCE_MS);
    ASSERT_FALSE(allowed2);

    // 1200ms later (cooldown elapsed) -> allowed
    uint32_t now3 = 6200;
    bool allowed3 = (now3 - lastGestureTime >= DEBOUNCE_MS);
    ASSERT_TRUE(allowed3);

    // 2500ms later -> allowed
    uint32_t now4 = 7500;
    bool allowed4 = (now4 - lastGestureTime >= DEBOUNCE_MS);
    ASSERT_TRUE(allowed4);
    return true;
}

bool testBackgroundClassFiltering() {
    ASSERT_TRUE(isBackgroundLabel("idle"));
    ASSERT_TRUE(isBackgroundLabel("IDLE"));
    ASSERT_TRUE(isBackgroundLabel("_noise"));
    ASSERT_TRUE(isBackgroundLabel("unknown"));

    ASSERT_FALSE(isBackgroundLabel("A"));
    ASSERT_FALSE(isBackgroundLabel("THANK_YOU"));
    ASSERT_FALSE(isBackgroundLabel("FIST"));
    ASSERT_FALSE(isBackgroundLabel("GOOD_DAY"));
    return true;
}

inline void runAll() {
    RUN_TEST(TinyML, testChronologicalUnwrappingNoWrap);
    RUN_TEST(TinyML, testChronologicalUnwrappingWithArbitraryWrap);
    RUN_TEST(TinyML, testWindowWarmUpGating);
    RUN_TEST(TinyML, testDebounceCooldown);
    RUN_TEST(TinyML, testBackgroundClassFiltering);
}

} // namespace TestTinyML

#endif // SIGNKO_TEST_TINYML_PIPELINE_H
