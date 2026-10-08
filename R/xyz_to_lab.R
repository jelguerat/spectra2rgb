#' Convert CIE XYZ to CIELAB
#'
#' Convenience wrapper: XYZ -> sRGB -> CIELAB. Uses the sRGB path so the
#' result matches what \code{\link{rgb_to_lab}} produces from the same XYZ.
#'
#' @param XYZ A data.frame with columns \code{X}, \code{Y}, \code{Z}, or
#'   a numeric matrix with 3 columns.
#' @param white Reference white point.
#'
#' @return A data.frame with columns \code{L}, \code{a}, \code{b}.
#'
#' @export
xyz_to_lab <- function(XYZ, white = c(X = 95.047, Y = 100, Z = 108.883)) {
  rgb <- xyz_to_rgb(XYZ, white = white)
  rgb_to_lab(rgb$R, rgb$G, rgb$B, white = white)
}