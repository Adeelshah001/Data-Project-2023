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
| **Dataset** | 16,000+ games, 16 features |
| **Target Variables** | NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales |
| **Key Features** | Genre, Platform, Publisher, Developer, Year, Critic/User Scores |
| **Methods** | EDA, Correlation Analysis, ANOVA, Predictive Modeling |
| **Models** | Linear Regression, Random Forest, SVR, XGBoost |
| **Best Model** | **XGBoost** (original test R² ≈ 0.34) |

---

## 🎯 Key Findings

### 📈 Sales Patterns
- **Peak sales year**: 2008 (late 2000s dominance)
- **Top publisher**: Nintendo (2.5× Activision's sales)
- **Dominant genre**: Action (globally), but **Role-Playing dominates in Japan**
- **Multi-platform games** generate ~30% more sales than exclusives

### 🤖 Model Performance in the Original Analysis

| Model | Test RMSE | Test R² | Test MAE | CV R² |
|-------|-----------|---------|----------|-------|
| **XGBoost** | **2.68** | **0.34** | **1.72** | **0.34** |
| Random Forest | 2.73 | 0.24 | 1.49 | 0.37 |
| Linear Regression | 2.37 | 0.11 | 1.09 | 0.22 |
| SVR | 1.10 | 0.13 | 1.62 | 0.08 |

> **Note**: Metrics vary by train/test split. XGBoost had the highest test R² in the original analysis.

---

## 🚀 Quick Start

The Windows R workflow uses PowerShell and R. Download `Video_Games.csv` from [Kaggle](https://www.kaggle.com/datasets/ibrahimmuhammadnaeem/video-games-sales-dataset-updated-extra-feat) and place it at `data/Video_Games.csv` inside the clone.

```powershell
git clone https://github.com/Adeelshah001/Data-Project.git
Set-Location Data-Project

# After placing the CSV, install R packages once in your personal R library.
.\run_analysis.ps1 -Language R -SetupOnly

# Run preprocessing, exploratory analysis, and the four model scripts.
.\run_analysis.ps1 -Language R
```

The launcher stops at the first failed R stage and identifies the script. The evaluation stage loads the comparison functions. The original analysis and results are available in [old/](old/).

## 📁 Project Structure

```
Data-Project/
├── 📂 data/                    # Raw data (not tracked)
│   └── Video_Games.csv         # Place dataset here
├── 📂 docs/                    # Documentation
│   └── data_description.txt
├── 📂 old/                     # Original project files
├── 📂 notebooks/               # Jupyter Notebooks (Python)
│   ├── 01_data_profiling.ipynb       # Pandas profiling report
│   ├── 02_exploratory_analysis.ipynb # EDA visualizations
│   └── 03_modeling.ipynb             # All 4 models + comparison
├── 📂 outputs/                 # Generated outputs (not tracked)
│   ├── 📂 figures/             # Visualizations (PNG)
│   ├── 📂 models/              # Trained models
│   └── 📂 reports/             # Analysis reports
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

The Python notebooks define the following visualizations for `outputs/figures/`:

| Figure | Description |
|--------|-------------|
| `sales_distributions.png` | Regional sales histograms |
| `top_platforms.png` | Top 10 platforms by game count |
| `top_publishers.png` | Top 10 publishers by global sales |
| `sales_by_year.png` | Global sales trend (1996-2016) |
| `sales_by_scores.png` | Sales by critic & user scores |
| `genre_distribution.png` | Genre frequency pie chart |
| `genre_regional_sales.png` | Regional sales by genre (faceted) |
| `multiplatform_sales.png` | Multi-platform vs single-platform |
| `sales_correlation.png` | Regional sales correlation heatmap |
| `genre_sales_by_year.png` | Stacked genre sales over time |
| `rf_feature_importance.png` | Random Forest top features |
| `xgb_feature_importance.png` | XGBoost top features |
| `model_comparison.png` | Model performance comparison |
| `predicted_vs_actual.png` | Predicted vs actual scatter plots |
| `residual_plots.png` | Residual analysis for all models |

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
- **Multi-platform indicator**: Games released on >1 platform
- **One-hot encoding**: Genre, Platform, Publisher, Developer
- **Score conversion**: User_Score & Critic_Score to numeric

### Models
1. **Linear Regression** — Baseline, interpretable
2. **Random Forest** — Non-linear, feature importance
3. **SVR (RBF Kernel)** — Non-linear regression
4. **XGBoost** — Gradient boosting, best performance

---

## 📚 References

- **Dataset**: Ibrahim Muhammad Naeem. (2023). *Video Game Sales Dataset Updated -Extra Feat* [Data set]. Kaggle. https://doi.org/10.34740/KAGGLE/DSV/4984906
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