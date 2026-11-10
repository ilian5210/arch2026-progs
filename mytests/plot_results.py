#!/usr/bin/env python3
"""Export the framework's measured plots as SVG without changing its scripts."""

import argparse
import csv
from pathlib import Path
import sys
from unittest.mock import patch

import matplotlib

matplotlib.use("Agg")
matplotlib.rcParams["svg.fonttype"] = "none"
from matplotlib.figure import Figure

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / "scripts"))
import cycles


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("evidence", type=Path, help="Directory with cycles.csv and footprint.csv")
    args = parser.parse_args()
    with (args.evidence / "cycles.csv").open() as source:
        rows = list(csv.DictReader(source))
    for row in rows:
        for key in ("cycles", "overhead", "n", "per_call", "instret", "per_call_instret"):
            row[key] = float(row[key])
    with (args.evidence / "footprint.csv").open() as source:
        footprint = list(csv.DictReader(source))
    for row in footprint:
        for key in cycles.SECTIONS:
            row[key] = int(row[key])
    save = Figure.savefig

    def svg(figure, filename, **kwargs):
        destination = Path(filename).with_suffix(".svg")
        save(figure, destination, metadata={"Date": None})
        print(destination)

    with patch.object(Figure, "savefig", svg):
        cycles.plot(str(args.evidence), cycles.per_call_table(rows), footprint)


if __name__ == "__main__":
    main()
