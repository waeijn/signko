#ifndef SIGNKO_COMPAT_FREERTOS_TASK_H
#define SIGNKO_COMPAT_FREERTOS_TASK_H

#include "FreeRTOS.h"

inline BaseType_t xTaskCreatePinnedToCore(
    TaskFunction_t,
    const char*,
    uint32_t,
    void*,
    uint32_t,
    TaskHandle_t*,
    BaseType_t
) { return pdTRUE; }

inline void vTaskDelay(const TickType_t) {}

#endif // SIGNKO_COMPAT_FREERTOS_TASK_H
