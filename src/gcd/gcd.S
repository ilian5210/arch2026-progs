# Stein's binary GCD. Strip every even difference before comparing again.
    .text
    .align 2
    .globl gcd_u32_asm
    .type gcd_u32_asm, @function
gcd_u32_asm:
    beq a0, a1, .Lgcd_return
    beqz a1, .Lgcd_return
    beqz a0, .Lgcd_zero
    li t0, 0
.Lgcd_common:
    or t1, a0, a1
    andi t1, t1, 1
    bnez t1, .Lgcd_a
    srli a0, a0, 1
    srli a1, a1, 1
    addi t0, t0, 1
    j .Lgcd_common
.Lgcd_a:
    andi t1, a0, 1
    bnez t1, .Lgcd_b
.Lgcd_shift_a:
    srli a0, a0, 1
    andi t1, a0, 1
    beqz t1, .Lgcd_shift_a
.Lgcd_b:
    andi t1, a1, 1
    bnez t1, .Lgcd_compare
.Lgcd_shift_b:
    srli a1, a1, 1
    andi t1, a1, 1
    beqz t1, .Lgcd_shift_b
.Lgcd_compare:
    bgeu a1, a0, .Lgcd_sub
    mv t1, a0
    mv a0, a1
    mv a1, t1
.Lgcd_sub:
    sub a1, a1, a0
    # Both operands are odd: a nonzero difference is necessarily even.
    bnez a1, .Lgcd_shift_b
    sll a0, a0, t0
.Lgcd_return:
    ret
.Lgcd_zero:
    mv a0, a1
    ret
    .size gcd_u32_asm, .-gcd_u32_asm
