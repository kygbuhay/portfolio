# Portfolio Scripts

Automation scripts for managing your data science portfolio, including figure extraction and notebook conversion utilities.

## 🚀 Quick Start

### Jupyter Notebook Manager (NEW! 🎉)
```bash
# Add to PATH first (one-time setup)
export PATH="$HOME/Documents/portfolio/scripts:$PATH"

# Interactive menu - opens notebooks in tabs
jn

# Open single notebook (auto-closes terminal when browser closes)
jn 01                    # Opens 01_data_dictionary_setup.ipynb
jn baseline              # Pattern matching works

# Open multiple in tabs
jn 01 03 05             # All in one terminal window
```

### Figure Export (Fixed! 🎉)
```bash
# Interactive menu for exporting figures from notebooks
./scripts/export_figures_menu.sh

# Direct export (single notebook)
python3 scripts/export_figures.py "path/to/notebook.ipynb" --project project_name
```

### Notebook to Markdown Export
```bash
# Interactive menu for converting notebooks to markdown
./scripts/export_notebooks_menu.sh

# Direct export (single notebook)
python3 scripts/export_notebooks.py "path/to/notebook.ipynb" --project project_name
```

### Create New Notebooks
```bash
# Generate a new notebook from template
./scripts/new_notebook.sh
```

## 📁 Output Structure

Your exports are organized in a consistent structure:

```
case_study_project/
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_modeling.ipynb
├── reports/
│   ├── figures/
│   │   ├── 01_data_exploration/
│   │   │   ├── correlation_heatmap_features.png       # 🎯 Descriptive names!
│   │   │   └── distribution_plots_target_variable.png
│   │   └── 02_feature_engineering/
│   │       └── feature_importance_scores.png
│   └── notebooks_md/                                  # 🆕 New markdown exports
│       ├── 01_data_exploration/
│       │   ├── 01_data_exploration.md
│       │   └── images/                                # Auto-extracted images
│       └── 02_feature_engineering/
│           └── 02_feature_engineering.md
└── docs/
    └── modeling/
        └── model_results.md
```

## 🛠️ Scripts Overview

### `export_figures.py` & `export_figures_menu.sh`
**Export matplotlib/seaborn figures from Jupyter notebooks with descriptive filenames**

#### Recent Fix (October 2025) ✅
- **Before:** Generic names like `5_metrics_visualizations.png`
- **After:** Descriptive names like `roc_curves_tree_based_models.png`

#### Features:
- **Smart naming:** Extracts plot titles from code (e.g., `plt.title("ROC Curves")`)
- **Fallback hierarchy:** Plot title → Cleaned section heading → Generic name
- **Section cleaning:** Removes numbers from headings ("5. Metrics" → "Metrics")
- **Safe overwrites:** Prompts before replacing existing files
- **Batch processing:** Select multiple notebooks from interactive menu

#### Usage:
```bash
# Interactive mode (recommended)
./scripts/export_figures_menu.sh

# Direct mode
python3 scripts/export_figures.py "notebooks/05_tree_models.ipynb" --project employee_attrition_analysis

# Force overwrite existing figures
python3 scripts/export_figures.py "notebooks/analysis.ipynb" --project myproject --force
```

### `export_notebooks.py` & `export_notebooks_menu.sh` 🆕
**Convert Jupyter notebooks to clean Markdown format**

#### Features:
- **Professional formatting:** Clean headers, proper code blocks, metadata
- **Image handling:** Preserves inline images and links to exported figures
- **Safe exports:** Won't overwrite unless explicitly requested
- **Batch processing:** Interactive menu for multiple notebooks
- **Cross-references:** Links to related figure exports when available

#### Usage:
```bash
# Interactive mode (recommended)
./scripts/export_notebooks_menu.sh

# Direct mode
python3 scripts/export_notebooks.py "notebooks/analysis.ipynb" --project myproject

# Force overwrite existing markdown
python3 scripts/export_notebooks.py "notebooks/analysis.ipynb" --project myproject --force
```

