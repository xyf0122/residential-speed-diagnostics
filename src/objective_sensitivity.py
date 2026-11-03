"""Compute the fixed-field objective check from the released bin summaries."""
import csv
import json
from collections import defaultdict
from math import fsum


def write_sensitivity(data, destination):
    parameters = json.loads((data / "parameters.json").read_text())
    reference = parameters["nu_mph"]
    profiles = json.loads((data / "profiles.json").read_text())
    retained = defaultdict(list)
    for cell in profiles["bins"]:
        if cell["retained"]:
            retained[cell["rid"]].append((cell["width"], cell["Q_display"]))

    with destination.open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["acquisition", "objective_mph", "support_model_m", "p",
                         "m_mph", "A_mph", "reference_mph", "E", "index_defined"])
        for rid, cells in retained.items():
            support = fsum(width for width, speed in cells)
            for objective in (20, 25, 30):
                above = [(width, speed - objective) for width, speed in cells
                         if speed > objective]
                length = fsum(width for width, excess in above)
                total = fsum(width * excess for width, excess in above)
                average = total / support
                valid = objective < reference
                # All primary field values are at or below the retained cap.
                assert max(speed for width, speed in cells) <= reference + 1e-12
                index = 1 - average / (reference - objective) if valid else None
                writer.writerow([rid, objective, support, length / support,
                                 total / length if length else None, average,
                                 reference, index, int(valid)])
