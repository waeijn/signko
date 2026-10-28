#ifndef SIGNKO_COMPAT_FREERTOS_QUEUE_H
#define SIGNKO_COMPAT_FREERTOS_QUEUE_H

#include "FreeRTOS.h"

inline QueueHandle_t xQueueCreate(uint32_t, uint32_t) { return nullptr; }
inline BaseType_t xQueueReceive(QueueHandle_t, void*, TickType_t) { return pdTRUE; }
inline BaseType_t xQueueSend(QueueHandle_t, const void*, TickType_t) { return pdTRUE; }
inline BaseType_t xQueueReset(QueueHandle_t) { return pdTRUE; }

#endif // SIGNKO_COMPAT_FREERTOS_QUEUE_H
