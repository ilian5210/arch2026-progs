# Cycle analysis

- compiler: riscv-none-elf-gcc 15.2.0, -march=rv32i_zicsr -mabi=ilp32 -ffreestanding
- rv32emu: 9dbff65 (system emulation, ELF_LOADER, interpreter)
- timed region: n calls on identical inputs; loop baseline subtracted

rv32emu has no timing model: `cycle` and `instret` are one counter of executed guest instructions. The figures below are instruction counts per call, with the loop control, input load and counter reads removed.

## Cycles per call

| Function | -O1 | -O2 | -O3 | -Os | asm | best C | asm vs best C |
|---|---|---|---|---|---|---|---|
| bf16.from_f32 | 11.1 | 12.2 | 13.8 | 12.2 | 6.1 | 11.1 | 1.81x |
| bf16.mul | 94.3 | 87.2 | 88.6 | 91.3 | 57.4 | 87.2 | 1.52x |
| bf16.sqrt | 330.8 | 332.2 | 333.6 | 338.4 | 18.6 | 330.8 | 17.76x |
| fixed.op1 | 27.2 | 24.7 | 26.8 | 24.7 | 22.1 | 24.7 | 1.12x |
| fixed.op2 | 4.0 | 4.0 | 5.9 | 4.0 | 4.0 | 4.0 | 1.00x |
| fixed.op3 | 7.0 | 7.0 | 8.9 | 7.0 | 7.0 | 7.0 | 1.00x |
| fixed.q_mul | 223.5 | 262.7 | 264.6 | 251.2 | 214.4 | 223.5 | 1.04x |
| gcd.gcd | 101.6 | 116.6 | 118.8 | 119.7 | 92.9 | 101.6 | 1.09x |
| rubik.solve | 39041.0 | 28710.3 | 28328.8 | 35662.5 | 16222.3 | 28328.8 | 1.75x |

## Ratio to -O2

| Function | -O1 | -O2 | -O3 | -Os | asm |
|---|---|---|---|---|---|
| bf16.from_f32 | 0.91 | 1.00 | 1.13 | 1.00 | 0.50 |
| bf16.mul | 1.08 | 1.00 | 1.02 | 1.05 | 0.66 |
| bf16.sqrt | 1.00 | 1.00 | 1.00 | 1.02 | 0.06 |
| fixed.op1 | 1.10 | 1.00 | 1.09 | 1.00 | 0.90 |
| fixed.op2 | 1.00 | 1.00 | 1.48 | 1.00 | 1.00 |
| fixed.op3 | 1.00 | 1.00 | 1.28 | 1.00 | 1.00 |
| fixed.q_mul | 0.85 | 1.00 | 1.01 | 0.96 | 0.82 |
| gcd.gcd | 0.87 | 1.00 | 1.02 | 1.03 | 0.80 |
| rubik.solve | 1.36 | 1.00 | 0.99 | 1.24 | 0.57 |

## Footprint (bytes, `size -A`, harness excluded)

| Program | Variant | .text | .rodata | .data | .bss |
|---|---|---|---|---|---|
| rubik | asm | 1524 | 116921 | 0 | 768 |
| rubik | -O1 | 2520 | 116864 | 0 | 0 |
| rubik | -O2 | 1884 | 116864 | 0 | 0 |
| rubik | -O3 | 3688 | 116864 | 0 | 0 |
| rubik | -Os | 1776 | 116864 | 0 | 0 |
| bf16 | asm | 612 | 256 | 0 | 0 |
| bf16 | -O1 | 840 | 0 | 0 | 0 |
| bf16 | -O2 | 792 | 0 | 0 | 0 |
| bf16 | -O3 | 792 | 0 | 0 | 0 |
| bf16 | -Os | 720 | 0 | 0 | 0 |
| gcd | asm | 124 | 0 | 0 | 0 |
| gcd | -O1 | 140 | 0 | 0 | 0 |
| gcd | -O2 | 140 | 0 | 0 | 0 |
| gcd | -O3 | 140 | 0 | 0 | 0 |
| gcd | -Os | 120 | 0 | 0 | 0 |
| fixed | asm | 176 | 0 | 0 | 0 |
| fixed | -O1 | 276 | 0 | 0 | 0 |
| fixed | -O2 | 284 | 0 | 0 | 0 |
| fixed | -O3 | 284 | 0 | 0 | 0 |
| fixed | -Os | 220 | 0 | 0 | 0 |
