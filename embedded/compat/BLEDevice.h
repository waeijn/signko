#ifndef SIGNKO_COMPAT_BLEDEVICE_H
#define SIGNKO_COMPAT_BLEDEVICE_H

#include <stdint.h>
#include <string>

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
    void setValue(const std::string&) {}
    void setValue(uint8_t*, size_t) {}
    void notify() {}
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

#endif // SIGNKO_COMPAT_BLEDEVICE_H
