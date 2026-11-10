#include "fixed.h"

uint32_t op1(uint32_t a, uint32_t b, int *n)
{
    *n = 0;
    while (b) {
        uint32_t carry = (a & b) << 1;
        a ^= b;
        b = carry;
        ++*n;
    }
    return a;
}

uint32_t op2(uint32_t a, uint32_t b)
{
    return a - b;
}

uint32_t op3(uint32_t a, uint32_t b)
{
    return (a & b) + ((a ^ b) >> 1);
}

int32_t q_mul(int32_t a, int32_t b)
{
    uint32_t ua = (uint32_t) a;
    uint32_t ub = (uint32_t) b;
    uint32_t ma = a < 0 ? 0u - ua : ua;
    uint32_t mb = b < 0 ? 0u - ub : ub;
    uint32_t lo = 0, hi = 0;
    uint32_t term_lo = ma, term_hi = 0;
    while (mb) {
        if (mb & 1u) {
            uint32_t sum = lo + term_lo;
            hi += term_hi + (sum < lo);
            lo = sum;
        }
        term_hi = (term_hi << 1) | (term_lo >> 31);
        term_lo <<= 1;
        mb >>= 1;
    }
    if ((ua ^ ub) >> 31) {
        hi = ~hi + (lo == 0);
        lo = ~lo + 1u;
    }
    hi += lo >= UINT32_C(0xfff80000);
    uint32_t rounded = lo + (1u << (Q - 1));
    /* Only bits 20..51 survive. Unsigned words avoid signed overflow,
     * implementation-defined shifts, and compiler-emitted __muldi3. */
    uint32_t result = (rounded >> Q) | (hi << (32 - Q));
    return result <= INT32_MAX ? (int32_t) result
                               : -1 - (int32_t) (UINT32_MAX - result);
}
