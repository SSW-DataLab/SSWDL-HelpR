#' Create a summary table of aberrant values of a data.frame
#'
#' This creates a table of the column names, types, number of unique values, and number and percentage of missing values for each column in the input.
#'
#' @param df A \code{data.frame} to create a summary from
#'
#' @return A \code{tbl_df} with one row per column of \code{df} and columns \code{column}, \code{class}, \code{n_distinct}, \code{n_NA}, \code{n_not_NA}, \code{pct_NA}
#'
#' @export
aberrant_values <- function(df) {

  # validate the input
  if (!is.data.frame(df)) stop("df must be a data.frame")

  # construct a tbl_df of the desired outputs
  dplyr::data_frame(
    column     = colnames(df),
    class      = sapply(df, class),
    n_distinct = sapply(df, dplyr::n_distinct),
    n_na       = sapply(df, function(x) sum(is.na(x))),
    n_not_na   = sapply(df, function(x) sum(!is.na(x))),
    pct_na     = sapply(df, function(x) round(sum(is.na(x)) / nrow(df) * 100, 2))
  )
}
