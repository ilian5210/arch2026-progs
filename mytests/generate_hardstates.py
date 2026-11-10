#!/usr/bin/env python3
"""Rebuild the distance-11 list using Assignment 1's independent BFS oracle."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("minirubik", type=Path, help="Assignment 1 checkout containing tests/check_gates.c")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    oracle = args.minirubik.resolve() / "tests/check_gates.c"
    if not oracle.is_file():
        parser.error(f"No independent oracle at {oracle}")
    source = "#define main old_main\n#include " + json.dumps(str(oracle)) + "\n#undef main\n" + r'''
int main(void) {
    build_oracle();
    uint8_t diameter; uint32_t counts[12];
    uint8_t *d = build_exact_distances(&diameter, counts);
    if (!d || diameter != 11 || counts[11] != 2644) return 2;
    puts("/* All distance-11 states from an independent breadth-first oracle. */");
    puts("static const char hard_states[2644][15] = {");
    for (uint32_t i = 0; i < STATES; ++i) if (d[i] == 11) {
        char text[15]; format_state(i / ORIENTATIONS, i % ORIENTATIONS, text);
        printf("    \"%s\",\n", text);
    }
    puts("};"); free(d); return 0;
}
'''
    with tempfile.TemporaryDirectory(prefix="ca2026-hardstates-") as temporary:
        directory = Path(temporary)
        generator = directory / "generate.c"
        executable = directory / "generate"
        generator.write_text(source)
        subprocess.run(["cc", "-O2", str(generator), "-o", str(executable)], check=True)
        with args.out.open("wb") as output:
            subprocess.run([str(executable)], stdout=output, check=True)
        style = Path(__file__).resolve().parents[1] / ".clang-format"
        subprocess.run(["clang-format-20", f"-style=file:{style}", "-i", str(args.out)], check=True)


if __name__ == "__main__":
    main()
