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
static uint32_t lastGestureTimestamp = 0;
static bool pipelineReady = false;

#if HAS_EDGE_IMPULSE_MODEL
static int rawFeatureGet(size_t offset, size_t length, float* out_ptr) {
    memcpy(out_ptr, featureWindow + offset, length * sizeof(float));
    return 0;
}
#endif

static void runInferencePlaceholder() {
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
        for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
            if (result.classification[ix].value >= TINYML_CONFIDENCE_THRESHOLD) {
                lastGestureTimestamp = now;
                if (gestureCallback) {
                    gestureCallback(result.classification[ix].label, result.classification[ix].value);
                }
                break;
            }
        }
    }
#else
    // Placeholder inference engine for early hardware bring-up and integration testing
    // Checks average flexion across all 5 fingers to detect distinct poses
    float avgFlex = 0.0f;
    for (int i = 0; i < FLEX_SENSOR_COUNT; ++i) {
        // Look at the latest frame's flex values
        int baseIdx = ((currentFrameIndex == 0 ? TINYML_WINDOW_FRAMES : currentFrameIndex) - 1) * TINYML_FEATURES_PER_FRAME;
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
            // Write features to circular window
            size_t baseIdx = currentFrameIndex * TINYML_FEATURES_PER_FRAME;
            for (int i = 0; i < 5; ++i) featureWindow[baseIdx + i] = sample.flex[i];
            featureWindow[baseIdx + 5] = sample.accel[0];
            featureWindow[baseIdx + 6] = sample.accel[1];
            featureWindow[baseIdx + 7] = sample.accel[2];
            featureWindow[baseIdx + 8] = sample.gyro[0];
            featureWindow[baseIdx + 9] = sample.gyro[1];
            featureWindow[baseIdx + 10] = sample.gyro[2];

            currentFrameIndex = (currentFrameIndex + 1) % TINYML_WINDOW_FRAMES;

            // Trigger non-blocking inference evaluation
            runInferencePlaceholder();
        }
    }
}

void initTinyMLPipeline(GestureCallback_t callback) {
    gestureCallback = callback;
    memset(featureWindow, 0, sizeof(featureWindow));

    if (sensorSampleQueue == nullptr) {
        sensorSampleQueue = xQueueCreate(16, sizeof(SensorSample));
        xTaskCreatePinnedToCore(
            tinymlWorkerTask,
            "TinyMLInference",
            4096,
            nullptr,
            1,
            nullptr,
            1 // Pin to Core 1 (Application Core) so Core 0 is reserved for BLE stack
        );
    }

    pipelineReady = true;
    Serial.println("[TINYML] Inference pipeline and FreeRTOS task initialized on Core 1.");
}

void enqueueSensorSample(const SensorSample& sample) {
    if (sensorSampleQueue != nullptr) {
        xQueueSend(sensorSampleQueue, &sample, 0); // Non-blocking queue send
    }
}

bool isTinyMLPipelineReady() {
    return pipelineReady;
}
