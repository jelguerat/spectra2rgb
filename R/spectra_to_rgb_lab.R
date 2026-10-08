#' Convert a data frame of spectra to sRGB and CIELAB
#'
#' @inheritParams spectra_to_rgb
#'
#' @return A data.frame with columns \code{Sample_ID}, \code{R}, \code{G},
#'   \code{B}, \code{hex}, \code{L}, \code{a}, \code{b}.
#'
#' @export
spectra_to_rgb_lab <- function(df, id_col = NULL,
                               na_action = c("zero", "drop", "keep"),
                               white = c(X = 95.047, Y = 100, Z = 108.883)) {
  na_action <- match.arg(na_action)
  prep <- .prep_spectra(df, id_col, na_action)
  xyz  <- hs_to_xyz(prep$wavelengths, prep$reflectance)
  rgb  <- xyz_to_rgb(xyz, white = white)
  lab  <- rgb_to_lab(rgb$R, rgb$G, rgb$B, white = white)
  if (na_action == "keep") {
    rgb[prep$na_rows, c("R", "G", "B", "hex")] <- NA
    lab[prep$na_rows, c("L", "a", "b")] <- NA
  }
  cbind(data.frame(Sample_ID = prep$ids, stringsAsFactors = FALSE),
        rgb, lab)
}