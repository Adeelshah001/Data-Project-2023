library(caret)
library(xgboost)

data <- read.csv(commandArgs(trailingOnly = TRUE)[1], na.strings = c("", "NA"))
data <- data[-1, c("Genre", "Platform", "Publisher", "Developer", "Global_Sales")]
data <- na.omit(data)[1:1000, ]
set.seed(42)
fit <- train(
  Global_Sales ~ .,
  data = data,
  method = "xgbTree",
  trControl = trainControl(method = "cv", number = 3, verboseIter = FALSE),
  verbosity = 0,
  nthread = 1
)
print(fit$bestTune)
print(merge(fit$bestTune, fit$results))
