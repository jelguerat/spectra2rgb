test_that("hs_to_xyz returns one XYZ row per input spectrum", {
  wl  <- seq(400, 700, by = 10)
  ref <- rep(0.5, length(wl))
  out <- hs_to_xyz(wl, ref)
  expect_equal(nrow(out), 1L)
  expect_named(out, c("X", "Y", "Z"))
  expect_true(all(out >= 0))
})

test_that("hs_to_xyz accepts a matrix of spectra", {
  wl  <- seq(400, 700, by = 10)
  ref <- matrix(0.5, nrow = 3, ncol = length(wl))
  out <- hs_to_xyz(wl, ref)
  expect_equal(nrow(out), 3L)
})

test_that("hs_to_xyz rejects mismatched dimensions", {
  wl  <- seq(400, 700, by = 10)
  ref <- matrix(0.5, nrow = 2, ncol = 5)
  expect_error(hs_to_xyz(wl, ref), "columns")
})

test_that("hs_to_xyz zeroes non-finite reflectance", {
  wl  <- seq(400, 700, by = 10)
  ref <- rep(NA_real_, length(wl))
  out <- hs_to_xyz(wl, ref)
  expect_equal(unname(unlist(out)), c(0, 0, 0))
})