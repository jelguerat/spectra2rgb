#' Convert hyperspectral reflectance to CIE XYZ
#'
#' Integrates a reflectance spectrum (or a matrix of spectra) against the
#' CIE 1931 2-degree standard observer and the D65 standard illuminant to
#' obtain tristimulus values XYZ.
#'
#' @param wavelengths Numeric vector of wavelengths in nanometres.
#' @param reflectance Numeric vector (single spectrum) or matrix
#'   (rows = samples, columns = wavelengths). Column order must match
#'   \code{wavelengths}.
#'
#' @return A data.frame with columns \code{X}, \code{Y}, \code{Z}.
#'
#' @details
#' The CIE 1931 colour-matching functions (\code{ciexyz31}) and the D65
#' illuminant (\code{illuminantD65}) are bundled with the package. Values
#' are linearly interpolated onto \code{wavelengths}. Wavelengths outside
#' the CMF range are extrapolated flat (\code{rule = 2} in
#' \code{\link[stats]{approx}}); the user is responsible for ensuring the
#' input range is appropriate (400-700 nm is standard for visible colour).
#'
#' Non-finite reflectance values are replaced by 0 and values are clamped
#' to \eqn{[0, 1]} before integration.
#'
#' @examples
#' wl  <- seq(400, 700, by = 10)
#' ref <- rep(0.5, length(wl))
#' hs_to_xyz(wl, ref)
#'
#' @export
hs_to_xyz <- function(wavelengths, reflectance) {
  if (!is.numeric(wavelengths) || length(wavelengths) < 2L) {
    stop("`wavelengths` must be a numeric vector of length >= 2.")
  }
  if (is.null(reflectance)) stop("`reflectance` must not be NULL.")
  
  # Coerce to matrix (rows = samples, cols = wavelengths)
  if (is.null(dim(reflectance))) {
    reflectance <- matrix(reflectance, nrow = 1L)
  } else {
    reflectance <- as.matrix(reflectance)
  }
  if (ncol(reflectance) != length(wavelengths)) {
    stop(sprintf(
      "`reflectance` has %d columns but `wavelengths` has length %d.",
      ncol(reflectance), length(wavelengths)))
  }
  
  # Clean reflectance
  reflectance <- matrix(as.numeric(reflectance),
                        nrow = nrow(reflectance),
                        ncol = ncol(reflectance))
  reflectance[!is.finite(reflectance)] <- 0
  reflectance[reflectance < 0] <- 0
  reflectance[reflectance > 1] <- 1
  
  # Interpolate CMFs and illuminant onto the sample grid
  interp <- function(x, y, xout) stats::approx(x, y, xout = xout, rule = 2)$y
  
  xbar <- interp(ciexyz31$wlnm,      ciexyz31$xbar,       wavelengths)
  ybar <- interp(ciexyz31$wlnm,      ciexyz31$ybar,       wavelengths)
  zbar <- interp(ciexyz31$wlnm,      ciexyz31$zbar,       wavelengths)
  S    <- interp(illuminantD65$wlnm, illuminantD65$intensity, wavelengths)
  
  k <- 100 / sum(S * ybar)
  
  X <- as.numeric(k * (reflectance %*% (S * xbar)))
  Y <- as.numeric(k * (reflectance %*% (S * ybar)))
  Z <- as.numeric(k * (reflectance %*% (S * zbar)))
  
  X[!is.finite(X)] <- 0
  Y[!is.finite(Y)] <- 0
  Z[!is.finite(Z)] <- 0
  
  data.frame(X = X, Y = Y, Z = Z)
}