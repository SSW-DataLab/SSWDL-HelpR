library(dplyr)
library(readr)
context("table_1")


#### argument validation ####

test_that("table_1 validates df input", {
  expect_error(
    simulated_social_services %>% as.list %>% table_1("service_1"),
    "df must be a data.frame"
  )
  expect_error(
    simulated_social_services %>% mutate(foobar = rep_len(c(T, F), nrow(simulated_social_services))) %>% table_1("service_1"),
    "all columns must be either numeric or factor columns"
  )
})

test_that("table_1 checks and converts names of df", {
  expect_warning(
    simulated_social_services %>% rename_(.dots = list("parent income" = "parent_income")) %>% table_1("service_1"),
    "Found invalid names; they will be converted using make.names"
  )
})

test_that("table_1 validated dimension input", {
  expect_error(table_1(simulated_social_services, "foobar"),        "dimension must be the name of a column in df")
  expect_error(table_1(simulated_social_services, "parent_income"), "dimension must be a factor column")
})


#### functional validation ####

test_that("table_1 produces expected outputs for different groupings", {
  # read test outputs so they display as expected
  ReadTestOutput <- function(x) read.csv(x, stringsAsFactors = FALSE, colClasses = "character")

  # group by each service_* column individually, excluding the others
  expect_equal(
    simulated_social_services %>% select(-service_2, -service_3) %>% table_1("service_1"),
    ReadTestOutput("table_1-service_1.csv")
  )
#   expect_equal(
#     simulated_social_services %>% select(-service_1, -service_3) %>% table_1("service_2"),
#     ReadTestOutput("tests/testthat/table_1-service_2.csv")
#   )
#   expect_equal(
#     simulated_social_services %>% select(-service_1, -service_2) %>% table_1("service_3"),
#     ReadTestOutput("tests/testthat/table_1-service_3.csv")
#   )
})


#### regressions ####

# https://github.com/SSW-DataLab/sswdlHelpR/pull/11
new_test <- simulated_social_services %>% mutate(sex2 = sample(sex, n())) %>% select(service_1, sex, sex2)
test_that("columns with the same factor levels don't cause issues with overall = TRUE", {
  new_test <- simulated_social_services %>% mutate(sex2 = sample(sex, n())) %>% select(service_1, sex, sex2)

  expect_equal(
    new_test %>% table_1("service_1")                 %>% nrow,
    new_test %>% table_1("service_1", overall = TRUE) %>% nrow
  )
})
