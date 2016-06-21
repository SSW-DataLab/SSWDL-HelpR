library(sswdlHelpR)
context("Categorical Summary")

test_frame <- data_frame(
  id     = 1:5,
  gender = factor(c("M", "F", "M", "M", "F")),
  race   = factor(c("white", "white", "black", "black", "other"))
)

test_that("categorical_summary validates input", {
  expect_error(categorical_summary(as.list(test_frame)), "df must be a data.frame")
  expect_error(categorical_summary(test_frame[, "id"]),  "df has no categorical"  )
})

test_that("categorical_summary produces expected output", {
  expect_identical(
    categorical_summary(test_frame),
    data_frame(
      variable = rep(c("gender", "race"), times = c(2, 3)),
      levels = c("F", "M", "black", "other", "white")
    )
  )
})
