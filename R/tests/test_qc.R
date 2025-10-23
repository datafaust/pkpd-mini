# Basic QC checks
source("R/00_utils.R")
source("R/01_load_sdtm_like.R")
source("R/02_derive_adpc.R")
source("R/03_nca.R")
need(c("testthat","dplyr"))

test_that("DM/PC build and keys are valid", {
  objs <- load_dm_pc()
  DM <- objs$DM; PC <- objs$PC
  expect_true(all(PC$PCTPTNUM >= 0))
  expect_true(all(PC$PCSTRESN >= 0))
  expect_true(nrow(DM) >= 10)
  expect_true(nrow(PC) >= 10)
  expect_no_error(assert_unique_keys(PC, c("USUBJID","PCTPTNUM")))
})

test_that("ADPC derivation preserves keys", {
  objs <- load_dm_pc()
  ADPC <- derive_adpc(objs$DM, objs$PC)
  expect_true(nrow(ADPC) == nrow(objs$PC))
  expect_true(all(ADPC$ANL01FL %in% c("Y","N")))
  expect_no_error(assert_unique_keys(ADPC, c("USUBJID","PCTPTNUM")))
})

test_that("NCA returns per-subject rows", {
  objs <- load_dm_pc()
  ADPC <- derive_adpc(objs$DM, objs$PC)
  nca <- compute_nca(ADPC)
  expect_true(nrow(nca) >= length(unique(ADPC$USUBJID)))
  expect_true(all(c("AUC","Cmax","Tmax") %in% names(nca)))
})

test_that("Parity: hand calc Cmax for one subject", {
  objs <- load_dm_pc()
  ADPC <- derive_adpc(objs$DM, objs$PC)
  one <- ADPC |> dplyr::filter(USUBJID == first(USUBJID))
  hand <- max(one$PCSTRESN, na.rm=TRUE)
  nca <- compute_nca(ADPC) |> dplyr::filter(USUBJID == first(USUBJID))
  expect_equal(as.numeric(nca$Cmax), as.numeric(hand), tolerance = 1e-8)
})
