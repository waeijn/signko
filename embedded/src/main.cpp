#include "haptics.h"

// BLE GATT UUIDs for SignKo Glove Service
#define SIGNKO_SERVICE_UUID        "0000ffe0-0000-1000-8000-00805f9b34fb"
#define SIGNKO_TELEMETRY_CHAR_UUID "0000ffe1-0000-1000-8000-00805f9b34fb"
#define SIGNKO_HAPTIC_CHAR_UUID    "0000ffe2-0000-1000-8000-00805f9b34fb"

static BLEServer* pServer = nullptr;
static BLECharacteristic* pTelemetryCharacteristic = nullptr;
static bool deviceConnected = false;

class SignKoServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server) override {
        (void)server;
        deviceConnected = true;
        // Brief pulse on BLE connection
        triggerHaptic(HAPTIC_SHORT_PULSE);
    }

    void onDisconnect(BLEServer* server) override {
        deviceConnected = false;
        // Alert pulse on BLE disconnection, then restart advertising
        triggerHaptic(HAPTIC_LONG_ALERT);
        server->startAdvertising();
    }
};

class HapticCharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic* pCharacteristic) override {
        std::string value = pCharacteristic->getValue();
        if (!value.empty()) {
            uint8_t cmd = static_cast<uint8_t>(value[0]);
            switch (cmd) {
                case HAPTIC_OFF:
                case HAPTIC_SHORT_PULSE:
                case HAPTIC_DOUBLE_PULSE:
                case HAPTIC_LONG_ALERT:
                    triggerHaptic(static_cast<HapticPattern>(cmd));
                    break;
                default:
                    break;
            }
        }
    }
};

void setup() {
    Serial.begin(115200);
    initHaptics();

    BLEDevice::init("SignKo ESP32 Glove");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new SignKoServerCallbacks());

    BLEService* pService = pServer->createService(SIGNKO_SERVICE_UUID);

    // Telemetry & TinyML Gesture Classification Characteristic (Notify)
    pTelemetryCharacteristic = pService->createCharacteristic(
        SIGNKO_TELEMETRY_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
    );
    pTelemetryCharacteristic->addDescriptor(new BLE2902());

    // Haptic Feedback Control Characteristic (Write / Write Without Response)
    BLECharacteristic* pHapticCharacteristic = pService->createCharacteristic(
        SIGNKO_HAPTIC_CHAR_UUID,
        BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
    );
    pHapticCharacteristic->setCallbacks(new HapticCharacteristicCallbacks());

    pService->start();

    BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SIGNKO_SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    BLEDevice::startAdvertising();

    Serial.println("[SYS] SignKo BLE Server & Haptics initialized.");
}

void loop() {
    // Sensor acquisition and Edge Impulse TinyML inference run on non-blocking intervals
    vTaskDelay(pdMS_TO_TICKS(50));
}
