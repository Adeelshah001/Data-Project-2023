# XGBoost Model
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(xgboost)
library(caret)

#' Train XGBoost model
#' @param encoded_data One-hot encoded data frame
#' @param target Target variable name
#' @param train_prop Proportion for training
#' @param params XGBoost parameters
#' @param nrounds Number of boosting rounds
#' @return List with model, predictions, and metrics
train_xgboost <- function(encoded_data,
                          target = "Global_Sales",
                          train_prop = 0.7,
                          params = list(
                            objective = "reg:squarederror",
                            eta = 0.1,
                            max_depth = 3
                          ),
                          nrounds = 100) {

  # Split data
  set.seed(123)
  train_indices <- sample(1:nrow(encoded_data), floor(train_prop * nrow(encoded_data)))
  train_data <- encoded_data[train_indices, ]
  test_data <- encoded_data[-train_indices, ]

  # Prepare features and target
  train_features <- train_data[, names(train_data) != target]
  train_target <- train_data[[target]]
  test_features <- test_data[, names(test_data) != target]
  test_target <- test_data[[target]]

  # Convert to matrix
  train_matrix <- as.matrix(train_features)
  test_matrix <- as.matrix(test_features)

  # Train model
  model <- xgboost(data = train_matrix,
                   label = train_target,
                   params = params,
                   nrounds = nrounds,
                   verbose = 0)

  # Predictions
  predictions <- predict(model, newdata = test_matrix)

  # Evaluation metrics
  mse <- mean((predictions - test_target)^2)
  rmse <- sqrt(mse)
  mae <- mean(abs(predictions - test_target))
  ss_total <- sum((test_target - mean(test_target))^2)
  ss_residual <- sum((predictions - test_target)^2)
  r_squared <- 1 - (ss_residual / ss_total)

  cat("XGBoost Results:\n")
  cat("MSE:", mse, "\n")
  cat("RMSE:", rmse, "\n")
  cat("MAE:", mae, "\n")
  cat("R-squared:", r_squared, "\n")

  # Feature importance
  importance <- xgb.importance(feature_names = colnames(train_matrix), model = model)
  print(head(importance, 20))
  xgb.plot.importance(importance[1:20])

  return(list(
    model = model,
    predictions = predictions,
    test_actual = test_target,
    metrics = list(mse = mse, rmse = rmse, mae = mae, rsquared = r_squared),
    importance = importance
  ))
}

#' Cross-validated XGBoost with hyperparameter tuning
#' @param data Original data with categorical variables
#' @param target Target variable
#' @param cv_folds Number of folds
cv_xgboost <- function(data, target = "Global_Sales", cv_folds = 3) {
  model_data <- data[, c("Genre", "Platform", "Publisher", "Developer", target)]
  model_data <- na.omit(model_data)
  model_data <- model_data %>% mutate_if(is.character, as.factor)

  ctrl <- trainControl(method = "cv",
                       number = cv_folds,
                       verboseIter = FALSE)

  # Tune grid
  tune_grid <- expand.grid(
    nrounds = c(50, 100),
    max_depth = c(3, 6),
    eta = c(0.1, 0.3),
    gamma = 0,
    colsample_bytree = 1,
    min_child_weight = 1,
    subsample = 1
  )

  model <- train(as.formula(paste(target, "~ .")),
                 data = model_data,
                 method = "xgbTree",
                 trControl = ctrl,
                 tuneGrid = tune_grid,
                 verbosity = 0)

  cat("Cross-Validated XGBoost:\n")
  print(model)
  print(model$results)

  return(model)
}

#' Train XGBoost with early stopping
#' @param encoded_data One-hot encoded data frame
#' @param target Target variable name
#' @param params XGBoost parameters
#' @param nrounds Maximum number of rounds
#' @param early_stopping_rounds Early stopping rounds
train_xgboost_early_stop <- function(encoded_data,
                                     target = "Global_Sales",
                                     params = list(
                                       objective = "reg:squarederror",
                                       eta = 0.1,
                                       max_depth = 3
                                     ),
                                     nrounds = 1000,
                                     early_stopping_rounds = 50) {

  # Split into train/validation/test
  set.seed(123)
  n <- nrow(encoded_data)
  train_idx <- sample(1:n, floor(0.6 * n))
  val_idx <- sample(setdiff(1:n, train_idx), floor(0.2 * n))
  test_idx <- setdiff(1:n, c(train_idx, val_idx))

  train_data <- encoded_data[train_idx, ]
  val_data <- encoded_data[val_idx, ]
  test_data <- encoded_data[test_idx, ]

  train_matrix <- xgb.DMatrix(as.matrix(train_data[, names(train_data) != target]),
                              label = train_data[[target]])
  val_matrix <- xgb.DMatrix(as.matrix(val_data[, names(val_data) != target]),
                            label = val_data[[target]])
  test_matrix <- xgb.DMatrix(as.matrix(test_data[, names(test_data) != target]),
                             label = test_data[[target]])

  # Train with early stopping
  model <- xgb.train(params = params,
                     data = train_matrix,
                     nrounds = nrounds,
                     watchlist = list(train = train_matrix, eval = val_matrix),
                     early_stopping_rounds = early_stopping_rounds,
                     verbose = 0)

  # Test predictions
  predictions <- predict(model, test_matrix)
  test_target <- test_data[[target]]

  mse <- mean((predictions - test_target)^2)
  rmse <- sqrt(mse)
  mae <- mean(abs(predictions - test_target))
  r_squared <- 1 - sum((predictions - test_target)^2) / sum((test_target - mean(test_target))^2)

  cat("XGBoost with Early Stopping:\n")
  cat("Best iteration:", model$best_iteration, "\n")
  cat("RMSE:", rmse, "\n")
  cat("MAE:", mae, "\n")
  cat("R-squared:", r_squared, "\n")

  return(list(
    model = model,
    predictions = predictions,
    test_actual = test_target,
    metrics = list(mse = mse, rmse = rmse, mae = mae, rsquared = r_squared)
  ))
}

# Main execution
if (sys.nframe() == 0) {
  source("../data/data_preprocessing.R")
  vg <- load_and_preprocess()
  encoded <- prepare_encoded_data(vg, categorical_vars = c("Genre", "Platform", "Publisher", "Developer"))
  results <- train_xgboost(encoded)
  cv_model <- cv_xgboost(vg)
}