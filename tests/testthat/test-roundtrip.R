test_that("round-trip: known RGB -> Lab -> matches reference values", {
  lab <- rgb_to_lab(128, 128, 128)
  expect_equal(round(lab$L, 1), 53.6, tolerance = 0.05)
  expect_equal(round(lab$a, 1), 0, tolerance = 0.05)
  expect_equal(round(lab$b, 1), 0, tolerance = 0.05)
})

test_that("round-trip: white is L=100, a=b=0", {
  lab <- rgb_to_lab(255, 255, 255)
  expect_equal(round(lab$L, 1), 100, tolerance = 0.05)
  expect_equal(round(lab$a, 1), 0, tolerance = 0.05)
  expect_equal(round(lab$b, 1), 0, tolerance = 0.05)
})

test_that("round-trip: black is L=a=b=0", {
  lab <- rgb_to_lab(0, 0, 0)
  expect_equal(lab$L, 0, tolerance = 1e-6)
  expect_equal(lab$a, 0, tolerance = 1e-6)
  expect_equal(lab$b, 0, tolerance = 1e-6)
})

test_that("xyz_to_rgb produces valid hex strings", {
  xyz <- data.frame(X = 20, Y = 20, Z = 5)
  rgb <- xyz_to_rgb(xyz)
  expect_match(rgb$hex, "^#[0-9A-Fa-f]{6}$")
})