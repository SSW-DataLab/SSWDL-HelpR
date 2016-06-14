#' Fake social service data
#'
#' Used to test and demonstrate the \code{table_1} function
#'
#' @source \preformatted{
#' set.seed(23112)
#'
#' simulated_social_services <- data_frame(
#'   parent_income = sample(9000:34000, 5000, replace = TRUE),
#'   child_age     = sample(0:9, 5000, replace = TRUE),
#'   time_in_care  = sample(14:730, 5000, replace = TRUE),
#'   sex           = sample(c("male", "female"), 5000, replace = TRUE),
#'   race          = sample(c("black", "white", "asian", "other"), 5000, replace = TRUE, prob = c(.33, .50, .20, .03)),
#'   cohort        = sample(2000:2010, 5000, replace = TRUE),
#'   service_1     = sample(letters[1:2], 5000, replace = TRUE, prob = c(.43, .67)),
#'   service_2     = sample(letters[1:3], 5000, replace = TRUE, prob = c(.33, .44, .23)),
#'   service_3     = sample(letters[1:4], 5000, replace = TRUE, prob = c(.21, .33, .28, .18))
#' ) \%>\%
#'   mutate_each(funs(factor), sex, race, cohort, service_1, service_2, service_3)
#' }
#'
"simulated_social_services"
