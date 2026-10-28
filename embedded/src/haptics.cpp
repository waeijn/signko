#include "haptics.h"

static QueueHandle_t hapticQueue = nullptr;

static void hapticWorkerTask(void* pvParameters) {
    (void)pvParameters;
    HapticPattern pattern;
    for (;;) {
        if (xQueueReceive(hapticQueue, &pattern, portMAX_DELAY) == pdTRUE) {
            switch (pattern) {
                case HAPTIC_SHORT_PULSE:
                    digitalWrite(HAPTIC_PIN, HIGH);
                    vTaskDelay(pdMS_TO_TICKS(100));
                    digitalWrite(HAPTIC_PIN, LOW);
                    break;

                case HAPTIC_DOUBLE_PULSE:
                    digitalWrite(HAPTIC_PIN, HIGH);
                    vTaskDelay(pdMS_TO_TICKS(150));
                    digitalWrite(HAPTIC_PIN, LOW);
                    vTaskDelay(pdMS_TO_TICKS(100));
                    digitalWrite(HAPTIC_PIN, HIGH);
                    vTaskDelay(pdMS_TO_TICKS(150));
                    digitalWrite(HAPTIC_PIN, LOW);
                    break;

                case HAPTIC_LONG_ALERT:
                    digitalWrite(HAPTIC_PIN, HIGH);
                    vTaskDelay(pdMS_TO_TICKS(500));
                    digitalWrite(HAPTIC_PIN, LOW);
                    break;

                case HAPTIC_OFF:
                default:
                    digitalWrite(HAPTIC_PIN, LOW);
                    break;
            }
        }
    }
}

void initHaptics() {
    pinMode(HAPTIC_PIN, OUTPUT);
    digitalWrite(HAPTIC_PIN, LOW);

    if (hapticQueue == nullptr) {
        hapticQueue = xQueueCreate(4, sizeof(HapticPattern));
        xTaskCreatePinnedToCore(
            hapticWorkerTask,
            "HapticWorker",
            2048,
            nullptr,
            1,
            nullptr,
            1 // Run on Application Core (Core 1) to avoid interfering with BLE on Core 0
        );
    }
}

void triggerHaptic(HapticPattern pattern) {
    if (hapticQueue == nullptr) {
        return;
    }
    if (pattern == HAPTIC_OFF) {
        xQueueReset(hapticQueue);
        digitalWrite(HAPTIC_PIN, LOW);
        return;
    }
    xQueueSend(hapticQueue, &pattern, 0);
}
