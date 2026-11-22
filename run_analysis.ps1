<#
.SYNOPSIS
    Run Video Game Sales Analysis Pipeline
.DESCRIPTION
    This script runs the complete analysis pipeline for the Video Game Sales project.
    It supports both R and Python implementations.
.NOTES
    Author: Adeel Shah
    Project: CIND 820 Big Data Analytics Project
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('R', 'Python', 'Both')]
    [string]$Language = 'Both',

    [Parameter(Mandatory=$false)]
    [switch]$SetupOnly,

    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

function Write-Status {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Check-Data {
    $dataPath = Join-Path $ScriptDir "data\Video_Games.csv"
    if (-not (Test-Path $dataPath)) {
        Write-ErrorMsg "Data file not found: $dataPath"
        Write-Host "Please download the dataset from Kaggle and place it in the data/ directory"
        Write-Host "Dataset: Video Game Sales Dataset Updated - Extra Feat by Ibrahim Muhammad Naeem"
        exit 1
    }
    Write-Host "Data file found: $dataPath"
}

function Find-Rscript {
    @(
        "Rscript",
        "C:\Program Files\R\R-4.6.2\bin\Rscript.exe",
        "C:\Program Files\R\R-4.6.1\bin\Rscript.exe",
        "C:\Program Files\R\R-4.6.0\bin\Rscript.exe",
        "C:\Program Files\R\R-4.5.1\bin\Rscript.exe",
        "C:\Program Files\R\R-4.5.0\bin\Rscript.exe"
    ) | Where-Object { (Get-Command $_ -ErrorAction SilentlyContinue) -or (Test-Path $_) } | Select-Object -First 1
}

function Install-RPackages {
    param([string]$RscriptPath)

    @'
packages <- c('dplyr', 'tidyr', 'ggplot2', 'caret', 'randomForest', 'e1071',
              'xgboost', 'DiagrammeR', 'reshape2', 'rpart', 'rpart.plot')
lib <- path.expand(Sys.getenv('R_LIBS_USER'))
if (!nzchar(lib)) stop('R_LIBS_USER is empty')
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(lib)) stop('Cannot create R user library: ', lib)
.libPaths(c(lib, .libPaths()))
missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing)) install.packages(missing, lib = lib, repos = 'https://cloud.r-project.org/')
unavailable <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(unavailable)) stop('Missing or unloadable R packages: ', paste(unavailable, collapse = ', '))
'@ | & $RscriptPath -
    if ($LASTEXITCODE -ne 0) {
        throw "R package setup failed (exit code $LASTEXITCODE)."
    }
}

function Setup-Environment {
    Write-Status "Setting up environment..."
    $RscriptPath = Find-Rscript

    if ($Language -eq 'R') {
        if (-not $RscriptPath) {
            throw "Rscript not found. Add R to PATH or install R."
        }
        Install-RPackages $RscriptPath
        return
    }

    # Check for conda (recommended - includes both Python and R)
    if (Get-Command conda -ErrorAction SilentlyContinue) {
        Write-Host "Conda found. Creating environment (includes Python + R)..."
        conda env create -f environment.yml
        Write-Host "Activate with: conda activate videogames-sales-analysis"
        Write-Host "Then run: .\run_analysis.ps1"
    } elseif ($RscriptPath) {
        Write-Host "R found at: $RscriptPath"
        Write-Host "Installing Python packages via pip..."
        pip install -r requirements.txt

        Write-Host "Installing R packages..."
        Install-RPackages $RscriptPath
    } else {
        Write-Host "Conda not found and R not in common locations. You have two options:"
        Write-Host ""
        Write-Host "Option 1 (Recommended): Install Miniconda from https://docs.conda.io/en/latest/miniconda.html"
        Write-Host "Then run: conda env create -f environment.yml"
        Write-Host ""
        Write-Host "Option 2: Manual setup"
        Write-Host "  - Install Python 3.9+ from https://python.org"
        Write-Host "  - Install R from https://cran.r-project.org/"
        Write-Host "  - Run: pip install -r requirements.txt"
        Write-Host "  - Run: R -e \"install.packages(c('dplyr','tidyr','ggplot2','caret','randomForest','e1071','xgboost','DiagrammeR','rpart','rpart.plot'), repos='https://cloud.r-project.org/')\""
    }
}

function Run-R-Analysis {
    Write-Status "Running R Analysis Pipeline..."

    $RscriptPath = Find-Rscript

    if (-not $RscriptPath) {
        Write-ErrorMsg "Rscript not found. Checked common locations."
        Write-Host "Please add R to PATH or install R from https://cran.r-project.org/"
        Write-Host "Or run Python-only: .\run_analysis.ps1 -Language Python"
        exit 1
    }

    Write-Host "Using Rscript: $RscriptPath"

    $stages = @(
        'src\data\data_preprocessing.R'
        'src\eda\eda.R'
        'src\models\linear_regression.R'
        'src\models\random_forest.R'
        'src\models\svr.R'
        'src\models\xgboost.R'
        'src\evaluation\model_comparison.R'
    )
    foreach ($stage in $stages) {
        Write-Host "Running $stage..."
        Push-Location (Split-Path $stage)
        try {
            & $RscriptPath (Split-Path $stage -Leaf)
            if ($LASTEXITCODE -ne 0) {
                throw "$stage failed (exit code $LASTEXITCODE)."
            }
        }
        finally {
            Pop-Location
        }
    }
}

function Run-Python-Analysis {
    Write-Status "Running Python Analysis Pipeline..."

    # Check for jupyter
    if (-not (Get-Command jupyter -ErrorAction SilentlyContinue)) {
        Write-ErrorMsg "Jupyter not found. Please install with: pip install jupyter"
        exit 1
    }

    # Data profiling
    Write-Host "Generating data profile report..."
    jupyter nbconvert --to notebook --execute notebooks\01_data_profiling.ipynb --output notebooks\01_data_profiling_executed.ipynb

    # EDA
    Write-Host "Running Exploratory Data Analysis..."
    jupyter nbconvert --to notebook --execute notebooks\02_exploratory_analysis.ipynb --output notebooks\02_exploratory_analysis_executed.ipynb

    # Modeling
    Write-Host "Training models..."
    jupyter nbconvert --to notebook --execute notebooks\03_modeling.ipynb --output notebooks\03_modeling_executed.ipynb
}

function Clean-Outputs {
    Write-Status "Cleaning outputs..."
    Remove-Item -Path "outputs\figures\*" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "outputs\models\*" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "outputs\reports\*" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "notebooks\*_executed.ipynb" -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "." -Recurse -Name "__pycache__" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "." -Recurse -Name "*.RData" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "." -Recurse -Name "*.Rhistory" | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete."
}

# Main execution
try {
    if ($Clean) {
        Clean-Outputs
        exit 0
    }

    if ($SetupOnly) {
        Setup-Environment
        exit 0
    }

    Check-Data

    if ($Language -eq 'R' -or $Language -eq 'Both') {
        Run-R-Analysis
    }

    if ($Language -eq 'Python' -or $Language -eq 'Both') {
        Run-Python-Analysis
    }

    Write-Status "Analysis pipeline completed successfully!"
    Write-Host "Check outputs/figures/ for visualizations"
    Write-Host "Check outputs/reports/ for reports"
    Write-Host "Check outputs/models/ for trained models"
}
catch {
    Write-ErrorMsg "Pipeline failed: $_"
    exit 1
}
