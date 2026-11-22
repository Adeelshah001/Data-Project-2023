# Support Vector Regression (SVR) Model
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(e1071)
library(caret)

#' Train SVR model
#' @param encoded_data One-hot encoded data frame
#' @param target Target variable name
#' @param train_prop Proportion for training
#' @param scale_target Whether to scale target variable
#' @return List with model, predictions, and metrics
train_svr <- function(encoded_data,
                      target = "Global_Sales",
                      train_prop = 0.7,
                      scale_target = TRUE) {

  data <- encoded_data

  # Scale target if requested
  if (scale_target) {
    data[[target]] <- scale(data[[target]])
  }

  # Split data
  set.seed(123)
  train_indices <- sample(1:nrow(data), floor(train_prop * nrow(data)))
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]

  # Train SVR model
  svr_model <- svm(as.formula(paste(target, "~ .")),
                   data = train_data,
                   kernel = "radial")

  # Training metrics
  train_pred <- predict(svr_model, train_data)
  train_rmse <- sqrt(mean((train_pred - train_data[[target]])^2))
  train_rsq <- cor(train_pred, train_data[[target]])^2

  cat("SVR Training Metrics:\n")
  cat("RMSE:", train_rmse, "\n")
  cat("R-squared:", train_rsq, "\n")

  # Test metrics
  test_pred <- predict(svr_model, test_data)
  test_rmse <- sqrt(mean((test_pred - test_data[[target]])^2))
  test_rsq <- cor(test_pred, test_data[[target]])^2
  test_mae <- mean(abs(test_pred - test_data[[target]]))

  cat("SVR Test Metrics:\n")
  cat("RMSE:", test_rmse, "\n")
  cat("R-squared:", test_rsq, "\n")
  cat("MAE:", test_mae, "\n")

  # Model parameters
  cat("Epsilon:", svr_model$epsilon, "\n")
  cat("Gamma:", svr_model$gamma, "\n")
  cat("Support Vectors:", svr_model$tot.nSV, "\n")

  return(list(
    model = svr_model,
    train_predictions = train_pred,
    train_actual = train_data[[target]],
    test_predictions = test_pred,
    test_actual = test_data[[target]],
    metrics = list(
      train_rmse = train_rmse,
      train_rsquared = train_rsq,
      test_rmse = test_rmse,
      test_rsquared = test_rsq,
      test_mae = test_mae
    )
  ))
}

#' Cross-validated SVR
#' @param data Original data with categorical variables
#' @param target Target variable
#' @param cv_folds Number of folds
cv_svr <- function(data, target = "Global_Sales", cv_folds = 5) {
  model_data <- data[, c("Genre", "Platform", "Developer", target)]
  model_data <- na.omit(model_data)
  model_data <- model_data %>% mutate_if(is.character, as.factor)

  ctrl <- trainControl(method = "cv",
                       number = cv_folds,
                       verboseIter = FALSE)

  model <- train(as.formula(paste(target, "~ .")),
                 data = model_data,
                 method = "svmRadial",
                 trControl = ctrl)

  cat("Cross-Validated SVR:\n")
  print(model)

  return(model)
}

# Main execution
if (sys.nframe() == 0) {
  source("../data/data_preprocessing.R")
  vg <- load_and_preprocess()
  encoded <- prepare_encoded_data(vg)
  results <- train_svr(encoded)
  cv_model <- cv_svr(vg)
}