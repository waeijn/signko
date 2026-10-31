#include "ble_pipeline.h"
#include <stdio.h>

static BLEServer* pServer = nullptr;
static BLECharacteristic* pTelemetryCharacteristic = nullptr;
static BLECharacteristic* pHapticCharacteristic = nullptr;
static bool deviceConnected = false;

class SignKoServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* server) override {
        (void)server;
        deviceConnected = true;
        // Brief pulse on BLE connection
        triggerHaptic(HAPTIC_SHORT_PULSE);
        Serial.println("[BLE] Central device connected.");
    }

    void onDisconnect(BLEServer* server) override {
        deviceConnected = false;
        // Alert pulse on BLE disconnection, then restart advertising
        triggerHaptic(HAPTIC_LONG_ALERT);
        Serial.println("[BLE] Device disconnected. Restarting advertising...");
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

void initBLEPipeline() {
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
    pHapticCharacteristic = pService->createCharacteristic(
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

    Serial.println("[BLE] SignKo BLE GATT Server and characteristics active.");
}

bool isDeviceConnected() {
    return deviceConnected;
}

void notifyGesture(const char* gestureLabel, float confidence) {
    if (!deviceConnected || pTelemetryCharacteristic == nullptr) {
        return;
    }

    char buffer[64];
    snprintf(buffer, sizeof(buffer), "{\"gesture\":\"%s\",\"confidence\":%.2f}", gestureLabel, confidence);
    pTelemetryCharacteristic->setValue(std::string(buffer));
    pTelemetryCharacteristic->notify();
}

void notifyTelemetry(const SensorSample& sample) {
    if (!deviceConnected || pTelemetryCharacteristic == nullptr) {
        return;
    }

    char buffer[96];
    snprintf(
        buffer, sizeof(buffer),
        "{\"f\":[%.2f,%.2f,%.2f,%.2f,%.2f],\"a\":[%.1f,%.1f,%.1f]}",
        sample.flex[0], sample.flex[1], sample.flex[2], sample.flex[3], sample.flex[4],
        sample.accel[0], sample.accel[1], sample.accel[2]
    );
    pTelemetryCharacteristic->setValue(std::string(buffer));
    pTelemetryCharacteristic->notify();
}
