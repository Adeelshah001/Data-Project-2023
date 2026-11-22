# 🎮 Video Game Sales Analysis

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![R 4.0+](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![Conda](https://img.shields.io/badge/conda-env-green.svg)](environment.yml)

> **CIND 820 Big Data Analytics Project** — Exploring the Dynamics of Video Game Sales

This project analyzes video game sales data to identify key factors influencing sales performance and build predictive models for global sales. The analysis uses the **Video Game Sales Dataset Updated - Extra Feat** by Ibrahim Muhammad Naeem (Kaggle, 2023) containing 16,000+ games across multiple platforms, genres, and regions.

---

## 📊 Project Overview

| Aspect | Details |
|--------|---------|
| **Dataset** | 16,719 rows and 16 columns |
| **Prediction target** | Global sales. Regional sales are explored in the descriptive analysis. |
| **Key Features** | Genre, Platform, Publisher, Developer, Year, Critic/User Scores |
| **Methods** | EDA, Correlation Analysis, ANOVA, Predictive Modeling |
| **Models** | Linear Regression, Random Forest, SVR, XGBoost |
| **Final report result** | Tuned XGBoost reached a cross-validated R² of 0.338. |

---

## 🎯 Key Findings

### 📈 Sales Patterns
- **Peak sales year**: 2008 (late 2000s dominance)
- **Top publisher**: Nintendo (2.5× Activision's sales)
- **Dominant genre**: Action (globally), but **Role-Playing dominates in Japan**
- **Multi-platform games** generate ~30% more sales than exclusives

## Final report and slides

- [Final project report (Word)](Exploring%20the%20Dynamics%20of%20Video%20Game%20Sales%20Project%20Report.docx)
- [Final presentation (PowerPoint)](Final%20Project%20Presentation.pptx)

The report gives XGBoost an initial R² of 0.084. After hyperparameter tuning, cross-validation yielded R² 0.338, RMSE 2.887, and MAE 1.605. These are results from the original analysis.

## 🚀 Quick Start

The Windows R workflow uses PowerShell and R. Download `Video_Games.csv` from [the Kaggle dataset, version 1](https://www.kaggle.com/datasets/ibriiee/video-games-sales-dataset-2022-updated-extra-feat/versions/1) and place it at `data/Video_Games.csv` inside the clone.

```powershell
git clone https://github.com/Adeelshah001/Data-Project-2023.git
Set-Location Data-Project-2023

# After placing the CSV, install R packages once in your personal R library.
.\run_analysis.ps1 -Language R -SetupOnly

# Run preprocessing, exploratory analysis, and the four model scripts.
.\run_analysis.ps1 -Language R
```

The launcher stops at the first failed R stage and identifies the script. The evaluation stage loads the comparison functions. The original analysis and results are available in [old/](old/).

## 📁 Project Structure

```
Data-Project-2023/
├── 📂 data/                    # Raw data (not tracked)
│   └── Video_Games.csv         # Place dataset here
├── 📂 docs/                    # Documentation
│   └── data_description.txt
├── 📂 old/                     # Original project files
├── 📂 notebooks/               # Jupyter Notebooks (Python)
│   ├── 01_data_profiling.ipynb       # Pandas profiling report
│   ├── 02_exploratory_analysis.ipynb # EDA visualizations
│   └── 03_modeling.ipynb             # All 4 models + comparison
├── 📂 outputs/                 # Verification outputs
│   ├── 📄 README.md            # Output index
│   └── 📂 figures/             # PNG charts, R plots PDF, and run results
│       ├── 📂 logs/
│       ├── 📂 notebooks/
│       └── 📂 reports/
├── 📂 src/                     # Source Code (R)
│   ├── 📂 data/
│   │   └── data_preprocessing.R
│   ├── 📂 eda/
│   │   └── eda.R
│   ├── 📂 models/
│   │   ├── linear_regression.R
│   │   ├── random_forest.R
│   │   ├── svr.R
│   │   └── xgboost.R
│   └── 📂 evaluation/
│       └── model_comparison.R
├── 📄 .gitignore
├── 📄 CONTRIBUTING.md
├── 📄 DESCRIPTION              # R dependencies
├── 📄 environment.yml          # Conda environment
├── 📄 LICENSE
├── 📄 Makefile                 # Build automation
├── 📄 README.md
├── 📄 requirements.txt         # Python dependencies
└── 📄 run_analysis.ps1         # Windows PowerShell runner
```

---

## Python notebooks

The [notebooks](notebooks/) contain the Python profiling, exploratory analysis, and modeling workflows. The Windows quick start above covers the R workflow.

## 📊 Visualizations

Open a figure below or browse the [figures folder](outputs/figures/).

| Figure | Description |
|--------|-------------|
| [sales_distributions.png](outputs/figures/sales_distributions.png) | Regional sales histograms |
| [top_platforms.png](outputs/figures/top_platforms.png) | Top 10 platforms by game count |
| [top_publishers.png](outputs/figures/top_publishers.png) | Top 10 publishers by global sales |
| [sales_by_year.png](outputs/figures/sales_by_year.png) | Global sales by release year (1996–2016) |
| [sales_by_scores.png](outputs/figures/sales_by_scores.png) | Sales by critic & user scores |
| [genre_distribution.png](outputs/figures/genre_distribution.png) | Genre frequency pie chart |
| [genre_regional_sales.png](outputs/figures/genre_regional_sales.png) | Regional sales by genre |
| [multiplatform_sales.png](outputs/figures/multiplatform_sales.png) | Multi-platform vs single-platform |
| [sales_correlation.png](outputs/figures/sales_correlation.png) | Regional sales correlation heatmap |
| [genre_sales_by_year.png](outputs/figures/genre_sales_by_year.png) | Stacked genre sales over time |
| [rf_feature_importance.png](outputs/figures/rf_feature_importance.png) | Random Forest top features |
| [xgb_feature_importance.png](outputs/figures/xgb_feature_importance.png) | XGBoost top features |
| [model_comparison.png](outputs/figures/model_comparison.png) | Model performance comparison |
| [predicted_vs_actual.png](outputs/figures/predicted_vs_actual.png) | Predicted vs actual scatter plots |
| [residual_plots.png](outputs/figures/residual_plots.png) | Residual analysis for all models |
| [r_exploratory_plots.pdf](outputs/figures/r_exploratory_plots.pdf) | Exploratory plots from the R workflow |

---

## 🔬 Methodology

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────────────┐
│   Data      │────▶│  Preprocessing   │────▶│  Exploratory Data      │
│  Collection │     │  (cleaning,      │     │  Analysis (EDA)        │
└─────────────┘     │  encoding,       │     │  (visualizations,      │
                    │  multi-platform) │     │  correlations, ANOVA)  │
                    └──────────────────┘     └───────────┬────────────┘
                                                         │
                    ┌──────────────────┐                 ▼
                    │  Evaluation      │◀────┐    ┌────────────────────────┐
                    │  (CV, metrics,   │     │    │  Predictive Modeling   │
                    │  comparison)     │     │    │  (LR, RF, SVR, XGB)    │
                    └──────────────────┘     │    └────────────────────────┘
```

### Feature Engineering
- **Multi-platform indicator**: Repeated nonblank game titles in the dataset
- **One-hot encoding**: Genre, Platform, Publisher, Developer
- **Score conversion**: User_Score & Critic_Score to numeric

### Models
1. **Linear Regression** — Baseline, interpretable
2. **Random Forest** — Non-linear, feature importance
3. **SVR (RBF Kernel)** — Non-linear regression
4. **XGBoost** — Gradient boosting with hyperparameter tuning

---

## 📚 References

- **Dataset**: Ibrahim Muhammad Naeem. (2023). *Video Game Sales Dataset Updated -Extra Feat* [Data set]. [Kaggle, version 1](https://www.kaggle.com/datasets/ibriiee/video-games-sales-dataset-2022-updated-extra-feat/versions/1) · [Dataset DOI](https://doi.org/10.34740/KAGGLE/DSV/4984906)
- Cox, J. (2014). What Makes a Blockbuster Video Game? *Manage. Decis. Econ.*, 35: 189-198.
- Babb, J., Terry, N., & Dana, K. (2013). The Impact Of Platform On Global Video Game Sales. *IBER*, 12(10), 1273.
- Ruohonen, J., & Hyrynsalmi, S. (2017). Evaluating the use of internet search volumes for time series modeling of sales in the video game industry. *Electron Markets*, 27, 351–370.
- Binken, J. L. G., & Stremersch, S. (2009). The Effect of Superstar Software on Hardware Sales in System Markets. *Journal of Marketing*, 73(2), 88–104.
- Haviv, A., Huang, Y., & Li, N. (2020). Intertemporal Demand Spillover Effects on Video Game Platforms. *Management Science*, 66(10):4788-4807.

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Adeel Shah**

CIND 820 Big Data Analytics Project, Toronto Metropolitan University

GitHub: [@Adeelshah001](https://github.com/Adeelshah001)

---

## 🙏 Acknowledgments

- Ibrahim Muhammad Naeem for the excellent dataset on Kaggle
- Toronto Metropolitan University CIND 820 course instructors
- Open source communities for R and Python data science tools