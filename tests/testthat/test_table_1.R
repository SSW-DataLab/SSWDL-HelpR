library(dplyr)
library(readr)
context("table_1")


#### sample input frame ####

set.seed(23112)

test_frame <- data_frame(
  parent_income = sample(9000:34000, 5000, replace = TRUE),
  child_age     = sample(0:9, 5000, replace = TRUE),
  time_in_care  = sample(14:730, 5000, replace = TRUE),
  sex           = sample(c("male", "female"), 5000, replace = TRUE),
  race          = sample(c("black", "white", "asian", "other"), 5000, replace = TRUE, prob = c(.33, .50, .20, .03)),
  cohort        = sample(2000:2010, 5000, replace = TRUE),
  service_1     = sample(letters[1:2], 5000, replace = TRUE, prob = c(.43, .67)),
  service_2     = sample(letters[1:3], 5000, replace = TRUE, prob = c(.33, .44, .23)),
  service_3     = sample(letters[1:4], 5000, replace = TRUE, prob = c(.21, .33, .28, .18))
) %>%
  mutate_each(funs(factor), sex, race, cohort, service_1, service_2, service_3)


#### argument validation ####

test_that("table_1 validates df input", {
  expect_error(
    test_frame %>% as.list %>% table_1("service_1"),
    "df must be a data.frame"
  )
  expect_error(
    test_frame %>% mutate(foobar = rep_len(c(T, F), nrow(test_frame))) %>% table_1("service_1"),
    "all columns must be either numeric or factor columns"
  )
})

test_that("table_1 checks and converts names of df", {
  expect_warning(
    test_frame %>% rename_(.dots = list("parent income" = "parent_income")) %>% table_1("service_1"),
    "Found invalid names; they will be converted using make.names"
  )
})

test_that("table_1 validated dimension input", {
  expect_error(table_1(test_frame, "foobar"),        "dimension must be the name of a column in df")
  expect_error(table_1(test_frame, "parent_income"), "dimension must be a factor column")
})


#### functional validation ####

test_that("table_1 produces expected outputs for different groupings", {
  # read test outputs so they display as expected
  ReadTestOutput <- function(x) read.csv(x, stringsAsFactors = FALSE, colClasses = "character")

  # group by each service_* column individually, excluding the others
  expect_equal(
    test_frame %>% select(-service_2, -service_3) %>% table_1("service_1"),
    ReadTestOutput("table_1-service_1.csv")
  )
#   expect_equal(
#     test_frame %>% select(-service_1, -service_3) %>% table_1("service_2"),
#     ReadTestOutput("tests/testthat/table_1-service_2.csv")
#   )
#   expect_equal(
#     test_frame %>% select(-service_1, -service_2) %>% table_1("service_3"),
#     ReadTestOutput("tests/testthat/table_1-service_3.csv")
#   )
})


#### regressions ####

# https://github.com/SSW-DataLab/sswdlHelpR/pull/11
new_test <- test_frame %>% mutate(sex2 = sample(sex, n())) %>% select(service_1, sex, sex2)
test_that("columns with the same factor levels don't cause issues with overall = TRUE", {
  new_test <- test_frame %>% mutate(sex2 = sample(sex, n())) %>% select(service_1, sex, sex2)

  expect_equal(
    new_test %>% table_1("service_1")                 %>% nrow,
    new_test %>% table_1("service_1", overall = TRUE) %>% nrow
  )
})
