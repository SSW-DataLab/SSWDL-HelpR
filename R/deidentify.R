library(dplyr)

# Deidentifies a single data frame.
#
# This function removes sensitive columns from the dataset and creates a masked,
# non-sensitive version of ID columns.
#
# Args:
#   df: (data.frame) data to be deidentified; must contain columns to be masked and dropped
#   mask: (character) columns to be masked
#   drop: (character) columns to be removed
#
# Returns:
#   (data.frame) deidentied version of df
deidentify <- function(df, mask = NULL, drop = NULL) {

  # warning messages
  if(is.null(mask) && is.null(drop)) {
    stop("No columns to mask/drop.")
  }

  if(!all(mask %in% names(df)) || !all(drop %in% names(df))) {
    stop("Data frame must contain columns to mask/drop.")
  }

  # make new ID column
  for(column in mask) {
    df[column] <- group_indices_(df, .dots = column)
  }

  # identify columns to keep
  keep_cols <- setdiff(names(df), drop)

  # remove senstive columns and make new id column first column
  df <- select_(df, .dots = keep_cols)

  df
}
