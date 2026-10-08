test_that("na_action='zero' fills NA with 0", {
  wl  <- seq(400, 700, by = 10)
  df  <- data.frame(t(rep(0.5, length(wl))))
  names(df) <- as.character(wl)
  df[1, ] <- NA
  out <- spectra_to_rgb(df, na_action = "zero")
  expect_equal(out$R[1], 0)
  expect_equal(out$G[1], 0)
  expect_equal(out$B[1], 0)
})

test_that("na_action='drop' removes all-NA rows with warning", {
  wl  <- seq(400, 700, by = 10)
  df  <- data.frame(t(rep(0.5, length(wl))))
  names(df) <- as.character(wl)
  df[2, ] <- NA
  expect_warning(out <- spectra_to_rgb(df, na_action = "drop"),
                 "Dropped 1")
  expect_equal(nrow(out), 1L)
})

test_that("na_action='keep' preserves NA in output", {
  wl  <- seq(400, 700, by = 10)
  df  <- data.frame(t(rep(0.5, length(wl))))
  names(df) <- as.character(wl)
  df[2, ] <- NA
  out <- spectra_to_rgb(df, na_action = "keep")
  expect_equal(nrow(out), 2L)
  expect_true(is.na(out$R[2]))
})