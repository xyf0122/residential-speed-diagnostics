# Local-window speed diagnostics: reproducibility data and code

This package reproduces eleven analytical table datasets and Figures 4–7 and B.1 from previously computed, non-record-level summaries for the study of residential speed reachability and spatial exceedance. The field inventory, maps, photographs and worked native-record example are excluded.

## Run

Use Python 3.10+ with Matplotlib and R 4.3+ with ggplot2 4.0+, patchwork 1.3+ and jsonlite. Install the Python requirements in your environment; install the three R packages using your usual R package manager. Then run from this directory:

```sh
python src/reproduce.py --out output
python tests/check_outputs.py --out output
Rscript tests/check_r_marks.R data output
```

`--rscript` selects an Rscript executable. All products go to the chosen output directory: eleven CSV tables, five PDF figures and scientific mark records used by the checks. Table CSVs reproduce reported cell precision and named columns; full-precision saved summaries are provided separately. The r19 table retains the manuscript's two-subset orientation.

## Interpretation

This is summary-to-display reproduction. It does not reconstruct restricted trajectories, estimate fields or fits, select new recovery features, or repeat bootstrap sampling. Conditional speed values use the declared joint speed–distance measurement model. Local coordinates and fitted spans are model metres; G is model s^-2, and J is dimensionless. The index describes the representative field, not individual-vehicle compliance or crash risk. The common-scale scenario changes speed and distance together by exactly 1.609344 with fixed numerical references.

See `docs/data_dictionary.md` for schemas, units and eligibility. The package includes selected acquisition-level summaries and aggregate profiles needed for the reported displays. It excludes individual radar records, vehicle identifiers, individual fits and calendar identities.

## Rendering and provenance

The display code retains the Python/Matplotlib and R/ggplot2/patchwork implementations used for the approved analytical graphics. Python prefers installed Arial and falls back to DejaVu Sans. R uses Arial with the macOS Quartz device when available and otherwise Helvetica with the standard PDF device; `AAP_FONT` can select another installed compatible font. Fonts are not distributed. Font and runtime differences can change typography and PDF bytes; scientific values and encodings are the reproduction target.

## Citation and licensing

See `CITATION.cff` for the study title and authors. This repository accompanies the study named in the citation file. A code and derived-data license has not yet been assigned. Obtain the rights holder's terms before redistribution or reuse; the package does not grant a license by implication.
