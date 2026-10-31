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
#ifndef INPUT
#define INPUT  0x00
#endif

inline void pinMode(uint8_t, uint8_t) {}
inline void digitalWrite(uint8_t, uint8_t) {}
inline int analogRead(uint8_t) { return 2048; }
inline unsigned long millis() { return 0; }
inline void delay(unsigned long) {}

struct HardwareSerialStub {
    void begin(unsigned long) {}
    void print(const char*) {}
    void print(int) {}
    void print(float) {}
    void println(const char*) {}
    void println(int) {}
    void println(float) {}
    void printf(const char*, ...) {}
};
static HardwareSerialStub Serial;

#endif // SIGNKO_COMPAT_ARDUINO_H
