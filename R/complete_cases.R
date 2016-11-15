#' Check for complete cases in a data-frame based on a subset of columns
#' 
#' This is an update to the base-R \code{complete.cases()} function, but allows the user to specify columns to include/drop on the fly. 
#' This is useful in instances where a variable/column may have NA values that were introduced during joins or other commands that a user is aware of.
#' 
#' @param df \code{data.frame} being checked
#' @param vars \code{character} vector of column names to be included/excluded based on \code{dplyr::select()}
#' 
#' @return A \code{logical} vector, indicating whether a case/row is *not* missing data.
#' 
#' @import dplyr
#' 
#' @export 
complete_cases <- function(df, vars = NULL) {
  if (is.null(vars)) {
    complete.cases(df)
  } else {
    df %>% 
      select_(.dots = vars) %>% 
      complete.cases
  }
}
