# Utilities: logging, assertions, helpers

# Make USUBJID an ordered factor with numeric-aware sorting
order_usubjid <- function(df, id = "USUBJID") {
  x <- as.character(df[[id]])
  # numeric-aware if IDs are digits only, else alpha sort
  lev <- if (all(grepl("^\\d+$", x))) {
    as.character(sort(unique(as.integer(x))))
  } else {
    sort(unique(x), method = "radix")
  }
  df[[id]] <- factor(x, levels = lev, ordered = TRUE)
  df
}


log_run <- function(msg) {
  dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  sha <- tryCatch(
    suppressWarnings(
      system2("git", c("rev-parse","--short","HEAD"),
              stdout = TRUE, stderr = FALSE)
    ),
    error = function(e) "no-git"
  )
  
  line <- sprintf("[%s] (%s) %s\n", ts, paste(sha, collapse=" "), msg)
  cat(line, file = "outputs/runlog.txt", append = TRUE)
  invisible(line)
}

assert_unique_keys <- function(df, keys) {
  dup <- any(duplicated(df[, keys, drop = FALSE]))
  if (dup) stop(sprintf("Duplicate keys found for: %s", paste(keys, collapse=", ")))
  TRUE
}

nz <- function(x) !is.na(x) & x != ""

# Package safe require
need <- function(pkgs) {
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org")
    }
  }
}
