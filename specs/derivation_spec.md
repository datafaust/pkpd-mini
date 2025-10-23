# Derivation Specification (SDTM-like → ADaM-like)

This document defines the **source-to-target mapping** and rules used to produce **ADPC** (ADaM-like) from SDTM-like inputs.

## Domains and Keys
- **DM-like**: `USUBJID`, `SEX`, `AGE`, `WTBL`
- **PC-like**: `USUBJID`, `PCTPTNUM` (analysis time, hours), `PCSTRESN` (conc, mg/L), `DOSE` (mg/kg or mg), `ANALYTE`

**Keys:** (`USUBJID`, `PCTPTNUM`) must be unique.

## Rules
| Target (ADPC) | Source | Rule |
|---|---|---|
| `USUBJID` | DM/PC | Join on subject |
| `ADT` | PC | Study day/time; for demo, set `ADT = PCTPTNUM` hours post-dose |
| `ATPT` | PC | Label for `PCTPTNUM` (e.g., "0.5h") |
| `ANL01FL` | PC | 'Y' if used for primary analysis (non-missing, non-negative conc) |
| `DOSE` | PC/DM | Carry from PC (or impute) |
| `WEIGHT` | DM | From baseline weight if available |
| `PCSTRESN` | PC | Concentration numeric (>=0) |

## NCA
Using **PKNCA** to compute per-subject **AUC (0-inf)**, **Cmax**, **Tmax** on `PCSTRESN` vs `PCTPTNUM`.

## QC
- Keys unique (`USUBJID`, `PCTPTNUM`)
- Ranges valid (no negative times/conc)
- Row counts expected (n subjects, n records)
- Parity: recompute `Cmax` for one subject by hand and compare to NCA output

> Note: All structures are **“-like”** for demonstration; not CDISC-compliant. 
