# Contributing to Video Game Sales Analysis

Thank you for your interest in contributing to this project! This document provides guidelines for contributing.

## Project Overview

This project analyzes video game sales data to identify key factors influencing sales performance and build predictive models. It was developed as part of the CIND 820 Big Data Analytics Project.

## How to Contribute

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/Data-Project.git
cd Data-Project
```

### 2. Set Up Development Environment

#### Option A: Conda (Recommended)
```bash
conda env create -f environment.yml
conda activate videogames-sales-analysis
```

#### Option B: Python + R separately
```bash
# Python
pip install -r requirements.txt

# R (install packages from DESCRIPTION)
R -e "install.packages(c('readxl', 'dplyr', 'tidyr', 'ggplot2', 'caret', 'randomForest', 'e1071', 'xgboost', 'DiagrammeR', 'rpart', 'rpart.plot'))"
```

### 3. Make Changes

- Create a new branch for your feature/fix:
  ```bash
  git checkout -b feature/your-feature-name
  ```

- Follow the existing code style:
  - R: Use tidyverse style, 2-space indentation
  - Python: Follow PEP 8, use Black formatter

- Add tests for new functionality
- Update documentation as needed

### 4. Code Style Guidelines

#### R Scripts
- Use `<-` for assignment
- Use snake_case for variables and functions
- Document functions with roxygen2-style comments
- Keep line length under 80 characters

#### Python Notebooks
- Use descriptive markdown cells
- Keep code cells focused on single tasks
- Add comments explaining complex logic
- Output visualizations with descriptive titles

### 5. Commit Guidelines

Use conventional commit messages:
```
type(scope): short description

Longer description if needed

Fixes #issue-number
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
```
feat(models): add gradient boosting model
fix(data): handle missing values in critic scores
docs(readme): update installation instructions
```

### 6. Pull Request Process

1. Ensure all tests pass
2. Update README if needed
3. Add entry to CHANGELOG.md (if exists)
4. Request review from maintainers
5. Address feedback
6. Merge after approval

### 7. Reporting Issues

When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, R/Python versions)
- Relevant error messages

## Project Structure

```
Data-Project/
├── data/                 # Raw data (not tracked)
├── docs/                 # Dataset documentation
├── notebooks/            # Jupyter notebooks (Python)
│   ├── 01_data_profiling.ipynb
│   ├── 02_exploratory_analysis.ipynb
│   └── 03_modeling.ipynb
├── outputs/              # Generated outputs (not tracked)
│   ├── figures/          # Visualizations
│   ├── models/           # Trained models
│   └── reports/          # Analysis reports
├── src/                  # Source code (R)
│   ├── data/             # Data preprocessing
│   ├── eda/              # Exploratory data analysis
│   ├── models/           # Model implementations
│   └── evaluation/       # Model evaluation
├── .gitignore
├── CONTRIBUTING.md
├── DESCRIPTION           # R package dependencies
├── environment.yml       # Conda environment
├── LICENSE
├── README.md
└── requirements.txt      # Python dependencies
```

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue on GitHub for any questions about contributing.