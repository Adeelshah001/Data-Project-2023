# Linear Regression Model
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(caret)
library(dplyr)

#' Train linear regression model with cross-validation
#' @param data Regression-ready data frame
#' @param target Target variable name
#' @param train_prop Proportion for training
#' @param cv_folds Number of CV folds
#' @return List with model, predictions, and metrics
train_linear_regression <- function(data,
                                    target = "Global_Sales",
                                    train_prop = 0.7,
                                    cv_folds = 5) {

  # Split data
  split <- split_train_test(data, target, train_prop)
  train_data <- split$train
  test_data <- split$test

  # Train model with cross-validation
  ctrl <- trainControl(method = "cv",
                       number = cv_folds,
                       verboseIter = FALSE)

  model <- train(as.formula(paste(target, "~ .")),
                 data = train_data,
                 method = "lm",
                 trControl = ctrl)

  # Predict on test set
  predictions <- predict(model, newdata = test_data)

  # Evaluation metrics
  rmse <- sqrt(mean((predictions - test_data[[target]])^2))
  rsquared <- cor(predictions, test_data[[target]])^2
  mae <- mean(abs(predictions - test_data[[target]]))

  cat("Linear Regression Results:\n")
  cat("RMSE:", rmse, "\n")
  cat("R-squared:", rsquared, "\n")
  cat("MAE:", mae, "\n")

  # Full model summary for diagnostics
  full_model <- lm(as.formula(paste(target, "~ .")), data = data)
  summary_full <- summary(full_model)

  # Diagnostic plots
  par(mfrow = c(2, 2))
  plot(full_model)
  par(mfrow = c(1, 1))

  # Cook's distance
  cooks_d <- cooks.distance(full_model)
  plot(cooks_d, main = "Cook's Distance")
  influential <- which(cooks_d > 4/nrow(data))
  cat("Influential observations (Cook's D > 4/n):", influential, "\n")

  return(list(
    model = model,
    full_model = full_model,
    predictions = predictions,
    test_actual = test_data[[target]],
    metrics = list(rmse = rmse, rsquared = rsquared, mae = mae),
    influential_points = influential
  ))
}

#' Cross-validated linear regression with detailed metrics
#' @param data Full data frame
#' @param target Target variable
#' @param cv_folds Number of folds
cv_linear_regression <- function(data, target = "Global_Sales", cv_folds = 5) {
  ctrl <- trainControl(method = "cv",
                       number = cv_folds,
                       verboseIter = FALSE)

  model <- train(as.formula(paste(target, "~ .")),
                 data = data,
                 method = "lm",
                 trControl = ctrl)

  cat("Cross-Validated Linear Regression:\n")
  print(model)

  return(model)
}

# Main execution
if (sys.nframe() == 0) {
  source("../data/data_preprocessing.R")
  vg <- load_and_preprocess()
  reg_data <- prepare_regression_data(vg)
  results <- train_linear_regression(reg_data)
  cv_model <- cv_linear_regression(reg_data)
}