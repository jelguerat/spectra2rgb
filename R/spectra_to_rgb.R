#' Convert a data frame of spectra to sRGB
#'
#' @param df A data.frame or matrix where each row is a sample and each
#'   column is a wavelength band. Column names must be parseable as
#'   numeric wavelengths in nanometres.
#' @param id_col Optional character vector of sample IDs, or a column name
#'   or index in \code{df}. If \code{NULL}, the row names are used, or
#'   \code{seq_len(nrow(df))} if row names are absent.
#' @param na_action One of \code{"zero"} (default; replace non-finite with
#'   0), \code{"drop"} (remove all-NA rows with a warning), or
#'   \code{"keep"} (preserve NA in the output).
#' @param white Reference white point for XYZ -> sRGB.
#'
#' @return A data.frame with columns \code{Sample_ID}, \code{R}, \code{G},
#'   \code{B}, \code{hex}.
#'
#' @export
spectra_to_rgb <- function(df, id_col = NULL,
                           na_action = c("zero", "drop", "keep"),
                           white = c(X = 95.047, Y = 100, Z = 108.883)) {
  na_action <- match.arg(na_action)
  prep <- .prep_spectra(df, id_col, na_action)
  xyz  <- hs_to_xyz(prep$wavelengths, prep$reflectance)
  rgb  <- xyz_to_rgb(xyz, white = white)
  if (na_action == "keep") {
    rgb[prep$na_rows, c("R", "G", "B", "hex")] <- NA
  }
  cbind(data.frame(Sample_ID = prep$ids, stringsAsFactors = FALSE), rgb)
}