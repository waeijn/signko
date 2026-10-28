#ifndef SIGNKO_COMPAT_ARDUINO_H
#define SIGNKO_COMPAT_ARDUINO_H

#include <stdint.h>
#include <stddef.h>
#include <string>

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

#endif // SIGNKO_COMPAT_ARDUINO_H
