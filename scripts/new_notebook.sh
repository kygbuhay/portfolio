#!/usr/bin/env bash
# === Professional Notebook Creator with Template ===
# Auto-generates notebooks with standardized headers and useful starter cells
# Compatible with portfolio src/ utilities

PORTFOLIO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Sanity checks
if [ ! -d "$PORTFOLIO_ROOT" ]; then
  echo "❌ Portfolio root not found: $PORTFOLIO_ROOT"; exit 1
fi
if [ ! -f "$PORTFOLIO_ROOT/.venv/bin/activate" ]; then
  echo "❌ .venv not found at $PORTFOLIO_ROOT/.venv"; exit 1
fi

# === Enhanced user inputs ===
echo "📂 Enter destination directory (relative to portfolio root):"
read -r DEST_DIR
DEST_DIR="${DEST_DIR:-reports}"

echo "📄 Enter notebook base name (leave blank for timestamp):"
read -r NB_BASENAME
if [ -z "$NB_BASENAME" ]; then
  NB_BASENAME="notebook_$(date +%Y-%m-%d_%H-%M-%S)"
fi

echo "🏷️ Enter project title (e.g., 'Sales Analysis — Q3 Performance Review'):"
read -r PROJECT_TITLE
PROJECT_TITLE="${PROJECT_TITLE:-New Analysis Project}"

echo "📝 Enter one-line business value description:"
read -r BUSINESS_VALUE
BUSINESS_VALUE="${BUSINESS_VALUE:-Analytical insights to drive data-driven decision making}"

echo "🎯 Enter stage number and name (e.g., '01 — Data Exploration'):"
read -r STAGE
STAGE="${STAGE:-01 — Analysis}"

echo "⏱️ Estimated runtime in minutes (e.g., '~15 minutes'):"
read -r RUNTIME
RUNTIME="${RUNTIME:-~15 minutes}"

# Ask if this is a case study (to determine whether to use bootstrap.py)
echo "📊 Is this a case study notebook? (y/N):"
read -r IS_CASE_STUDY
IS_CASE_STUDY="${IS_CASE_STUDY:-n}"

NB_NAME="$NB_BASENAME.ipynb"