### `new_notebook.sh`
**Generate new Jupyter notebooks from templates**

Creates properly structured notebooks with:
- Standard imports and setup
- Project path configuration
- Consistent naming conventions
- Predefined sections for data science workflows

## 🔧 Setup & Dependencies

### Required Python Packages
```bash
# Core dependencies (usually pre-installed in data science environments)
pip install nbformat nbconvert

# Your project dependencies
pip install -e .  # Installs your src/ package for path resolution
```

### Bash Aliases (Recommended)
Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Add scripts to PATH for 'jn' command
export PATH="$HOME/Documents/portfolio/scripts:$PATH"

# Navigate to portfolio and run scripts
alias exportfigs='cd ~/Documents/portfolio && ./scripts/export_figures_menu.sh'
alias exportfigures='cd ~/Documents/portfolio && ./scripts/export_figures_menu.sh'
alias exportnb='cd ~/Documents/portfolio && ./scripts/export_notebooks_menu.sh'
alias exportnotebooks='cd ~/Documents/portfolio && ./scripts/export_notebooks_menu.sh'
alias newnb='cd ~/Documents/portfolio && ./scripts/new_notebook.sh'
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## 📋 Project Structure Requirements

For scripts to work properly, your case study projects should follow this structure:

```
case_study_name/
├── notebooks/          # Required: Contains .ipynb files
│   ├── *.ipynb
├── data/
│   ├── raw/
│   └── processed/
├── src/                # Required: Contains paths.py for path resolution
│   ├── __init__.py
│   ├── paths.py        # Defines get_paths_from_notebook()
│   └── *.py
├── docs/
└── reports/            # Auto-created: Export destinations
    ├── figures/
    └── notebooks_md/
```

## 🎯 How the Figure Naming Fix Works

The enhanced figure export script uses a three-tier naming strategy:

### 1. **Plot Title Extraction** (Highest Priority)
Searches for actual plot titles in your code:
```python
plt.title("ROC Curves — Tree-Based Models")  # → roc_curves_tree_based_models.png
ax.set_title("Feature Importance Scores")    # → feature_importance_scores.png
```

### 2. **Cleaned Section Headers** (Fallback)
Removes section numbers and prefixes:
```markdown
## 5. Metrics & Visualizations  # → metrics_visualizations.png
## Step 3: Model Evaluation      # → model_evaluation.png
```

### 3. **Safe Fallback** (Last Resort)
Uses generic names with numbering: `figure.png`, `figure_2.png`, etc.

## 🔍 Troubleshooting

### Common Issues

**"No projects with notebooks/ found"**
- Ensure your case study folders contain a `notebooks/` subdirectory
- Run from the correct directory or specify the path

**"nbconvert not found"**
```bash
pip install nbconvert
```

**"Module 'src.paths' not found"**
```bash
cd portfolio_root
pip install -e .  # Install your project package
```

**Permission denied**
```bash
chmod +x scripts/*.sh  # Make scripts executable
```

### Figure Names Still Generic?
1. Check that your plots have explicit titles: `plt.title("Your Title Here")`
2. Use descriptive section headers without just numbers
3. Verify the script can find your plot code in the same cell as the figure output

## 🤝 Contributing

Feel free to enhance these scripts! Common improvements:
- Support for additional plot libraries (plotly, bokeh, etc.)
- Custom naming patterns
- Better image optimization
- Integration with other notebook tools

## 📝 Notes

- **Safe by default:** Scripts won't overwrite existing files unless `--force` is used
- **Project isolation:** Each case study maintains separate figure/markdown folders
- **Extensible:** Easy to add new export formats or naming conventions
- **Portable:** Works from any directory thanks to relative path resolution

---

**Last Updated:** October 2025
**Maintainer:** Your Portfolio Automation System