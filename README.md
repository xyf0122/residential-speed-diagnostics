# Local-window speed diagnostics: reproducibility data and code

The code reproduces the analytical displays for the second revision of *Safety-oriented self-enforcement index for residential stop control*. It uses aggregate summaries from eight residential radar acquisitions in St. Matthews, Kentucky. Each profile uses the retained support of its own sensor window. Comparing physical positions across windows requires registration to the roadway.

| Manuscript display | Output |
| --- | --- |
| Figure 4 | Local observation domains and retained support |
| Figure 5 | Conditional stop-to-stop reachability schematic |
| Figure 6 | Spatial 85th-percentile speed profiles |
| Figure 7 | Exceedance extent, severity and average excess |
| Figure 8 | Acceleration gradient, fitted spans and observation populations |
| Figure B.1 | Primary and joint-scale scenario estimates |
| Tables 2–8 and B.1–B.4 | Twelve CSV datasets, including separate files for Table B.4(a) and (b) |
| Section 5.2 | Fixed-field sensitivity at 20, 25 and 30 mph |

## Run

Use Python 3.10+ with Matplotlib and R 4.3+ with ggplot2 4.0+, patchwork 1.3+ and jsonlite. Install the Python requirements in your environment; install the three R packages using your usual R package manager. Run these commands from this directory with a fresh output directory:

```sh
python src/reproduce.py --out output
python tests/check_outputs.py --out output
Rscript tests/check_r_marks.R data output
```

`--rscript` selects an Rscript executable. The command writes table CSVs, six PDF figures and the values used by the plotting checks under `output/`.

## Interpretation

The schematic shows how acceleration and braking distances determine whether a selected speed is reachable for specified endpoint states and motion limits. The radar summaries describe observed-window exceedance under a conditional measurement model. The study uses 25 mph as a common analytical objective. At 30 mph the primary percentile fields have zero positive exceedance, but the objective is above the retained reference of about 29.70 mph, so the index is undefined. Table B.4 compares the full field with the accepted-fit field on identical bins **within** r15 and **within** r16. Roughness describes the reconstructable tracks.

See `docs/data_dictionary.md` for units, eligibility and table mappings. Inputs are acquisition-level summaries and aggregate bin profiles. The reproduction starts after field construction, fitting and bootstrap sampling. The field inventory, photographs, individual radar records, track identifiers, individual fits and calendar dates are outside this release.

## Rendering and provenance

The display code retains the Python/Matplotlib and R/ggplot2/patchwork implementations used for the approved analytical graphics. Python prefers installed Arial and falls back to DejaVu Sans. R uses Arial with the macOS Quartz device when available and otherwise Helvetica with the standard PDF device; `AAP_FONT` can select another installed compatible font. Fonts are not distributed. Font and runtime differences can change typography and PDF bytes; scientific values and encodings are the reproduction target.

## Citation and licensing

See `CITATION.cff` for the study title and authors. This repository accompanies the study named in the citation file. A code and derived-data license has not yet been assigned. Obtain the rights holder's terms before redistribution or reuse; the package does not grant a license by implication.
