library(sswdlHelpR)
library(Zelig)
library(dplyr)

context("Zelig Prediction Summary")

set.seed(1234)

test_that("zelig_prediction_summary validates input", {
  expect_error(zelig_prediction_summary(list(mtcars = mtcars)), "model must be a Zelig model")
})

# custom comparison function
expect_equal_summaries <- function(x, y) {
  rounder <- function(x) mutate_each(x, funs(round(., 5)), lower, mean, upper)

  expect_equal(rounder(x), rounder(y))
}

#### ls model ####

# adapted from http://docs.zeligproject.org/en/latest/installation_quickstart.html#quickstart-guide
z <- zls$new()
z$zelig(Fertility ~ Education, data = swiss)
z$setx(Education = 5)
z$sim()

expectation <- data_frame(
  simulation = "x",
  condition  = "1",
  lower      = 72.10425,
  mean       = 75.33275,
  upper      = 78.48296
)

expect_equal_summaries(zelig_prediction_summary(z), expectation)

# add another simulation point
z$setx1(Education = 15)
z$sim()

expectation <- data_frame(
  simulation = c("x", "x1"),
  condition  = c("1", "1"),
  lower      = c(72.17420, 63.90556),
  mean       = c(75.33191, 66.73478),
  upper      = c(78.76657, 69.49198)
)

expect_equal_summaries(zelig_prediction_summary(z), expectation)


#### mlogit model (named conditions) ####

# adapted from http://docs.zeligproject.org/en/latest/zelig-mlogitbayes.html
data(mexico)
z <- zelig(
  vote88 ~ pristr + othcok + othsocok,
  model = "mlogit.bayes",
  data = mexico,
  verbose = FALSE
)
z$setx()
z$sim()

expectation <- data_frame(
  simulation = c("x", "x", "x"),
  condition  = c("P(Y=1)", "P(Y=2)", "P(Y=3)"),
  lower      = c(0.530663971616597, 0.185431163229329, 0.203358998253076),
  mean       = c(0.561336785360835, 0.209912432414783, 0.228750782224382),
  upper      = c(0.591496311283821, 0.235089121964779, 0.255815314233621)
)

expect_equal_summaries(zelig_prediction_summary(z), expectation)

