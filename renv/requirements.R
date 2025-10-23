# Fallback installer in case renv::restore() has problems on CI/OS
pkgs <- c(
  "PKNCA","tidyverse","data.table","ggplot2","testthat","gt","readxl","openxlsx","janitor","tibble","dplyr","stringr","readr"
)
inst <- rownames(installed.packages())
to_install <- setdiff(pkgs, inst)
if (length(to_install)) install.packages(to_install, repos='https://cloud.r-project.org')
