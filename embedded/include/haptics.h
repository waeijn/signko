#ifndef SIGNKO_HAPTICS_H
#define SIGNKO_HAPTICS_H

#include "sdk_compat.h"

// ESP32-S3-N16R8 GPIO driving the MOSFET gate on the 5V Vibration Module (23mm x 20.8mm, 9000 RPM, 60-90mA)
// Module VCC is supplied by the 5.0V output of the Mini DC-to-DC Boost Converter.
#ifndef HAPTIC_PIN
#define HAPTIC_PIN 14
#endif

enum HapticPattern : uint8_t {
    HAPTIC_OFF          = 0x00,
    HAPTIC_SHORT_PULSE  = 0x01, // 100ms pulse (gesture/word confirmation)
    HAPTIC_DOUBLE_PULSE = 0x02, // 2x 150ms pulse (incoming speech/text message)
    HAPTIC_LONG_ALERT   = 0x03  // 500ms pulse (connection/battery alert)
};

// Initializes the haptic actuator GPIO pin
void initHaptics();

// Triggers a non-blocking FreeRTOS task to execute the requested vibration pattern
void triggerHaptic(HapticPattern pattern);

#endif // SIGNKO_HAPTICS_H
