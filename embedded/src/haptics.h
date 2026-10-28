#ifndef SIGNKO_HAPTICS_H
#define SIGNKO_HAPTICS_H

#include "sdk_compat.h"

// GPIO driving the N-channel MOSFET gate for the 3V coin vibration motor
#ifndef HAPTIC_PIN
#define HAPTIC_PIN 23
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
