# Makefile for Video Game Sales Analysis
# Run full analysis pipeline: make all

.PHONY: all clean setup data eda models evaluation report

# Default target
all: setup data eda models evaluation

# Setup environment
setup:
	@echo "Setting up environment..."
	conda env create -f environment.yml || true
	@echo "Activate environment with: conda activate videogames-sales-analysis"

# Install Python dependencies only
setup-py:
	pip install -r requirements.txt

# Install R dependencies only
setup-r:
	R -e "install.packages(c('dplyr', 'tidyr', 'ggplot2', 'caret', 'randomForest', 'e1071', 'xgboost', 'DiagrammeR', 'reshape2', 'rpart', 'rpart.plot'), repos='https://cloud.r-project.org/')"

# Download/prepare data (placeholder - user must provide Video_Games.csv)
data:
	@echo "Data preparation..."
	@echo "Please place Video_Games.csv in the data/ directory"
	@test -f data/Video_Games.csv || (echo "ERROR: data/Video_Games.csv not found!" && exit 1)

# Run EDA (R)
eda: data
	@echo "Running Exploratory Data Analysis (R)..."
	cd src/eda && Rscript eda.R

# Run EDA (Python notebook)
eda-py: data
	@echo "Running Exploratory Data Analysis (Python)..."
	jupyter nbconvert --to notebook --execute notebooks/02_exploratory_analysis.ipynb --output notebooks/02_exploratory_analysis_executed.ipynb

# Run all models (R)
models: data
	@echo "Training Linear Regression..."
	cd src/models && Rscript linear_regression.R
	@echo "Training Random Forest..."
	cd src/models && Rscript random_forest.R
	@echo "Training SVR..."
	cd src/models && Rscript svr.R
	@echo "Training XGBoost..."
	cd src/models && Rscript xgboost.R

# Run all models (Python notebook)
models-py: data
	@echo "Training models (Python)..."
	jupyter nbconvert --to notebook --execute notebooks/03_modeling.ipynb --output notebooks/03_modeling_executed.ipynb

# Run model evaluation
evaluation: models
	@echo "Running model evaluation..."
	cd src/evaluation && Rscript model_comparison.R

# Locate the published report
report:
	@test -f "Exploring the Dynamics of Video Game Sales Project Report.docx"
	@echo "Exploring the Dynamics of Video Game Sales Project Report.docx"

# Run Python profiling
profile: data
	@echo "Generating data profile report..."
	jupyter nbconvert --to notebook --execute notebooks/01_data_profiling.ipynb --output notebooks/01_data_profiling_executed.ipynb

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf outputs/figures/*
	rm -rf outputs/models/*
	rm -rf outputs/reports/*
	rm -rf notebooks/*_executed.ipynb
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	find . -name "*.RData" -delete
	find . -name "*.Rhistory" -delete

# Clean everything including environment
clean-all: clean
	conda env remove -n videogames-sales-analysis || true

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Run R analysis (default)"
	@echo "  setup       - Create conda environment"
	@echo "  setup-py    - Install Python dependencies only"
	@echo "  setup-r     - Install R dependencies only"
	@echo "  data        - Verify data file exists"
	@echo "  eda         - Run EDA (R)"
	@echo "  eda-py      - Run EDA (Python notebook)"
	@echo "  models      - Train all models (R)"
	@echo "  models-py   - Train all models (Python notebook)"
	@echo "  profile     - Generate data profile report"
	@echo "  evaluation  - Run model evaluation"
	@echo "  report      - Locate the published report"
	@echo "  clean       - Remove generated outputs"
	@echo "  clean-all   - Remove outputs and conda environment"
	@echo "  help        - Show this help"