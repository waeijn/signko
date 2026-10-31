#ifndef SIGNKO_TINYML_PIPELINE_H
#define SIGNKO_TINYML_PIPELINE_H

#include "sensors.h"

// Time-series feature shape for Edge Impulse 1D CNN
#define TINYML_FEATURES_PER_FRAME 11 // 5 flex + 3 accel + 3 gyro
#define TINYML_SAMPLE_RATE_HZ     50 // 50 Hz = 20ms per frame
#define TINYML_WINDOW_FRAMES      50 // 50 frames = 1000ms time window
#define TINYML_BUFFER_SIZE        (TINYML_FEATURES_PER_FRAME * TINYML_WINDOW_FRAMES)

// Classification confidence threshold to filter out uncertain noise
#define TINYML_CONFIDENCE_THRESHOLD 0.80f

// Cooldown between emitted gestures to prevent duplicate spam (milliseconds)
#define TINYML_DEBOUNCE_COOLDOWN_MS 1200

typedef void (*GestureCallback_t)(const char* gestureLabel, float confidence);

// Initializes the ring buffer and spawns the non-blocking inference FreeRTOS task on Core 1
void initTinyMLPipeline(GestureCallback_t callback);

// Feeds a new sensor sample into the time-series window (non-blocking)
void enqueueSensorSample(const SensorSample& sample);

// Returns true if the TinyML model / inference worker is active
bool isTinyMLPipelineReady();

#endif // SIGNKO_TINYML_PIPELINE_H
