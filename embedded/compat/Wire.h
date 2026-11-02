#ifndef SIGNKO_COMPAT_WIRE_H
#define SIGNKO_COMPAT_WIRE_H

#include <stdint.h>
#include <stddef.h>

class TwoWire {
public:
    bool begin(int sda = -1, int scl = -1, uint32_t frequency = 0) {
        (void)sda; (void)scl; (void)frequency;
        return true;
    }
    void setClock(uint32_t) {}
    void beginTransmission(uint8_t) {}
    size_t write(uint8_t) { return 1; }
    uint8_t endTransmission(bool stop = true) { (void)stop; return 0; }
    uint8_t requestFrom(uint8_t, uint8_t, uint8_t stop = 1) { (void)stop; return 0; }
    int available() { return 0; }
    int read() { return 0; }
};

[[maybe_unused]] static TwoWire Wire;

#endif // SIGNKO_COMPAT_WIRE_H