# Resolve destination to absolute path
case "$DEST_DIR" in
  /*) TARGET_DIR="$DEST_DIR" ;;
  *)  TARGET_DIR="$PORTFOLIO_ROOT/$DEST_DIR" ;;
esac

# Activate venv
# shellcheck source=/dev/null
source "$PORTFOLIO_ROOT/.venv/bin/activate" || { echo "❌ Failed to activate venv"; exit 1; }

# Ensure destination exists
mkdir -p "$TARGET_DIR" || { echo "❌ Cannot create $TARGET_DIR"; exit 1; }

NB_PATH="$TARGET_DIR/$NB_NAME"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Create professional notebook with template
python - "$NB_PATH" "$PROJECT_TITLE" "$BUSINESS_VALUE" "$STAGE" "$RUNTIME" "$CURRENT_DATE" "$IS_CASE_STUDY" <<'PY'
import json, os, sys

path = sys.argv[1]
project_title = sys.argv[2]
business_value = sys.argv[3]
stage = sys.argv[4]
runtime = sys.argv[5]
current_date = sys.argv[6]
is_case_study = sys.argv[7].lower() in ('y', 'yes', '1', 'true')

# Professional header template
header_content = f"""# {project_title}

***{business_value}***

**Author:** Katherine Ygbuhay
**Updated:** {current_date}
**Stage:** {stage}
**Runtime:** {runtime}

## Objective

[Describe the specific analytical goal and business question this notebook addresses]

## Scope & Approach

- **Data source analysis** and quality assessment
- **Methodology overview** with key analytical steps
- **Statistical/modeling approach** if applicable
- **Visualization strategy** for insights communication

## Key Outputs

- [Specific deliverable 1]
- [Specific deliverable 2]
- [Recommendations or insights summary]

## Prerequisites

- [Required datasets or previous analysis stages]
- [Domain knowledge or technical understanding needed]

---"""

# Choose appropriate imports based on notebook type
if is_case_study:
    # Use bootstrap.py for case study notebooks
    imports_content = '''import os
os.environ["PORTFOLIO_PROJECT"] = "your_project_name_here"  # TODO: Update project name

import pandas as pd, numpy as np, matplotlib.pyplot as plt, seaborn as sns
from src.bootstrap import setup_notebook
from src.viz_helpers import apply_plot_rc_defaults, pretty_label

# Set up project paths and load data
RAW_NAME = "your_raw_data.csv"  # TODO: Update filename
PROC_NAME = "your_processed_data.csv"  # TODO: Update filename

P, df = setup_notebook(raw_filename=RAW_NAME, proc_filename=PROC_NAME, load="proc")
apply_plot_rc_defaults()

print(f"✅ Loaded data: {df.shape}")'''

    data_loading_content = '''# Data is already loaded via bootstrap.py
print(f"Dataset shape: {df.shape}")
print(f"Columns: {list(df.columns)}")
display(df.head())
df.info()'''
else:
    # Standard imports for general analysis
    imports_content = '''# Core data analysis libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Configuration for better outputs
pd.set_option('display.max_columns', None)
pd.set_option('display.precision', 3)

# Plotting configuration (accessible, professional)
plt.style.use('default')
sns.set_palette('colorblind')
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['font.size'] = 11

print("✅ Environment configured")'''

    data_loading_content = '''# Data loading and initial inspection
# TODO: Update file path and loading method as needed

# df = pd.read_csv('path/to/your/data.csv')
# df = pd.read_excel('path/to/your/data.xlsx')
# df = pd.read_parquet('path/to/your/data.parquet')

# Initial data inspection
# print(f"Dataset shape: {df.shape}")
# print(f"Columns: {list(df.columns)}")
# display(df.head())
# df.info()

print("📊 Ready for data loading")'''

# Analysis section header
analysis_header = """## Analysis & Insights

[This section will contain your main analytical work]"""

# Create notebook structure
nb = {
    "cells": [
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [header_content]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": ["## 1. Environment Setup"]
        },
        {
            "cell_type": "code",
            "metadata": {},
            "source": [imports_content],
            "outputs": [],
            "execution_count": None
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": ["## 2. Data Loading & Initial Inspection"]
        },
        {
            "cell_type": "code",
            "metadata": {},
            "source": [data_loading_content],
            "outputs": [],
            "execution_count": None
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [analysis_header]
        },
        {
            "cell_type": "code",
            "metadata": {},
            "source": ["# Your analysis code here\n"],
            "outputs": [],
            "execution_count": None
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": ["## Summary & Next Steps\n\n**Key Findings:**\n- [Finding 1]\n- [Finding 2]\n\n**Recommendations:**\n- [Recommendation 1]\n- [Recommendation 2]\n\n**Next Steps:**\n- [Next step 1]\n- [Next step 2]"]
        }
    ],
    "metadata": {
        "kernelspec": {
            "display_name": "Python 3",
            "language": "python",
            "name": "python3"
        },
        "language_info": {
            "name": "python",
            "version": "3.11.0"
        }
    },
    "nbformat": 4,
    "nbformat_minor": 5
}

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(nb, f, indent=2)

print(f"✨ Created professional notebook: {path}")
if is_case_study:
    print("📊 Case study template with bootstrap.py integration")
else:
    print("📈 Standard analysis template")
PY

echo ""
echo "🎉 Professional notebook created with:"
echo "   📋 Standardized header template"
if [[ "$IS_CASE_STUDY" =~ ^[yY] ]]; then
    echo "   🔧 Case study setup with bootstrap.py integration"
    echo "   🎨 Visualization helpers and accessibility defaults"
    echo "   📂 Project path management"
else
    echo "   🔧 Standard analysis imports and configuration"
    echo "   📊 Data loading templates for common formats"
fi
echo "   🏗️ Structured analysis sections"
echo "   📝 Summary and next steps framework"
echo ""
echo "🚀 Launching Jupyter Lab..."

# Launch Jupyter Lab at the new notebook
exec jupyter lab "$NB_PATH"