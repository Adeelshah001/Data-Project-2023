# Exploratory Data Analysis Script
# Video Game Sales Analysis Project
# Author: Adeel Shah
# Date: 2023

library(ggplot2)
library(dplyr)
library(tidyr)
library(DiagrammeR)

#' Generate profile report using pandas_profiling (Python)
#' This is a placeholder - actual profiling done in Python notebook
generate_profile_report <- function(data, output_file = "profile_report.html") {
  cat("Profile report generation is done in Python using pandas_profiling.\n")
  cat("See notebooks/01_data_profiling.ipynb\n")
}

#' Plot North American sales distribution
#' @param data Video games data frame
plot_na_sales <- function(data) {
  plot(data$NA_Sales,
       main = "North American Video Game Sales",
       xlab = "Observations",
       ylab = "NA Unit Sales (Millions)")
}

#' Plot top 10 platforms by game count
#' @param data Video games data frame
plot_top_platforms <- function(data) {
  platform_freq <- data.frame(table(data$Platform))
  platform_sorted <- platform_freq[order(platform_freq$Freq, decreasing = TRUE), ]

  barplot(head(platform_sorted$Freq, 10),
          names.arg = head(platform_sorted$Platform, 10),
          xlab = "Top 10 Platforms",
          ylab = "# of Games on Platform",
          main = "Top 10 Platforms by Game Count")
}

#' Plot top publishers by global sales
#' @param data Video games data frame
plot_top_publishers <- function(data, top_n = 10) {
  publisher_sales <- aggregate(Global_Sales ~ Publisher, data = data, FUN = sum)
  publisher_sales <- publisher_sales[order(publisher_sales$Global_Sales, decreasing = TRUE), ]
  top_publishers <- head(publisher_sales, top_n)

  barplot(top_publishers$Global_Sales,
          names.arg = top_publishers$Publisher,
          xlab = "Publisher",
          ylab = "Global Sales",
          main = paste("Top", top_n, "Publishers by Global Sales"),
          las = 2)
}

#' Plot sales by user score and critic score
#' @param data Video games data frame
plot_sales_by_scores <- function(data) {
  # User Score
  data$User_Score <- as.numeric(as.character(data$User_Score))
  subset_user <- data[!is.na(data$User_Score), ]
  sales_by_user <- aggregate(subset_user$Global_Sales,
                             by = list(user_score = subset_user$User_Score),
                             FUN = sum)
  sales_by_user <- sales_by_user[order(sales_by_user$user_score, decreasing = TRUE), ]

  # Critic Score
  data$Critic_Score <- as.numeric(as.character(data$Critic_Score))
  subset_critic <- data[!is.na(data$Critic_Score), ]
  sales_by_critic <- aggregate(subset_critic$Global_Sales,
                               by = list(critic_score = subset_critic$Critic_Score),
                               FUN = sum)
  sales_by_critic <- sales_by_critic[order(sales_by_critic$critic_score, decreasing = TRUE), ]

  # Side-by-side plots
  par(mfrow = c(1, 2))
  barplot(sales_by_critic$x, names.arg = sales_by_critic$critic_score,
          xlab = "Critic Score", ylab = "Sales", main = "Sales by Critic Score")
  barplot(sales_by_user$x, names.arg = sales_by_user$user_score,
          xlab = "User Score", ylab = "Sales", main = "Sales by User Score")

  par(mfrow = c(1, 1))
}

#' Plot sales by year of release
#' @param data Video games data frame
plot_sales_by_year <- function(data) {
  sales_by_year <- aggregate(Global_Sales ~ Year_of_Release, data = data, FUN = sum)

  # All years
  barplot(sales_by_year$Global_Sales, names.arg = sales_by_year$Year_of_Release,
          xlab = "Year", ylab = "Total Sales", main = "Total Sales per Year")

  # Filtered years (1996-2016)
  sales_by_year_filtered <- sales_by_year[sales_by_year$Year_of_Release >= 1996 &
                                           sales_by_year$Year_of_Release <= 2016, ]
  barplot(sales_by_year_filtered$Global_Sales, names.arg = sales_by_year_filtered$Year_of_Release,
          xlab = "Year", ylab = "Total Sales", main = "Total Sales per Year (1996-2016)")
}

#' Plot top developers and publishers by sales
#' @param data Video games data frame
plot_top_devs_publishers <- function(data, top_n = 10) {
  par(mfrow = c(2, 1))

  # Top Developers
  sales_per_dev <- aggregate(Global_Sales ~ Developer, data = data, sum)
  sales_per_dev <- sales_per_dev[order(sales_per_dev$Global_Sales, decreasing = TRUE), ]
  top_devs <- head(sales_per_dev[-1, ], top_n)  # Remove first (often "Unknown")

  bar_colors <- rainbow(length(top_devs$Developer))
  barplot(top_devs$Global_Sales, names.arg = top_devs$Developer,
          xlab = "Developer", ylab = "Global Sales", col = bar_colors,
          main = paste("Top", top_n, "Developers by Sales"))
  legend("topright", legend = top_devs$Developer, fill = bar_colors,
         bty = "n", horiz = FALSE, cex = 0.7)

  # Top Publishers
  sales_per_pub <- aggregate(Global_Sales ~ Publisher, data = data, sum)
  sales_per_pub <- sales_per_pub[order(sales_per_pub$Global_Sales, decreasing = TRUE), ]
  top_pubs <- head(sales_per_pub[-1, ], top_n)

  bar_colors <- rainbow(length(top_pubs$Publisher))
  barplot(top_pubs$Global_Sales, names.arg = top_pubs$Publisher,
          xlab = "Publisher", ylab = "Global Sales", col = bar_colors,
          main = paste("Top", top_n, "Publishers by Sales"))
  legend("topright", legend = top_pubs$Publisher, fill = bar_colors,
         bty = "n", horiz = FALSE, cex = 0.7)

  par(mfrow = c(1, 1))
}

