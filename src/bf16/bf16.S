# Integer bit patterns only. Preserve the contract's ordered NaN handling.
    .text
    .align 2
    .globl bf16_from_f32_asm
    .type bf16_from_f32_asm, @function
bf16_from_f32_asm:
    # A discarded half below 0x8000 never rounds upward, in any value class.
    slli t0, a0, 16
    bgez t0, .Lf32_top
    li t0, 0x7f800000
    and t1, a0, t0
    beq t0, t1, .Lf32_top
    srli t1, a0, 16
    andi t1, t1, 1
    li t0, 0x7fff
    add a0, a0, t0
    add a0, a0, t1
.Lf32_top:
    srli a0, a0, 16
    ret
    .size bf16_from_f32_asm, .-bf16_from_f32_asm

    .globl bf16_mul_asm
    .type bf16_mul_asm, @function
bf16_mul_asm:
    xor a2, a0, a1
    li t0, 0x8000
    and a2, a2, t0
    andi a3, a0, 127
    andi a4, a1, 127
    srli a5, a0, 7
    andi a5, a5, 255
    srli a6, a1, 7
    andi a6, a6, 255
    li t6, 255
    beq a5, t6, .Lmul_special_a
    beq a6, t6, .Lmul_special_b
    slli t0, a0, 17
    beqz t0, .Lmul_zero
    slli t0, a1, 17
    beqz t0, .Lmul_zero
    beqz a5, .Lmul_denorm_a
    ori a3, a3, 128
    j .Lmul_b
.Lmul_denorm_a:
    li a5, 1
    li t0, 128
.Lmul_normalize_a:
    slli a3, a3, 1
    addi a5, a5, -1
    bltu a3, t0, .Lmul_normalize_a
.Lmul_b:
    beqz a6, .Lmul_denorm_b
    ori a4, a4, 128
    j .Lmul_product
.Lmul_denorm_b:
    li a6, 1
    li t0, 128
.Lmul_normalize_b:
    slli a4, a4, 1
    addi a6, a6, -1
    bltu a4, t0, .Lmul_normalize_b
.Lmul_product:
    # The normalized multiplier has bit 7 set; only seven bits remain.
    slli a7, a3, 7
    .rept 7
    andi t0, a4, 1
    beqz t0, 1f
    add a7, a7, a3
1:
    slli a3, a3, 1
    srli a4, a4, 1
    .endr
    add a5, a5, a6
    addi a5, a5, -127
    srli t0, a7, 15
    beqz t0, .Lmul_fraction
    srli a7, a7, 1
    addi a5, a5, 1
.Lmul_fraction:
    srli a7, a7, 7
    andi a7, a7, 127
    bge a5, t6, .Lmul_inf
    blez a5, .Lmul_underflow
    slli a5, a5, 7
    andi a7, a7, 127
    or a0, a2, a5
    or a0, a0, a7
    ret
.Lmul_underflow:
    li t0, -6
    blt a5, t0, .Lmul_zero
    li t0, 1
    sub t0, t0, a5
    srl a7, a7, t0
    or a0, a2, a7
    ret
.Lmul_special_a:
    bnez a3, .Lmul_return
    slli t0, a1, 17
    beqz t0, .Lmul_nan
    j .Lmul_inf
.Lmul_special_b:
    beqz a4, .Lmul_b_inf
    mv a0, a1
.Lmul_return:
    ret
.Lmul_b_inf:
    slli t0, a0, 17
    beqz t0, .Lmul_nan
.Lmul_inf:
    li t0, 0x7f80
    or a0, a2, t0
    ret
.Lmul_nan:
    li a0, 0x7fc0
    ret
.Lmul_zero:
    mv a0, a2
    ret
    .size bf16_mul_asm, .-bf16_mul_asm

# For a positive normal, only 7 fraction bits and exponent parity determine
# sqrt's significand. Cache the 256 exact integer-root results, not a floating
# approximation: isqrt(128 * (m + 1) - 1), m=(128+fraction)<<parity.
    .globl bf16_sqrt_asm
    .type bf16_sqrt_asm, @function
bf16_sqrt_asm:
    srli t0, a0, 7
    andi t0, t0, 255
    andi t1, a0, 127
    li t2, 255
    beq t0, t2, .Lsqrt_special
    slli t2, a0, 17
    beqz t2, .Lsqrt_zero
    li t2, 0x8000
    bgeu a0, t2, .Lsqrt_nan
    beqz t0, .Lsqrt_zero
    andi t2, t0, 1
    xori t2, t2, 1
    slli t2, t2, 7
    or t1, t1, t2
    la t2, .Lsqrt_roots
    add t1, t1, t2
    lbu t1, 0(t1)
    andi t1, t1, 127
    addi t0, t0, 127
    srli t0, t0, 1
    slli t0, t0, 7
    or a0, t0, t1
    ret
.Lsqrt_special:
    bnez t1, .Lsqrt_return
    li t2, 0x8000
    bltu a0, t2, .Lsqrt_return
.Lsqrt_nan:
    li a0, 0x7fc0
.Lsqrt_return:
    ret
.Lsqrt_zero:
    li a0, 0
    ret
    .size bf16_sqrt_asm, .-bf16_sqrt_asm

    .section .rodata
.Lsqrt_roots:
    .byte 128,128,129,129,130,130,131,131,132,132,133,133,134,134,135,135
    .byte 136,136,137,137,138,138,139,139,139,140,140,141,141,142,142,143
    .byte 143,143,144,144,145,145,146,146,147,147,147,148,148,149,149,150
    .byte 150,150,151,151,152,152,153,153,153,154,154,155,155,155,156,156
    .byte 157,157,157,158,158,159,159,159,160,160,161,161,161,162,162,163
    .byte 163,163,164,164,165,165,165,166,166,167,167,167,168,168,168,169
    .byte 169,170,170,170,171,171,171,172,172,173,173,173,174,174,174,175
    .byte 175,175,176,176,177,177,177,178,178,178,179,179,179,180,180,181
    .byte 181,182,182,183,184,184,185,186,186,187,188,188,189,190,190,191
    .byte 192,192,193,194,194,195,196,196,197,198,198,199,200,200,201,202
    .byte 202,203,203,204,205,205,206,207,207,208,208,209,210,210,211,211
    .byte 212,213,213,214,214,215,216,216,217,217,218,219,219,220,220,221
    .byte 221,222,223,223,224,224,225,225,226,227,227,228,228,229,229,230
    .byte 231,231,232,232,233,233,234,234,235,235,236,237,237,238,238,239
    .byte 239,240,240,241,241,242,242,243,243,244,245,245,246,246,247,247
    .byte 248,248,249,249,250,250,251,251,252,252,253,253,254,254,255,255
