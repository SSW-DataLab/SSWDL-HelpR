#' Create a "table 1" from a data.frame
#'
#' Given a factor variable to group on (\code{dimension}), this will summarize the other variables terms of that one, and optionally include overall columns with summaries that ignore the dimension groupings. This will not return a ready-to-publish table, but does most of the hard work (the grouped computations).
#'
#' For each level of \code{dimension}, the output will return a count and percentage for each level of other factor variabls, or a mean and standard deviation for the numeric variables.
#' All columns are of type \code{character} to preserve formatting.
#'
#' @param df (\code{data.frame}) the data to summarize
#' @param dimension (\code{character}) the name of a column in \code{df} to use as the dimensions; used to form columns of the output
#' @param overall (\code{logical}) should a pair of overall columns be generated?
#'
#' @return \code{data.frame} with two columns per level of \code{dimension} (and two more if \code{overall=TRUE}) suffixed by "_count"/"_percent", one row for each numeric column of \code{df}, and one row for each level of each non-\code{dimension} factor column of \code{df}, preceded by the name of that factor column.
#'
#' @examples
#' table_1(simulated_social_services, "service_1")
#' table_1(simulated_social_services, "service_1", overall = TRUE)
#' table_1(simulated_social_services, "service_2")
#'
#' @import dplyr
#'
#' @export
table_1 <- function(df, dimension = NULL, overall = FALSE) {

  # validate df
  if (!is.data.frame(df)) stop("df must be a data.frame")
  if (sum(sapply(df, function(x) !(is.numeric(x) | is.factor(x)))) > 0) stop("all columns must be either numeric or factor columns")

  # check names, convert + warn if needed
  if (all.equal(names(df), make.names(names(df))) != TRUE) {
    warning("Found invalid names; they will be converted using make.names")
    names(df) <- make.names(names(df))
    dimension <- make.names(dimension)
  }

  # cast df to tbl if it isn't already so we can use dplyr functions
  if (!is.tbl(df)) df <- as.tbl(df)

  # select and validate dimension column
  if (is.null(dimension)) dimension <- names(df)[1]
  if (!(dimension %in% names(df))) stop("dimension must be the name of a column in df")
  if (!is.factor(magrittr::extract2(df, dimension))) stop("dimension must be a factor column")

  # run helper function on each non-dimension column and combine
  table_one <- df %>%
    names %>%
    setdiff(dimension) %>%  # don't apply to dimension col
    lapply(make_subtable, df, dimension, overall) %>%
    bind_rows %>%
    as.data.frame

  # create an overall column with recursion
  if (overall) {
    overall_table <- df %>%
      mutate_(.dots = setNames(list(~as.factor("overall")), dimension)) %>%
      table_1(dimension, overall = FALSE) %>%
      select(-variable)

    table_one <- table_one %>% cbind(overall_table)
  }

  table_one
}


#### helper functions ####

make_subtable <- function(x, df, dimension, overall) {
  col <- magrittr::extract2(df, x)

  # dispatch appropriate function
  if (is.factor(col)) {
    subtable <- subtable_factor(x, df, dimension, overall)
  } else if (is.numeric(col)) {
    subtable <- subtable_numeric(x, df, dimension, overall)
  } else {
    stop("Column \"", x, "\" is neither factor nor numeric")
  }

  subtable
}


subtable_factor <- function(x, df, dimension, overall) {
  # create table of count/percent values, grouped by dimension and x
  subtable <- df %>%
    group_by_(.dots = c(dimension, x)) %>%
    summarise(count = n()) %>%  # drops x from grouping implicitly
    mutate(percent = trimws(format(round(count / sum(count) * 100, 1), nsmall = 1))) %>%
    ungroup %>%
    mutate_each(funs(as.character)) %>%
    mutate(percent = paste0(percent, "%"))

  # manipulate this table to be in the format we need
  subtable <- subtable %>% format_subtable(dimension, x)

  # rename the first column so all tables from this function have the same columns
  names(subtable)[1] <- "variable"

  # prepend a mostly-empty row with the variable name
  subtable <- subtable %>%
    rbind(
      as_data_frame(setNames(c(x, as.list(rep("", length(names(subtable)) - 1))), names(subtable))),
      .
    )

  subtable
}


subtable_numeric <- function(x, df, dimension, overall) {

  subtable <- df %>%
    group_by_(dimension) %>%
    summarize_(.dots = setNames(lapply(list(~mean(var), ~sd(var)), lazyeval::interp, var = as.name(x)), c("count", "percent"))) %>%
    mutate_each(funs(round(., 1) %>% format(nsmall = 1)), count, percent)
    ungroup

  # manipulate this table to be in the format we need
  subtable <- subtable %>% format_subtable(dimension)

  # prepend variable name
  subtable <- subtable %>%
    mutate(variable = x) %>%
    select(variable, everything())

  subtable
}


format_subtable <- function(subtable, dimension, x = NULL) {
  subtable <- subtable %>% tidyr::gather_("colname", "value", c("count", "percent"), factor_key = TRUE)
  subtable$colname <- paste(magrittr::extract2(subtable, dimension), subtable$colname, sep = "_")  # TODO: convert to mutate_
  subtable <- subtable %>%
    select_(.dots = c(x, "colname", "value") %>% as.list) %>%  # using c first drops x if null
    tidyr::spread_("colname", "value")

  subtable
}