#' Plot genre frequency pie chart
#' @param data Video games data frame
plot_genre_frequency <- function(data) {
  genre_frequency <- table(data$Genre)
  genre_proportions <- prop.table(genre_frequency) * 100
  labels <- paste(names(genre_proportions), "(", round(genre_proportions, 1), "%)", sep = "")
  pie(genre_proportions, labels = labels, main = "Genre Frequency")
}

#' Plot regional sales by genre using ggplot2
#' @param data Video games data frame
plot_region_sales_by_genre <- function(data) {
  sales_data_genre <- data[, c("Genre", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales")]
  sales_data_long <- tidyr::gather(sales_data_genre, Region, Sales, -Genre)

  p <- ggplot(sales_data_long, aes(x = Genre, y = Sales)) +
    geom_bar(stat = "identity") +
    facet_wrap(~ Region, scales = "free_y") +
    labs(x = "Genre", y = "Sales") +
    ggtitle("Region Sales by Genre") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  print(p)
  return(p)
}

#' Plot multi-platform vs single-platform sales
#' @param data Video games data frame with Multiple_Platforms column
plot_multiplatform_sales <- function(data) {
  multiplat <- subset(data, Multiple_Platforms == "yes")
  not_multiplat <- subset(data, Multiple_Platforms == "no")

  multiplat_sales <- sum(multiplat$Global_Sales)
  not_multiplat_sales <- sum(not_multiplat$Global_Sales)

  sales <- c(multiplat_sales, not_multiplat_sales)
  categories <- c("Multi-platform", "Not Multi-platform")

  barplot(sales, names.arg = categories,
          xlab = "Category", ylab = "Global Sales",
          main = "Multi-platform Sales", col = c("red", "blue"))
}

#' Plot genre sales by year (stacked bar)
#' @param data Video games data frame
plot_genre_sales_by_year <- function(data) {
  genre_sales_by_year <- aggregate(Global_Sales ~ Year_of_Release + Genre, data = data, FUN = sum)

  p <- ggplot(genre_sales_by_year, aes(x = Year_of_Release, y = Global_Sales, fill = Genre)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "Year", y = "Global Sales", fill = "Genre") +
    ggtitle("Genre Sales by Year") +
    theme_minimal()

  print(p)
  return(p)
}

#' Plot correlation heatmap for regional sales
#' @param data Video games data frame
plot_sales_correlation <- function(data) {
  sales_data <- data[, c("NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales")]
  cor_matrix <- cor(sales_data, use = "complete.obs")

  heatmap(cor_matrix,
          col = colorRampPalette(c("#FF0000", "white", "#0000FF"))(100),
          main = "Correlation Matrix: Regional Sales",
          xlab = "Sales Columns",
          ylab = "Sales Columns",
          cex.main = 1.2,
          cex.axis = 1.2)
}

#' Create methodology flowchart
create_methodology_flowchart <- function() {
  code <- "
  digraph flowchart {
    node [shape = box] Start Data_Collection Data_Preprocessing Exploratory_Data_Analysis
    node [shape = box] Correlation_Analysis Predictive_Modeling Evaluation End

    Start -> Data_Collection
    Data_Collection -> Data_Preprocessing
    Data_Preprocessing -> Exploratory_Data_Analysis
    Exploratory_Data_Analysis -> Correlation_Analysis
    Correlation_Analysis -> Predictive_Modeling
    Predictive_Modeling -> Evaluation
    Evaluation -> End
  }"

  graph <- grViz(code)
  return(graph)
}

#' Run all EDA plots and save to outputs/figures
#' @param data Video games data frame
run_full_eda <- function(data, output_dir = "../../outputs/figures") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  cat("Running EDA plots...\n")

  # Note: In R, plots are displayed interactively
  # For saving, wrap each plot function with png()/dev.off()

  plot_na_sales(data)
  plot_top_platforms(data)
  plot_top_publishers(data)
  plot_sales_by_scores(data)
  plot_sales_by_year(data)
  plot_top_devs_publishers(data)
  plot_genre_frequency(data)
  plot_region_sales_by_genre(data)
  plot_multiplatform_sales(data)
  plot_genre_sales_by_year(data)
  plot_sales_correlation(data)

  cat("EDA complete. Plots displayed interactively.\n")
  cat("To save plots, wrap plot calls with png('filename.png') and dev.off()\n")
}

# Main execution
if (sys.nframe() == 0) {
  source("../data/data_preprocessing.R")
  vg <- load_and_preprocess()
  vg <- create_multiplatform_var(vg)
  run_full_eda(vg)
}