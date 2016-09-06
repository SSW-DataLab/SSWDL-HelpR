#' Deidentify a single data frame.
#'
#' This removes sensitive columns from a dataset and masks ID columns by mapping levels to integers.
#'
#' @param df (\code{data.frame}) the dataset to deidentify
#' @param mask (\code{character}) names of columns in \code{df} to mask
#' @param drop (\code{character}) names of columns in \code{df} to drop
#'
#' @return \code{data.frame} \code{df} with drop columns removed and mask columns replaced
#'
#' @examples
#' deidentify(mtcars, mask = c("mpg", "cyl"), drop = c("vs", "am"))
#'
#' @export
deidentify <- function(df, mask = NULL, drop = NULL) {

  # validate df
  if (!is.data.frame(df)) stop("df must be a data.frame")

  # ensure there's something to do
  if (is.null(mask) & is.null(drop)) {
    stop("no columns to mask/drop.")
  }

  # validate mask
  if (!is.null(mask)) {
    if (!is.character(mask)) stop("mask must be a character vector")
    if (any(!(mask %in% names(df)))) stop("all columns in mask must be in df")
  }

  # validate drop
  if (!is.null(drop)) {
    if (!is.character(drop)) stop("drop must be a character vector")
    if (any(!(drop %in% names(df)))) stop("all columns in drop must be in df")
  }

  # mask ID columns
  if (!is.null(mask)) {
    for (column in mask) {
      df[column] <- group_indices_(df, .dots = column)
    }
  }

  # remove drop columns
  if (!is.null(drop)) {
    df <- dplyr::select_(df, .dots = setdiff(names(df), drop))
  }

  df
}
