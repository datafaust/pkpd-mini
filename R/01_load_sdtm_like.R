# Build SDTM-like DM and PC from Theoph (robust loader)
source("R/00_utils.R")
need(c("dplyr","tibble","janitor","readr"))

load_dm_pc <- function() {
  log_run("Loading Theoph and building SDTM-like DM/PC")
  
  # Prefer the full built-in Theoph
  theoph <- tryCatch({
    utils::data("Theoph", package = "datasets", envir = environment())
    tibble::as_tibble(get("Theoph", envir = environment()))
  }, error = function(e) NULL)
  
  # If that somehow fails, fall back to CSV
  if (is.null(theoph)) {
    theoph <- readr::read_csv("data/theoph.csv", show_col_types = FALSE)
  }
  
  # If CSV has only one subject (stub), override with built-in
  if (dplyr::n_distinct(theoph$Subject %||% theoph$subject) < 3) {
    utils::data("Theoph", package = "datasets", envir = environment())
    theoph <- tibble::as_tibble(get("Theoph", envir = environment()))
  }
  
  # Normalize names
  theoph <- janitor::clean_names(theoph) # subject, time, conc, dose, wt
  
  dm <- theoph |>
    dplyr::distinct(subject, wt) |>
    dplyr::transmute(USUBJID = as.character(subject),
                     WTBL = wt)
  
  pc <- theoph |>
    dplyr::transmute(USUBJID = as.character(subject),
                     PCTPTNUM = as.numeric(time),
                     PCSTRESN = as.numeric(conc),
                     DOSE = dose)
  
  stopifnot(all(pc$PCTPTNUM >= 0), all(pc$PCSTRESN >= 0))
  assert_unique_keys(pc, c("USUBJID","PCTPTNUM"))
  
  list(DM = dm, PC = pc)
}

`%||%` <- function(x, y) if (!is.null(x)) x else y
