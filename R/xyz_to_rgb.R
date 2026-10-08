#' Convert CIE XYZ to sRGB
#'
#' @param XYZ A data.frame with columns \code{X}, \code{Y}, \code{Z} (as
#'   returned by \code{\link{hs_to_xyz}}), or a numeric matrix with 3
#'   columns.
#' @param white Reference white point. Defaults to D65
#'   (\code{c(X = 95.047, Y = 100, Z = 108.883)}).
#'
#' @return A data.frame with integer columns \code{R}, \code{G}, \code{B}
#'   (0-255) and character column \code{hex} (e.g. \code{"#654909"}).
#'
#' @export
xyz_to_rgb <- function(XYZ, white = c(X = 95.047, Y = 100, Z = 108.883)) {
  if (is.data.frame(XYZ)) {
    XYZ <- as.matrix(XYZ[, c("X", "Y", "Z"), drop = FALSE])
  } else {
    XYZ <- as.matrix(XYZ)
  }
  if (ncol(XYZ) != 3L) stop("`XYZ` must have exactly 3 columns (X, Y, Z).")

  XYZ[!is.finite(XYZ)] <- 0

  x <- XYZ[, 1] / white["X"]
  y <- XYZ[, 2] / white["Y"]
  z <- XYZ[, 3] / white["Z"]

  M <- matrix(c(
     3.2406, -1.5372, -0.4986,
    -0.9689,  1.8758,  0.0415,
     0.0557, -0.2040,  1.0570
  ), nrow = 3, byrow = TRUE)

  rgb_lin <- cbind(x, y, z) %*% t(M)
  rgb_lin <- matrix(as.numeric(rgb_lin),
                    nrow = nrow(rgb_lin),
                    ncol = 3L)
  rgb_lin[!is.finite(rgb_lin)] <- 0

  gamma_encode <- function(c) {
    c <- pmax(pmin(c, 1), 0)
    out <- ifelse(c <= 0.0031308, 12.92 * c,
                  1.055 * c^(1 / 2.4) - 0.055)
    out[!is.finite(out)] <- 0
    out
  }

  rgb_srgb <- apply(rgb_lin, 2, gamma_encode)
  rgb_srgb <- matrix(as.numeric(rgb_srgb),
                     nrow = nrow(rgb_lin),
                     ncol = 3L)

  rgb_255  <- round(pmax(pmin(rgb_srgb * 255, 255), 0))
  rgb_255[is.na(rgb_255)] <- 0
  colnames(rgb_255) <- c("R", "G", "B")

  out <- as.data.frame(rgb_255)
  out$hex <- grDevices::rgb(out$R, out$G, out$B, maxColorValue = 255)
  out
}
