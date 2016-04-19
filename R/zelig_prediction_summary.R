#' Extract and combine summary simulation stats from a Zelig models
#'
#' @param models
#'
#' @export
zelig_prediction_summary <- function(model) {

  # argument validation
  if (!(attributes(class(model))$package == "Zelig")) {
    stop("model must be a Zelig model")
  }

  # isolate simulations
  sims <- model$sim.out

  # per-simulation function
  f <- function(sim) {

    # isolate evs
    evs <- sim$ev

    # per-condition function
    g <- function(ev) {
      dplyr::data_frame(
        lower = quantile(ev, 0.025),
        mean  = mean(ev),
        upper = quantile(ev, 0.975)
      )
    }

    # get a tbl_df with columns (condition, lower, mean, upper) and as many rows as evs
    evs %>%
      lapply(g) %>%
      bind_rows %>%
      bind_cols(data_frame(condition = rownames(sim)), .)
  }

  # get per-simulation tbl_df's, combine, prepend simulation names
  sims %>%
    lapply(f) %>%
    bind_rows %>%
    bind_cols(data_frame(simulation = names(sims)), .)
}
