#ifndef SIGNKO_BLE_PIPELINE_H
#define SIGNKO_BLE_PIPELINE_H

#include "sensors.h"
#include "haptics.h"

#define SIGNKO_SERVICE_UUID        "0000ffe0-0000-1000-8000-00805f9b34fb"
#define SIGNKO_TELEMETRY_CHAR_UUID "0000ffe1-0000-1000-8000-00805f9b34fb"
#define SIGNKO_HAPTIC_CHAR_UUID    "0000ffe2-0000-1000-8000-00805f9b34fb"

// Initializes the ESP32 BLE GATT Server and advertising
void initBLEPipeline();

// Returns true if a central device (e.g. Flutter mobile app) is connected
bool isDeviceConnected();

// Sends a recognized gesture label and confidence via BLE Notify
void notifyGesture(const char* gestureLabel, float confidence);

// Streams raw/normalized sensor telemetry via BLE Notify (optional debugging stream)
void notifyTelemetry(const SensorSample& sample);

#endif // SIGNKO_BLE_PIPELINE_H
