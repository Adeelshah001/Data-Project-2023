# Data Preprocessing Script
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

# Load required libraries
library(dplyr)
library(tidyr)

#' Load and preprocess the video game sales dataset
#' @param filepath Path to the CSV file
#' @return Cleaned data frame
load_and_preprocess <- function(filepath = "../../data/Video_Games.csv") {
  # Load the dataset
  video_games <- read.csv(filepath, stringsAsFactors = FALSE)

  # View basic structure
  cat("Dataset dimensions:", dim(video_games), "\n")
  cat("Column names:", names(video_games), "\n")
  str(video_games)
  summary(video_games)

  return(video_games)
}

#' Create multi-platform indicator variable
#' @param data Video games data frame
#' @return Data frame with Multiple_Platforms column
create_multiplatform_var <- function(data) {
  game_counts <- table(data$Name)
  repeated_titles <- names(game_counts)[game_counts > 1 & nzchar(names(game_counts))]
  data$Multiple_Platforms <- factor(ifelse(data$Name %in% repeated_titles, "yes", "no"))

  return(data)
}

#' Prepare data for regression modeling
#' @param data Video games data frame
#' @param columns Columns to select for regression
#' @return Cleaned regression-ready data frame
prepare_regression_data <- function(data, columns = c("Global_Sales", "Genre", "Platform", "Developer")) {
  regression_data <- data %>%
    select(all_of(columns)) %>%
    na.omit() %>%
    mutate_if(is.character, as.factor)

  return(regression_data)
}

#' Prepare data for tree-based models (with one-hot encoding)
#' @param data Video games data frame
#' @param categorical_vars Categorical variables to encode
#' @param target Target variable name
#' @param max_rows Maximum rows to use (for performance)
#' @return Encoded data frame ready for modeling
prepare_encoded_data <- function(data,
                                 categorical_vars = c("Genre", "Platform", "Developer"),
                                 target = "Global_Sales",
                                 max_rows = 1000) {
  library(caret)

  # Select relevant columns
  model_data <- data[, c(categorical_vars, target)]
  model_data <- na.omit(model_data)

  # Limit rows if specified
  if (nrow(model_data) > max_rows) {
    model_data <- model_data[1:max_rows, ]
  }

  # One-hot encoding
  dummy_data <- dummyVars(" ~ .", data = model_data[, categorical_vars], sep = "_")
  encoded_data <- predict(dummy_data, newdata = model_data)
  encoded_data <- as.data.frame(encoded_data)
  encoded_data[[target]] <- model_data[[target]]

  return(encoded_data)
}

#' Split data into train/test sets
#' @param data Data frame
#' @param target Target variable name
#' @param p Proportion for training (default 0.7)
#' @return List with train_data and test_data
split_train_test <- function(data, target = "Global_Sales", p = 0.7) {
  library(caret)

  train_indices <- createDataPartition(data[[target]], p = p, list = FALSE)
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]

  return(list(train = train_data, test = test_data))
}

# Main execution when sourced directly
if (sys.nframe() == 0) {
  cat("Running data preprocessing...\n")
  vg <- load_and_preprocess()
  vg <- create_multiplatform_var(vg)
  cat("Preprocessing complete.\n")
}
