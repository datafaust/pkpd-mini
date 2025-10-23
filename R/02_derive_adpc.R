# Derive ADaM-like ADPC
source("R/00_utils.R")
need(c("dplyr","stringr"))

derive_adpc <- function(DM, PC) {
  log_run("Deriving ADPC (ADaM-like)")
  ADPC <- PC |>
    dplyr::left_join(DM, by="USUBJID") |>
    dplyr::mutate(
      ADT = PCTPTNUM,                                # analysis "time" (hours)
      ATPT = paste0(PCTPTNUM, "h"),
      ANL01FL = dplyr::if_else(!is.na(PCSTRESN) & PCSTRESN >= 0, "Y", "N")
    )
  assert_unique_keys(ADPC, c("USUBJID","PCTPTNUM"))
  ADPC
}
