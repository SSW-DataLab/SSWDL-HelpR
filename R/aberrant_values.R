#' Create a summary table which, for each row, displays the rows name, type, number of unique values, and number and percentage of missing values.
#'
#' @param df the \code{data.frame} to create a summary from
#'
#' @return A \code{tbl_df} with one row per column of \code{df} and columns (column, class, n_distinct, n_NA, n_not_NA, pct_NA)
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
    n_NA       = sapply(df, function(x) sum(is.na(x))),
    n_not_NA   = sapply(df, function(x) sum(!is.na(x))),
    pct_NA     = sapply(df, function(x) round(sum(is.na(x)) / nrow(df) * 100, 2))
  )
}
