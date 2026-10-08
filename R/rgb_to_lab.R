#' Convert sRGB to CIELAB
#'
#' @param R,G,B Integer vectors (0-255).
#' @param white Reference white point.
#'
#' @return A data.frame with numeric columns \code{L}, \code{a}, \code{b}.
#'
#' @export
rgb_to_lab <- function(R, G, B,
                       white = c(X = 95.047, Y = 100, Z = 108.883)) {
  R[!is.finite(R)] <- 0
  G[!is.finite(G)] <- 0
  B[!is.finite(B)] <- 0
  
  r <- R / 255; g <- G / 255; b <- B / 255
  f <- function(c) ifelse(c <= 0.04045, c / 12.92,
                          ((c + 0.055) / 1.055)^2.4)
  r <- f(r); g <- f(g); b <- f(b)
  
  X <- (0.4124 * r + 0.3576 * g + 0.1805 * b) * 100
  Y <- (0.2126 * r + 0.7152 * g + 0.0722 * b) * 100
  Z <- (0.0193 * r + 0.1192 * g + 0.9505 * b) * 100
  
  h <- function(t) ifelse(t > 0.008856, t^(1 / 3), 7.787 * t + 16 / 116)
  
  fx <- h(X / white["X"])
  fy <- h(Y / white["Y"])
  fz <- h(Z / white["Z"])
  
  data.frame(L = 116 * fy - 16,
             a = 500 * (fx - fy),
             b = 200 * (fy - fz))
}