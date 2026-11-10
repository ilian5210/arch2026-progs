#!/usr/bin/env python3
"""Measure arithmetic error against host real and arbitrary-precision references."""

import argparse
import ctypes
import json
import math
from pathlib import Path
import random
import subprocess
import sys
import tempfile


def value(bits):
    exponent = (bits >> 7) & 255
    fraction = bits & 127
    magnitude = math.ldexp(128 + fraction, exponent - 134) if exponent else math.ldexp(fraction, -133)
    return -magnitude if bits & 0x8000 else magnitude


def analyze(lib):
    lib.bf16_sqrt.argtypes = [ctypes.c_uint16]
    lib.bf16_sqrt.restype = ctypes.c_uint16
    lib.bf16_mul.argtypes = [ctypes.c_uint16, ctypes.c_uint16]
    lib.bf16_mul.restype = ctypes.c_uint16
    lib.q_mul.argtypes = [ctypes.c_int32, ctypes.c_int32]
    lib.q_mul.restype = ctypes.c_int32

    root = {"positive_normals": 0, "max_relative_error": -1.0}
    for bits in range(0x0080, 0x7F80):
        actual = lib.bf16_sqrt(bits)
        exact = math.sqrt(value(bits))
        error = abs(value(actual) - exact) / exact
        root["positive_normals"] += 1
        if error > root["max_relative_error"]:
            root.update(max_relative_error=error, input=hex(bits), output=hex(actual))

    product = {"normal_significand_pairs": 0, "max_relative_error": -1.0}
    for a in range(0x3F80, 0x4000):
        for b in range(0x3F80, 0x4000):
            actual = lib.bf16_mul(a, b)
            exact = value(a) * value(b)
            error = abs(value(actual) - exact) / exact
            product["normal_significand_pairs"] += 1
            if error > product["max_relative_error"]:
                product.update(max_relative_error=error, a=hex(a), b=hex(b), output=hex(actual))
    product["subnormal_quirk_example"] = {
        "a": "0x0080", "b": "0x3f00", "result": hex(lib.bf16_mul(0x80, 0x3F00))
    }

    seed = 20261110
    rng = random.Random(seed)
    overflow = 0
    maximum_error_units = 0
    for _ in range(100000):
        a, b = (rng.randint(-(1 << 31), (1 << 31) - 1) for _ in range(2))
        wide = a * b
        rounded = (wide + (1 << 19)) >> 20
        low = rounded & 0xFFFFFFFF
        expected = low if low < (1 << 31) else low - (1 << 32)
        assert lib.q_mul(a, b) == expected, (a, b, expected)
        overflow += not (-(1 << 31) <= rounded < (1 << 31))
        maximum_error_units = max(maximum_error_units, abs((rounded << 20) - wide))
    fixed = {
        "random_pairs": 100000, "seed": seed, "exact_reference_pass": True,
        "overflow_pairs": overflow,
        "max_pre_wrap_absolute_error": math.ldexp(maximum_error_units, -40),
        "bound_half_lsb": math.ldexp(1, -21),
    }
    return {"sqrt": root, "mul": product, "q_mul": fixed}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="ca2026-errors-") as temporary:
        library = Path(temporary) / ("analysis.dylib" if sys.platform == "darwin" else "analysis.so")
        subprocess.run([
            "cc", "-O2", "-shared", "-fPIC", str(root / "src/bf16/bf16.c"),
            str(root / "src/fixed/fixed.c"), "-o", str(library),
        ], check=True)
        report = json.dumps(analyze(ctypes.CDLL(str(library))), indent=2) + "\n"
    if args.out:
        args.out.write_text(report)
    print(report, end="")


if __name__ == "__main__":
    main()
