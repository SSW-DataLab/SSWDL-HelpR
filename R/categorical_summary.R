#' Create a summary table of a data.frame's categorical (factor) variables.
#'
#' This will output a two-column table where the first is the name of the column and the second is the name of that column's levels.
#'
#' @param df The \code{data.frame} to create a categorical summary from
#'
#' @return A \code{tbl_df} with two columns, \code{variable} and \code{levels}. The \code{variable} column contains the name of each categorical column, repeated for each level it had, in the same order as in \code{df}. The \code{levels} column contains each level for the associated \code{variable}.
#'
#' @examples
#' df <- data.frame(
#'   id = 1:5,
#'   gender = factor(c("M", "F", "M", "M", "F")),
#'   race = factor(c("white", "white", "black", "black", "other"))
#' )
#' categorical_summary(df)
#'
#' @import dplyr
#'
#' @export
categorical_summary <- function(df) {

  # argument validation
  if (!is.data.frame(df)) stop("df must be a data.frame")
  if (sum(sapply(df, is.factor)) == 0) stop("df has no categorical (factor) columns")

  # table creation
  df %>%
    sapply(is.factor) %>%
    which %>%
    names %>%
    lapply(function(x) {
      data_frame(
        variable = as.character(x),
        levels   = as.character(levels(df[[x]]))
      )
    }) %>%
    bind_rows()

}
