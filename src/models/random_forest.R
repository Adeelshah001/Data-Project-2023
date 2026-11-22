# Random Forest Model
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(caret)
library(randomForest)

#' Train Random Forest model
#' @param encoded_data One-hot encoded data frame
#' @param target Target variable name
#' @param train_prop Proportion for training
#' @param ntree Number of trees
#' @return List with model, predictions, and metrics
train_random_forest <- function(encoded_data,
                                target = "Global_Sales",
                                train_prop = 0.7,
                                ntree = 100) {

  # Split data
  split <- split_train_test(encoded_data, target, train_prop)
  train_data <- split$train
  test_data <- split$test

  # Separate features and target
  x_train <- train_data[, names(train_data) != target]
  y_train <- train_data[[target]]
  x_test <- test_data[, names(test_data) != target]
  y_test <- test_data[[target]]

  # Convert to matrix for randomForest
  x_train <- as.matrix(x_train)
  x_test <- as.matrix(x_test)

  # Train model
  rf_model <- randomForest(x_train, y_train, ntree = ntree)

  # Predictions
  predictions <- predict(rf_model, newdata = x_test)

  # Evaluation metrics
  mse <- mean((y_test - predictions)^2)
  rmse <- sqrt(mse)
  ssr <- sum((predictions - mean(y_test))^2)
  sst <- sum((y_test - mean(y_test))^2)
  rsquared <- 1 - (ssr / sst)
  mae <- mean(abs(predictions - y_test))

  cat("Random Forest Results:\n")
  cat("MSE:", mse, "\n")
  cat("RMSE:", rmse, "\n")
  cat("R-squared:", rsquared, "\n")
  cat("MAE:", mae, "\n")
  cat("% Var explained:", rf_model$rsq[ntree] * 100, "\n")

  # Plot MSE vs trees
  plot(rf_model$mse, type = "l",
       xlab = "Number of Trees", ylab = "MSE",
       main = "Random Forest: MSE vs Number of Trees")

  return(list(
    model = rf_model,
    predictions = predictions,
    test_actual = y_test,
    metrics = list(mse = mse, rmse = rmse, rsquared = rsquared, mae = mae)
  ))
}

#' Cross-validated Random Forest
#' @param data Original data (not encoded - caret handles encoding)
#' @param target Target variable
#' @param cv_folds Number of folds
cv_random_forest <- function(data, target = "Global_Sales", cv_folds = 5) {
  # Prepare data with categorical variables as factors
  model_data <- data[, c("Genre", "Platform", "Developer", target)]
  model_data <- na.omit(model_data)
  model_data <- model_data %>% mutate_if(is.character, as.factor)

  ctrl <- trainControl(method = "cv",
                       number = cv_folds,
                       verboseIter = TRUE)

  model <- train(as.formula(paste(target, "~ .")),
                 data = model_data,
                 method = "rf",
                 trControl = ctrl,
                 ntree = 100)

  cat("Cross-Validated Random Forest:\n")
  print(model)

  return(model)
}

# Main execution
if (sys.nframe() == 0) {
  source("../data/data_preprocessing.R")
  vg <- load_and_preprocess()
  encoded <- prepare_encoded_data(vg)
  results <- train_random_forest(encoded)
  cv_model <- cv_random_forest(vg)
}