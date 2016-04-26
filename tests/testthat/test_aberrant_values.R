library(sswdlHelpR)
context("Aberrant Values")

animals <- readRDS("animals.rds")  # tbl_df
result  <- readRDS("aberrant_animals.rds")

test_that("expected output is produced", {
  expect_identical(aberrant_values(animals), result)
})

test_that("input can be plain (non-tbl_df) data.frame", {
  expect_identical(aberrant_values(as.data.frame(animals)), result)
})

test_that("unexpected inputs throw error", {
  expect_error(aberrant_values(as.list(animals)), "df must be a data.frame")
  expect_error(aberrant_values(1:5),              "df must be a data.frame")
})
