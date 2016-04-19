#' Extract and combine summary simulation stats from a Zelig models
#'
#' @param models
#'
#' @importFrom magrittr %>%
#'
#' @export
zelig_prediction_summary <- function(model) {

  # argument validation
  if (!(attributes(class(model))$package == "Zelig")) {
    stop("model must be a Zelig model")
  }

  # isolate simulations and names
  sims      <- model$sim.out
  sim_names <- names(sims)

  # get per-simulation tbl_df's & combine
  Map(summarize_zelig_simulation, sims, sim_names) %>% dplyr::bind_rows()
}


#### helper functions ####

# usage: summarize_zelig_simulation(z$sim.out$x)
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
    dplyr::bind_rows() %>%
    dplyr::bind_cols(dplyr::data_frame(simulation = rep(name, length(results)), condition = conditions), .)
}


# usage: summarize_zelig_condition(z$sim.out$x$ev[[1]], rownames(z$sim.out$x)[1])
summarize_zelig_condition <- function(x) {
  dplyr::data_frame(
    lower     = quantile(x, 0.025),
    mean      = mean(x),
    upper     = quantile(x, 0.975)
  )
}
