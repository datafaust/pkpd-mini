# Compute basic NCA (AUC_last, Cmax, Tmax) with PKNCA if available;
# falls back to a manual trapezoid calculator if PKNCA interface differs.
source("R/00_utils.R")
need(c("dplyr","tibble"))  # PKNCA/tidyr loaded conditionally below

# ---- helper: manual trapezoid AUC_last per subject ----
.manual_nca <- function(adpc) {
  library(dplyr)
  by_subj <- adpc |>
    arrange(USUBJID, PCTPTNUM) |>
    group_by(USUBJID) |>
    summarise(
      AUC  = {
        t <- PCTPTNUM; c <- PCSTRESN
        # trapezoidal sum over consecutive pairs
        if (length(t) < 2) NA_real_ else sum((head(c,-1)+tail(c,-1))/2 * diff(t), na.rm=TRUE)
      },
      Cmax = suppressWarnings(max(PCSTRESN, na.rm=TRUE)),
      Tmax = {
        i <- suppressWarnings(which.max(PCSTRESN))
        if (length(i) == 0 || is.infinite(Cmax) || is.nan(Cmax)) NA_real_ else PCTPTNUM[i]
      },
      .groups = "drop"
    )
  by_subj |>
    mutate(
      AUC  = as.numeric(AUC),
      Cmax = as.numeric(Cmax),
      Tmax = as.numeric(Tmax)
    )
}

compute_nca <- function(ADPC) {
  log_run("Computing NCA (AUC, Cmax, Tmax)")
  stopifnot(all(c("USUBJID","PCTPTNUM","PCSTRESN") %in% names(ADPC)))
  
  # quick guardrails
  if (any(is.na(ADPC$PCTPTNUM)) || any(is.na(ADPC$PCSTRESN))) {
    warning("Missing time or concentration values detected; results may be partial")
  }
  
  # Try PKNCA first (two signatures), else fallback to manual
  ok <- requireNamespace("PKNCA", quietly = TRUE)
  if (ok) {
    # dose per subject at time 0 (max recorded dose, or 1 if missing)
    dose_df <- ADPC |>
      dplyr::group_by(USUBJID) |>
      dplyr::summarise(dose = suppressWarnings(max(DOSE, na.rm = TRUE)),
                       .groups = "drop") |>
      dplyr::mutate(dose = ifelse(is.finite(dose), dose, 1),
                    time = 0)
    
    # Try formula interface (newer PKNCA)
    try1 <- try({
      conc_obj <- PKNCA::PKNCAconc(PCSTRESN ~ PCTPTNUM | USUBJID, data = ADPC)
      dose_obj <- PKNCA::PKNCAdose(dose ~ time | USUBJID, data = dose_df)
      pkdata   <- PKNCA::PKNCAdata(conc = conc_obj, dose = dose_obj)
      intervals <- data.frame(start = 0,
                              end   = max(ADPC$PCTPTNUM, na.rm = TRUE),
                              auclast = TRUE, cmax = TRUE, tmax = TRUE)
      pkres <- PKNCA::pk.nca(pkdata, intervals = intervals)
      as.data.frame(PKNCA::summary(pkres))
    }, silent = TRUE)
    
    if (!inherits(try1, "try-error")) {
      # Extract subject-wise auclast/cmax/tmax
      need(c("tidyr"))
      out <- try1 |>
        dplyr::select(USUBJID = subject, PPTESTCD, value) |>
        tidyr::pivot_wider(names_from = PPTESTCD, values_from = value) |>
        dplyr::transmute(
          USUBJID,
          AUC  = as.numeric(auclast),
          Cmax = as.numeric(cmax),
          Tmax = as.numeric(tmax)
        )
      return(out)
    }
    
    # Try older-style interface (some versions expect named args)
    try2 <- try({
      conc_obj <- PKNCA::PKNCAconc(PCSTRESN ~ PCTPTNUM | USUBJID, data = ADPC)
      dose_obj <- PKNCA::PKNCAdose(dose ~ time | USUBJID, data = dose_df)
      pkdata   <- do.call(PKNCA::PKNCAdata, list(conc = conc_obj, dose = dose_obj))
      intervals <- data.frame(start = 0,
                              end   = max(ADPC$PCTPTNUM, na.rm = TRUE),
                              auclast = TRUE, cmax = TRUE, tmax = TRUE)
      pkres <- PKNCA::pk.nca(pkdata, intervals = intervals)
      as.data.frame(PKNCA::summary(pkres))
    }, silent = TRUE)
    
    if (!inherits(try2, "try-error")) {
      need(c("tidyr"))
      out <- try2 |>
        dplyr::select(USUBJID = subject, PPTESTCD, value) |>
        tidyr::pivot_wider(names_from = PPTESTCD, values_from = value) |>
        dplyr::transmute(
          USUBJID,
          AUC  = as.numeric(auclast),
          Cmax = as.numeric(cmax),
          Tmax = as.numeric(tmax)
        )
      return(out)
    }
    
    # Log that PKNCA failed and fall back
    log_run("PKNCA failed; using manual trapezoid fallback")
  } else {
    log_run("PKNCA not installed; using manual trapezoid fallback")
  }
  
  # Fallback path
  .manual_nca(ADPC)
}
