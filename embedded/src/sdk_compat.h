#ifndef SIGNKO_SDK_COMPAT_H
#define SIGNKO_SDK_COMPAT_H

#include <stdint.h>
#include <stddef.h>
#include <string>

#if __has_include(<Arduino.h>)
#include <Arduino.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/queue.h>
#else
// IDE IntelliSense fallback definitions when the ESP32 PlatformIO SDK is not installed locally.
// When compiled by PlatformIO/Arduino for ESP32, the real SDK headers above are used automatically.

#ifndef HIGH
#define HIGH 0x1
#endif
#ifndef LOW
#define LOW  0x0
#endif
#ifndef OUTPUT
#define OUTPUT 0x03
#endif

inline void pinMode(uint8_t, uint8_t) {}
inline void digitalWrite(uint8_t, uint8_t) {}

struct HardwareSerialStub {
    void begin(unsigned long) {}
    void println(const char*) {}
};
static HardwareSerialStub Serial;

// FreeRTOS fallback definitions
typedef void* QueueHandle_t;
typedef void* TaskHandle_t;
typedef int BaseType_t;
typedef uint32_t TickType_t;
typedef void (*TaskFunction_t)(void*);

#ifndef pdTRUE
#define pdTRUE 1
#endif
#ifndef portMAX_DELAY
#define portMAX_DELAY 0xFFFFFFFFUL
#endif
#ifndef pdMS_TO_TICKS
#define pdMS_TO_TICKS(ms) ((TickType_t)(ms))
#endif

inline QueueHandle_t xQueueCreate(uint32_t, uint32_t) { return nullptr; }
inline BaseType_t xQueueReceive(QueueHandle_t, void*, TickType_t) { return pdTRUE; }
inline BaseType_t xQueueSend(QueueHandle_t, const void*, TickType_t) { return pdTRUE; }
inline BaseType_t xQueueReset(QueueHandle_t) { return pdTRUE; }
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
#endif // __has_include(<Arduino.h>)

#if __has_include(<BLEDevice.h>)
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#else
// BLE IDE IntelliSense fallback definitions
class BLEDescriptor {};
class BLE2902 : public BLEDescriptor {};
class BLEServer;
class BLECharacteristic;

class BLEServerCallbacks {
public:
    virtual ~BLEServerCallbacks() = default;
    virtual void onConnect(BLEServer*) {}
    virtual void onDisconnect(BLEServer*) {}
};

class BLECharacteristicCallbacks {
public:
    virtual ~BLECharacteristicCallbacks() = default;
    virtual void onWrite(BLECharacteristic*) {}
};

class BLECharacteristic {
public:
    static const uint32_t PROPERTY_READ     = 1 << 0;
    static const uint32_t PROPERTY_WRITE    = 1 << 1;
    static const uint32_t PROPERTY_NOTIFY   = 1 << 2;
    static const uint32_t PROPERTY_WRITE_NR = 1 << 3;

    void addDescriptor(BLEDescriptor*) {}
    void setCallbacks(BLECharacteristicCallbacks*) {}
    std::string getValue() { return ""; }
};

class BLEService {
public:
    BLECharacteristic* createCharacteristic(const char*, uint32_t) { return nullptr; }
    void start() {}
};

class BLEServer {
public:
    void setCallbacks(BLEServerCallbacks*) {}
    BLEService* createService(const char*) { return nullptr; }
    void startAdvertising() {}
};

class BLEAdvertising {
public:
    void addServiceUUID(const char*) {}
    void setScanResponse(bool) {}
    void setMinPreferred(uint8_t) {}
};

class BLEDevice {
public:
    static void init(const char*) {}
    static BLEServer* createServer() { return nullptr; }
    static BLEAdvertising* getAdvertising() { return nullptr; }
    static void startAdvertising() {}
};
#endif // __has_include(<BLEDevice.h>)

#endif // SIGNKO_SDK_COMPAT_H
