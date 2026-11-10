    .text
    .align 2
    .globl op1_asm
    .type op1_asm, @function
op1_asm:
    li t0, 0
    beqz a1, .Lop1_done
.Lop1_loop:
    and t1, a0, a1
    xor a0, a0, a1
    slli a1, t1, 1
    addi t0, t0, 1
    bnez a1, .Lop1_loop
.Lop1_done:
    sw t0, 0(a2)
    ret
    .size op1_asm, .-op1_asm

    .globl op2_asm
    .type op2_asm, @function
op2_asm:
    sub a0, a0, a1
    ret
    .size op2_asm, .-op2_asm

    .globl op3_asm
    .type op3_asm, @function
op3_asm:
    xor t0, a0, a1
    and a0, a0, a1
    srli t0, t0, 1
    add a0, a0, t0
    ret
    .size op3_asm, .-op3_asm

# Signed product in a register pair. Treat b as unsigned first, then
# subtract a from the high word when b was negative.
    .globl q_mul_asm
    .type q_mul_asm, @function
q_mul_asm:
    mv t0, a0
    srai t1, a0, 31
    srai t6, a1, 31
    and t6, t6, a0
    li a2, 0
    li a3, 0
    beqz a1, .Lq_finish
.Lq_loop:
    andi t2, a1, 1
    beqz t2, .Lq_shift
    add a2, a2, t0
    sltu t4, a2, t0
    add a3, a3, t1
    add a3, a3, t4
.Lq_shift:
    srli t2, t0, 31
    slli t1, t1, 1
    or t1, t1, t2
    slli t0, t0, 1
    srli a1, a1, 1
    bnez a1, .Lq_loop
.Lq_finish:
    sub a3, a3, t6
    li t0, 0x80000
    add t1, a2, t0
    sltu t2, t1, a2
    add a3, a3, t2
    srli a0, t1, 20
    slli a3, a3, 12
    or a0, a0, a3
    ret
    .size q_mul_asm, .-q_mul_asm
