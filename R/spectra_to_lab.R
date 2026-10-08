#' Convert a data frame of spectra to CIELAB
#'
#' @inheritParams spectra_to_rgb
#'
#' @return A data.frame with columns \code{Sample_ID}, \code{L}, \code{a},
#'   \code{b}.
#'
#' @export
spectra_to_lab <- function(df, id_col = NULL,
                           na_action = c("zero", "drop", "keep"),
                           white = c(X = 95.047, Y = 100, Z = 108.883)) {
  na_action <- match.arg(na_action)
  prep <- .prep_spectra(df, id_col, na_action)
  xyz  <- hs_to_xyz(prep$wavelengths, prep$reflectance)
  lab  <- xyz_to_lab(xyz, white = white)
  if (na_action == "keep") {
    lab[prep$na_rows, c("L", "a", "b")] <- NA
  }
  cbind(data.frame(Sample_ID = prep$ids, stringsAsFactors = FALSE), lab)
}