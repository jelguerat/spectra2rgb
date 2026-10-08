# Internal helper: validate and normalise a spectra data.frame.
# Returns list(wavelengths, reflectance, ids, na_rows).
.prep_spectra <- function(df, id_col, na_action) {
  if (is.matrix(df)) df <- as.data.frame(df)
  if (!is.data.frame(df)) stop("`df` must be a data.frame or matrix.")
  
  # --- Resolve IDs -----------------------------------------------------
  ids <- NULL
  if (!is.null(id_col)) {
    if (is.character(id_col) && length(id_col) == 1L &&
        id_col %in% names(df)) {
      ids <- as.character(df[[id_col]])
      df  <- df[, setdiff(names(df), id_col), drop = FALSE]
    } else if (is.numeric(id_col) && length(id_col) == 1L) {
      ids <- as.character(df[[id_col]])
      df  <- df[, -id_col, drop = FALSE]
    } else if (is.character(id_col) &&
               length(id_col) == nrow(df)) {
      ids <- id_col
    } else {
      stop("`id_col` must be NULL, a column name, a column index, ",
           "or a character vector of length nrow(df).")
    }
  } else if (!is.null(rownames(df)) &&
             !identical(rownames(df), as.character(seq_len(nrow(df))))) {
    ids <- rownames(df)
  } else {
    ids <- as.character(seq_len(nrow(df)))
  }
  
  # --- Parse wavelengths from column names ----------------------------
  wl <- suppressWarnings(as.numeric(names(df)))
  if (anyNA(wl)) {
    stop("All column names of `df` must be numeric wavelengths (nm). ",
         "Offending columns: ",
         paste(utils::head(names(df)[is.na(wl)], 5), collapse = ", "))
  }
  o <- order(wl)
  wl <- wl[o]
  df <- df[, o, drop = FALSE]
  
  # --- Detect all-NA rows ---------------------------------------------
  na_rows <- rowSums(is.na(df)) == ncol(df)
  
  if (na_action == "drop" && any(na_rows)) {
    warning(sprintf("Dropped %d all-NA sample(s): %s",
                    sum(na_rows),
                    paste(ids[na_rows], collapse = ", ")))
    df  <- df[!na_rows, , drop = FALSE]
    ids <- ids[!na_rows]
    na_rows <- rep(FALSE, nrow(df))
  }
  
  reflectance <- as.matrix(df)
  reflectance <- matrix(as.numeric(reflectance),
                        nrow = nrow(reflectance),
                        ncol = ncol(reflectance))
  
  list(wavelengths  = wl,
       reflectance  = reflectance,
       ids          = ids,
       na_rows      = na_rows)
}