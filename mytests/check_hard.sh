#!/bin/sh
# The caller selects the same toolchain as the official framework.
set -eu
cd "$(dirname "$0")/.."
make OPT=O2
riscv-none-elf-gcc -march=rv32i_zicsr -mabi=ilp32 -ffreestanding -O2 -g \
    -Wall -Wextra -iquote . -Icommon -Itests -c mytests/rubik_hard.c \
    -o build/rubik-hard.o
riscv-none-elf-ld -T common/linker.ld --no-warn-rwx-segments \
    -o build/rubik-hard.elf build/rubik-hard.o build/rubik/O2/impl.o \
    build/rubik/impl_asm.o build/common/start.o build/common/perf.o \
    build/common/rt.o build/common/print.o build/common/utest.o \
    build/common/trt.o build/common/tutest.o
exec third_party/rv32emu/build/rv32emu build/rubik-hard.elf
