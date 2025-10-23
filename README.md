# PK/PD Mini-Workflow in R — SDTM-like → ADaM-like → TLFs with QC

**Goal.** Demonstrate end-to-end clinical-style programming on open PK data (Theoph): map SDTM-like domains, derive an ADaM-like analysis dataset, compute basic NCA parameters, and generate TLFs (tables, listings, figures) in a reproducible Quarto pipeline with visible QC and traceability.

**Why this matters (recruiters/ATS).** Hits clinical signals: **TLFs**, **derived datasets**, **specs→code**, **QC/traceability**, **PK/PD terminology** (AUC, Cmax, Tmax), **CDISC-like naming**, and **R/Quarto**. Looks sponsor-ready (structured repo, specs folder, CI, run logs) with minimal scope.

**Dataset.** `datasets::Theoph` (ships with base R). No licenses/PHI.

## Outputs
- **Listings:** Subject-level concentration–time
- **Tables:** NCA summary (AUC, Cmax, Tmax) per subject
- **Figures:** Spaghetti (individuals) + mean curve; simple exposure–response demo
- **Run log & QC:** tests passed, counts, versions, Git SHA

## How to run (local)
1. Install R (≥4.2), Quarto, and Pandoc.
2. In R:
   ```r
   install.packages(c("renv"))
   renv::restore()    # uses renv.lock; if versions fail on your OS, run `source('renv/requirements.R')` then `renv::snapshot()`
   ```
3. Render TLFs + run tests:
   ```bash
   quarto render tlf/
   Rscript -e "testthat::test_dir('R/tests')"
   ```
4. See `outputs/` for `listings.html`, `tables.html`, `figures.html`, and `runlog.txt`.

## CI (GitHub Actions)
- On each push to `main`, the workflow restores deps, runs tests, renders Quarto, and uploads artifacts (optionally publish Pages).

## Repo layout
```
pkpd-mini/
├─ README.md
├─ _quarto.yml
├─ renv.lock
├─ renv/requirements.R
├─ data/
│  └─ theoph.csv   # optional; otherwise load from datasets::Theoph
├─ specs/
│  ├─ derivation_spec.md
│  └─ tlf_shells.xlsx
├─ R/
│  ├─ 00_utils.R
│  ├─ 01_load_sdtm_like.R
│  ├─ 02_derive_adpc.R
│  ├─ 03_nca.R
│  └─ tests/test_qc.R
├─ tlf/
│  ├─ 01_listings.qmd
│  ├─ 02_tables.qmd
│  └─ 03_figures.qmd
├─ outputs/
│  └─ .gitkeep
└─ .github/workflows/render.yml
```

## Limitations
Demonstration only; **SDTM/ADaM structures are simplified** (marked “-like”). No clinical claims.

---

**Positioning (resume/LinkedIn):** *PK/PD Mini-Workflow (Quarto): SDTM-like → ADaM-like derivations on open Theoph data; NCA (AUC, Cmax, Tmax), TLFs (tables/listings/figures), and QC (testthat, run logs). Reproducible build with renv, GitHub Actions, and Quarto.*
