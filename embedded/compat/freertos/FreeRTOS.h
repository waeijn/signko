#ifndef SIGNKO_COMPAT_FREERTOS_H
#define SIGNKO_COMPAT_FREERTOS_H

#include <stdint.h>
#include <stddef.h>

typedef void* QueueHandle_t;
typedef void* TaskHandle_t;
typedef int BaseType_t;
typedef uint32_t TickType_t;
typedef void (*TaskFunction_t)(void*);

#ifndef pdTRUE
#define pdTRUE 1
#endif
#ifndef pdFALSE
#define pdFALSE 0
#endif
#ifndef portMAX_DELAY
#define portMAX_DELAY 0xFFFFFFFFUL
#endif
#ifndef pdMS_TO_TICKS
#define pdMS_TO_TICKS(ms) ((TickType_t)(ms))
#endif

#endif // SIGNKO_COMPAT_FREERTOS_H
