#include "haptics.h"
#include "sensors.h"
#include "tinyml_pipeline.h"
#include "ble_pipeline.h"

// Callback triggered whenever the TinyML engine recognizes a sign gesture
static void onGestureDetected(const char* gestureLabel, float confidence) {
    Serial.print("[GESTURE] Recognized: ");
    Serial.print(gestureLabel);
    Serial.print(" | Conf: ");
    Serial.println(confidence);

    // 1. Dispatch over Bluetooth Low Energy to the Flutter mobile app
    notifyGesture(gestureLabel, confidence);

    // 2. Provide tactile confirmation pulse on the glove
    triggerHaptic(HAPTIC_SHORT_PULSE);
}

void setup() {
    Serial.begin(115200);
    delay(200); // Settling delay for Serial monitor

    Serial.println("==========================================");
    Serial.println("        SignKo ESP32 Smart Glove         ");
    Serial.println("==========================================");

    // 1. Initialize vibration actuator GPIO & FreeRTOS worker queue
    initHaptics();

    // 2. Initialize ADC pins for 5 resistive flex sensors & IMU I2C bus
    initSensors();

    // 3. Initialize sliding-window time-series buffer and TinyML inference task
    initTinyMLPipeline(onGestureDetected);

    // 4. Initialize Bluetooth Low Energy GATT Server and advertising
    initBLEPipeline();

    Serial.println("[SYS] All pipelines online. Starting sensor sampling loop...");
}

void loop() {
    SensorSample sample;

    // Read flex sensor ADC values and IMU orientation
    if (readSensorSample(sample)) {
        // Feed time-series frame into the non-blocking TinyML sliding window
        enqueueSensorSample(sample);
    }

    // Run at 50 Hz sampling frequency (20ms non-blocking interval)
    vTaskDelay(pdMS_TO_TICKS(20));
}
