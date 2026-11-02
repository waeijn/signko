#include "tinyml_pipeline.h"
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/queue.h>
#include <string.h>

#if __has_include("signko_inferencing.h")
#include "signko_inferencing.h"
#define HAS_EDGE_IMPULSE_MODEL 1
#else
#define HAS_EDGE_IMPULSE_MODEL 0
#endif

static QueueHandle_t sensorSampleQueue = nullptr;
static GestureCallback_t gestureCallback = nullptr;
static float featureWindow[TINYML_BUFFER_SIZE];
static uint16_t currentFrameIndex = 0;
static uint32_t totalFramesCollected = 0;
static uint32_t lastGestureTimestamp = 0;
static bool pipelineReady = false;

#if HAS_EDGE_IMPULSE_MODEL
// Unwraps the circular buffer into chronological order [oldest_frame ... newest_frame]
// so the 1D CNN receives a contiguous temporal sequence without wrap-around discontinuities.
static int rawFeatureGet(size_t offset, size_t length, float* out_ptr) {
    size_t startIdx = (static_cast<size_t>(currentFrameIndex) * TINYML_FEATURES_PER_FRAME + offset) % TINYML_BUFFER_SIZE;
    for (size_t i = 0; i < length; ++i) {
        out_ptr[i] = featureWindow[(startIdx + i) % TINYML_BUFFER_SIZE];
    }
    return 0;
}

static bool isBackgroundLabel(const char* label) {
    return (strcmp(label, "idle") == 0 ||
            strcmp(label, "IDLE") == 0 ||
            strcmp(label, "_noise") == 0 ||
            strcmp(label, "unknown") == 0);
}
#endif

static void evaluateWindow() {
    uint32_t now = millis();
    if (now - lastGestureTimestamp < TINYML_DEBOUNCE_COOLDOWN_MS) {
        return;
    }

#if HAS_EDGE_IMPULSE_MODEL
    signal_t signal;
    signal.total_length = TINYML_BUFFER_SIZE;
    signal.get_data = &rawFeatureGet;

    ei_impulse_result_t result = { 0 };
    EI_IMPULSE_ERROR err = run_classifier(&signal, &result, false);
    if (err == EI_IMPULSE_OK) {
        size_t bestIdx = 0;
        float bestConfidence = 0.0f;

        for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
            if (result.classification[ix].value > bestConfidence) {
                bestConfidence = result.classification[ix].value;
                bestIdx = ix;
            }
        }

        const char* bestLabel = result.classification[bestIdx].label;
        if (bestConfidence >= TINYML_CONFIDENCE_THRESHOLD && !isBackgroundLabel(bestLabel)) {
            lastGestureTimestamp = now;
            if (gestureCallback) {
                gestureCallback(bestLabel, bestConfidence);
            }
        }
    }
#else
    // Placeholder heuristic for hardware bring-up prior to Edge Impulse model export:
    // Evaluates average flexion across the latest frame's 5 fingers
    float avgFlex = 0.0f;
    size_t latestFrame = (currentFrameIndex == 0 ? TINYML_WINDOW_FRAMES : currentFrameIndex) - 1;
    size_t baseIdx = latestFrame * TINYML_FEATURES_PER_FRAME;

    for (int i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        avgFlex += featureWindow[baseIdx + i];
    }
    avgFlex /= static_cast<float>(FLEX_SENSOR_COUNT);

    if (avgFlex > 0.85f) {
        lastGestureTimestamp = now;
        if (gestureCallback) {
            gestureCallback("FIST", 0.95f);
        }
    } else if (avgFlex < 0.15f && (now - lastGestureTimestamp > TINYML_DEBOUNCE_COOLDOWN_MS * 2)) {
        lastGestureTimestamp = now;
        if (gestureCallback) {
            gestureCallback("OPEN_HAND", 0.92f);
        }
    }
#endif
}

static void tinymlWorkerTask(void* pvParameters) {
    (void)pvParameters;
    SensorSample sample;

    for (;;) {
        if (xQueueReceive(sensorSampleQueue, &sample, portMAX_DELAY) == pdTRUE) {
            // Write 11 features (5 flex + 3 accel + 3 gyro) to circular sliding window
            size_t baseIdx = static_cast<size_t>(currentFrameIndex) * TINYML_FEATURES_PER_FRAME;
            for (int i = 0; i < FLEX_SENSOR_COUNT; ++i) {
                featureWindow[baseIdx + i] = sample.flex[i];
            }
            featureWindow[baseIdx + 5]  = sample.accel[0];
            featureWindow[baseIdx + 6]  = sample.accel[1];
            featureWindow[baseIdx + 7]  = sample.accel[2];
            featureWindow[baseIdx + 8]  = sample.gyro[0];
            featureWindow[baseIdx + 9]  = sample.gyro[1];
            featureWindow[baseIdx + 10] = sample.gyro[2];

            currentFrameIndex = (currentFrameIndex + 1) % TINYML_WINDOW_FRAMES;
            totalFramesCollected++;

            // Only run inference once the initial 50-frame window is full, and then every TINYML_STRIDE_FRAMES (200ms)
            if (totalFramesCollected >= TINYML_WINDOW_FRAMES &&
                (totalFramesCollected % TINYML_STRIDE_FRAMES == 0)) {
                evaluateWindow();
            }
        }
    }
}

void initTinyMLPipeline(GestureCallback_t callback) {
    gestureCallback = callback;
    memset(featureWindow, 0, sizeof(featureWindow));
    currentFrameIndex = 0;
    totalFramesCollected = 0;

    if (sensorSampleQueue == nullptr) {
        sensorSampleQueue = xQueueCreate(16, sizeof(SensorSample));
        xTaskCreatePinnedToCore(
            tinymlWorkerTask,
            "TinyMLInference",
            8192, // 8 KB stack to safely accommodate Edge Impulse TFLite Micro 1D CNN arena frames
            nullptr,
            1,
            nullptr,
            1     // Pin to Core 1 (Application Core) so Core 0 is dedicated to BLE 5.0 radio
        );
    }

    pipelineReady = true;
    Serial.println("[TINYML] Sliding-window inference pipeline initialized on ESP32-S3 Core 1.");
}

void enqueueSensorSample(const SensorSample& sample) {
    if (sensorSampleQueue != nullptr) {
        xQueueSend(sensorSampleQueue, &sample, 0); // Non-blocking queue send
    }
}

bool isTinyMLPipelineReady() {
    return pipelineReady;
}
