# Derived-data dictionary

Acquisition aliases are r1, r13, r15, r16, r17, r18, r19 and r20, in that fixed order. Repeated acquisitions are not independent roads. No acquisition calendar dates or vehicle identifiers are present.

| File | Content and units |
|---|---|
| support.json | Selected-point domain edges; ell (span); nominal retained grid length; clipped retained support length; component membership and principal indicator; number of days. Coordinates/lengths: model m. `retained=false` is unsupported, not a zero-valued bin. |
| profiles.json | Complete ordered bin grid, clipped edges, retained/component flags, uncapped Q and eligible pointwise bounds; recovery markers. Raw numerical Q/bounds: model m/s; display Q/bounds: conditional mph = model m/s / 0.44704. Step connectors occur only between touching bins in one retained component. |
| components.csv | Figure 6 p/m/A/E estimates and whole-day interval endpoints; p and E dimensionless; m and A conditional mph. `status` is primary, descriptive or withheld. Missing estimate (r16 m) is distinct from a withheld interval (r15/r16 m). |
| roughness.csv | Figure 7 E/J/G and intervals; fitted-span quartiles/median; aggregate field/fit counts. G: model s^-2; L: model m; E/J dimensionless. `*_display` strings retain approved label precision. |
| scenario.csv | Figure B.1 paired primary/scenario endpoints. E and capped fraction dimensionless; uncapped A/overshoot conditional mph. `panel`, `y` and `display` describe display position/format, not additional observations. |
| tables.json | Eleven named analytical table datasets at reported precision, with semantic column names. Bracketed pairs are literal reported intervals/ranges. NA, Withheld and Descriptive retain separate meanings. |
| fixed_fit_summaries.csv | Full-precision acquisition-level J/G/L distribution summaries at tau 0, .05 and .10, using identical fitted curves; fit and day counts. |
| field_summary.csv | Full-precision primary/scenario aggregate field summaries. D_ft recorded spacing in ft; domain/grid/support lengths and H/S in model m; speed-like quantities, m/A and overshoot in model m/s; p/E and capped length fraction dimensionless; count fields integers. `nu` is fixed numerical reference. Uncapped fields precede reference capping. |
| recovery_components.csv | All retained component edges, bin membership, selected principal component and saved recovery identities. Coordinates/lengths model m; first_Q/peak_Q/gains model m/s. Missing post-trough gain denotes no eligible feature. |
| intervals.csv | Saved whole-day p/m/A/E/J/G interval endpoints; defined/total draws, days, reportability and reason. m/A are model m/s; G model s^-2; p/E/J dimensionless. These are conditional percentile intervals, not simultaneous bands. |
| variation_support.csv | Acquisition-level day and draw counts, support/eligibility counts and zero-exceedance fractions; no draw vectors or day identities. |
| parameters.json | Exact conversions and numerical reference/configuration values. Speeds model m/s; acceleration references model m/s^2; distances model m; max_gap_s model seconds. These describe the saved summaries and are not rerun by this package. |

r19 has four observed days: its ranges are descriptive and no nominal 95% interval is drawn. Other intervals require at least 1,900 defined draws out of 2,000; severity additionally requires positive exceedance length. `reportable=false` or a reason/status field explains missing intervals. Zero is a scientific value and is never substituted for absence. Figure 5 intervals are pointwise, with support gaps preserved. All full-precision scalar strings/JSON numbers are retained independently of publication rounding.
