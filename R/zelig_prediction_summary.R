#' Extract summary stats from a simulated Zelig model
#'
#' Returns simulation name, condition name, and the lower quantile (2.5\%), mean (NOT median), and upper quantile (97.5\%) of each simulation-condition pair's expected values (\code{ev}).
#'
#' @param model (\code{Zelig}) a simulated model from the Zelig package with one or more conditions
#'
#' @return \code{tbl_df} with one row per simulation-condition pair, and columns \code{simulation}, \code{condition}, \code{lower}, \code{mean}, \code{upper}
#'
#' @examples
#' z <- zls$new()
#' z$zelig(Fertility ~ Education, data = swiss)
#' z$setx(Education = 5)
#' z$sim()
#' zelig_prediction_summary(z)
#'
#' @import dplyr
#'
#' @export
zelig_prediction_summary <- function(model) {

  # argument validation
  if (!inherits(model, "Zelig")) {
    stop("model must be a Zelig model")
  }

  # isolate simulations and names
  sims      <- model$sim.out
  sim_names <- names(sims)

  # get per-simulation tbl_df's & combine
  Map(summarize_zelig_simulation, sims, sim_names) %>% bind_rows()
}


#### helper functions ####

# usage: summarize_zelig_simulation(z$sim.out$x, "foobar")
summarize_zelig_simulation <- function(sim, name) {

  # get names of different conditions and their expected values
  evs        <- sim$ev[[1]]
  conditions <- dimnames(evs)[2] %>% unlist
  if (is.null(conditions)) conditions <- 1:(dim(evs)[2])  # default

  # this function has only been tested where evs is a matrix (2d) or
  # 3D array where the third dimension is 1; throw error in other cases
  stopifnot(length(dim(evs)) < 3 | dim(evs)[3] == 1)

  # apply the condition function to the second dimension
  results <- evs %>% apply(2, summarize_zelig_condition)

  # combine results and prepend condition names
  results %>%
    bind_rows() %>%
    bind_cols(data_frame(simulation = rep(name, length(results)), condition = conditions), .)
}


# usage:
#   one condition:   summarize_zelig_condition(z$sim.out$x$ev[[1]])
#   mult conditions: summarize_zelig_condition(z$sim.out$x$ev[[1]][, 1, ])
summarize_zelig_condition <- function(x) {
  data_frame(
    lower     = quantile(x, 0.025),
    mean      = mean(x),
    upper     = quantile(x, 0.975)
  )
}
