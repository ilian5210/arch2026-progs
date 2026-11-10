#include "bf16.h"

uint16_t bf16_from_f32(uint32_t bits)
{
    if ((bits & UINT32_C(0x7f800000)) == UINT32_C(0x7f800000))
        return (uint16_t) (bits >> 16);
    return (uint16_t) ((bits + 0x7fffu + ((bits >> 16) & 1u)) >> 16);
}

uint16_t bf16_mul(uint16_t a, uint16_t b)
{
    unsigned sign = (a ^ b) & 0x8000u;
    unsigned ma = a & 127u, mb = b & 127u;
    int ea = (a >> 7) & 255u, eb = (b >> 7) & 255u;
    if (ea == 255) {
        if (ma)
            return a;
        return (b & 0x7fffu) ? (uint16_t) (sign | 0x7f80u) : 0x7fc0u;
    }
    if (eb == 255) {
        if (mb)
            return b;
        return (a & 0x7fffu) ? (uint16_t) (sign | 0x7f80u) : 0x7fc0u;
    }
    if (!(a & 0x7fffu) || !(b & 0x7fffu))
        return (uint16_t) sign;
    if (ea)
        ma |= 128u;
    else {
        ea = 1;
        while (ma < 128u) {
            ma <<= 1;
            --ea;
        }
    }
    if (eb)
        mb |= 128u;
    else {
        eb = 1;
        while (mb < 128u) {
            mb <<= 1;
            --eb;
        }
    }
    unsigned product = ma * mb;
    int exponent = ea + eb - 127;
    if (product >= 32768u) {
        product >>= 1;
        ++exponent;
    }
    /* The quiz contract shifts the stored fraction on underflow, after
     * discarding the implicit leading one; retain this specified quirk. */
    unsigned mantissa = (product >> 7) & 127u;
    if (exponent >= 255)
        return (uint16_t) (sign | 0x7f80u);
    if (exponent <= 0)
        return exponent < -6 ? (uint16_t) sign
                             : (uint16_t) (sign | (mantissa >> (1 - exponent)));
    return (uint16_t) (sign | ((unsigned) exponent << 7) | (mantissa & 127u));
}

uint16_t bf16_sqrt(uint16_t a)
{
    unsigned exponent = (a >> 7) & 255u;
    unsigned fraction = a & 127u;
    if (exponent == 255u) {
        if (fraction || !(a & 0x8000u))
            return a;
        return 0x7fc0u;
    }
    if (!(a & 0x7fffu))
        return 0;
    if (a & 0x8000u)
        return 0x7fc0u;
    if (!exponent)
        return 0;
    unsigned m = 128u | fraction;
    int e = (int) exponent - 127;
    if ((exponent ^ 127u) & 1u) {
        m <<= 1;
        --e;
    }
    unsigned lo = 90, hi = 256;
    while (lo < hi) {
        unsigned mid = (lo + hi + 1u) >> 1;
        if ((mid * mid >> 7) <= m)
            lo = mid;
        else
            hi = mid - 1u;
    }
    int result_e = e / 2 + 127;
    if (lo < 128u) {
        lo <<= 1;
        --result_e;
    }
    return (uint16_t) (((unsigned) result_e << 7) | (lo & 127u));
}
