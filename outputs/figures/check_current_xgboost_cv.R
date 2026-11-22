source("../data/data_preprocessing.R")
source("xgboost.R")

# Use the same fast histogram method as recent XGBoost, with the older caret-compatible API.
train <- function(...) caret::train(..., tree_method = "hist", nthread = 1)
data <- read.csv("../../data/Video_Games.csv", stringsAsFactors = FALSE)
set.seed(123)
fit <- cv_xgboost(data)
print(merge(fit$bestTune, fit$results))
