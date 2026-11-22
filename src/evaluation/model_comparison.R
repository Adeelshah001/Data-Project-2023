# Model Evaluation and Comparison
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(ggplot2)
library(dplyr)
library(reshape2)

#' Compare multiple models' performance
#' @param results_list Named list of model results (each with $metrics)
#' @return Comparison data frame
compare_models <- function(results_list) {
  metrics_df <- data.frame()

  for (model_name in names(results_list)) {
    metrics <- results_list[[model_name]]$metrics
    metrics_df <- rbind(metrics_df, data.frame(
      Model = model_name,
      RMSE = metrics$rmse %||% metrics$test_rmse %||% NA,
      MAE = metrics$mae %||% metrics$test_mae %||% NA,
      R_Squared = metrics$rsquared %||% metrics$test_rsquared %||% metrics$R_squared %||% NA,
      stringsAsFactors = FALSE
    ))
  }

  # Sort by RMSE (lower is better)
  metrics_df <- metrics_df[order(metrics_df$RMSE), ]

  cat("Model Comparison (sorted by RMSE):\n")
  print(metrics_df)

  return(metrics_df)
}

#' Plot model comparison
#' @param comparison_df Output from compare_models()
plot_model_comparison <- function(comparison_df) {
  # Melt for ggplot
  plot_data <- melt(comparison_df, id.vars = "Model",
                    measure.vars = c("RMSE", "MAE", "R_Squared"),
                    variable.name = "Metric", value.name = "Value")

  # RMSE and MAE - lower is better
  # R_Squared - higher is better

  p <- ggplot(plot_data, aes(x = reorder(Model, Value), y = Value, fill = Metric)) +
    geom_bar(stat = "identity", position = "dodge") +
    facet_wrap(~ Metric, scales = "free_y") +
    coord_flip() +
    labs(title = "Model Performance Comparison",
         x = "Model", y = "Value") +
    theme_minimal() +
    theme(legend.position = "none")

  print(p)
  return(p)
}

#' Detailed evaluation with cross-validation results
#' @param cv_models List of cross-validated models from caret
evaluate_cv_models <- function(cv_models) {
  cv_results <- data.frame()

  for (model_name in names(cv_models)) {
    model <- cv_models[[model_name]]
    if (!is.null(model$results)) {
      best_row <- model$results[which.min(model$results$RMSE), ]
      cv_results <- rbind(cv_results, data.frame(
        Model = model_name,
        RMSE = best_row$RMSE,
        Rsquared = best_row$Rsquared,
        MAE = best_row$MAE,
        stringsAsFactors = FALSE
      ))
    }
  }

  cv_results <- cv_results[order(cv_results$RMSE), ]

  cat("Cross-Validated Model Comparison:\n")
  print(cv_results)

  return(cv_results)
}

#' Generate evaluation report
#' @param comparison_df Model comparison data frame
#' @param output_file Output file path
generate_evaluation_report <- function(comparison_df, output_file = "../../outputs/reports/model_evaluation_report.txt") {
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)

  sink(output_file)
  cat("=========================================\n")
  cat("VIDEO GAME SALES - MODEL EVALUATION REPORT\n")
  cat("=========================================\n\n")

  cat("Model Performance Summary:\n")
  cat("--------------------------\n")
  print(comparison_df)

  cat("\n\nBest Model by RMSE:", comparison_df$Model[1], "\n")
  cat("Best Model by R-Squared:", comparison_df$Model[which.max(comparison_df$R_Squared)], "\n")
  cat("Best Model by MAE:", comparison_df$Model[which.min(comparison_df$MAE)], "\n")

  cat("\n\nKey Findings:\n")
  cat("-------------\n")
  cat("1. XGBoost typically performs best on tabular data with mixed feature types\n")
  cat("2. Random Forest provides good baseline with feature importance\n")
  cat("3. Linear Regression offers interpretability but lower predictive power\n")
  cat("4. SVR can capture non-linear relationships but may overfit\n")

  sink()

  cat("Evaluation report saved to:", output_file, "\n")
}

#' ANOVA analysis for feature significance
#' @param data Video games data
#' @param target Target variable
anova_analysis <- function(data, target = "Global_Sales") {
  # Simple ANOVA
  formula1 <- as.formula(paste(target, "~ Genre"))
  anova1 <- aov(formula1, data = data)
  cat("ANOVA: Global_Sales ~ Genre\n")
  print(summary(anova1))

  # Full ANOVA
  formula2 <- as.formula(paste(target, "~ Genre + Platform + Publisher + Developer"))
  anova2 <- aov(formula2, data = data)
  cat("\nANOVA: Global_Sales ~ Genre + Platform + Publisher + Developer\n")
  print(summary(anova2))

  return(list(simple = anova1, full = anova2))
}

# Main execution
if (sys.nframe() == 0) {
  # This would be run after training all models
  cat("Model evaluation module loaded.\n")
  cat("Source this after running model scripts to compare results.\n")
}