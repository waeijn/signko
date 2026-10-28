#ifndef SIGNKO_SDK_COMPAT_H
#define SIGNKO_SDK_COMPAT_H

#include <stdint.h>
#include <stddef.h>
#include <string>

#if __has_include(<Arduino.h>)
#include <Arduino.h>
#endif

#if __has_include(<freertos/FreeRTOS.h>)
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/queue.h>
#elif __has_include(<FreeRTOS.h>)
#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>
#endif

#if __has_include(<BLEDevice.h>)
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#endif

#endif // SIGNKO_SDK_COMPAT_H
