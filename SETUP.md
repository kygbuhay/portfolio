# Portfolio Setup Guide

This guide helps you set up the portfolio for local development and explains how the utilities work.

## Quick Start

```bash
# 1. Clone and navigate to portfolio
git clone https://github.com/yourusername/portfolio.git
cd portfolio

# 2. Set up Python environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 3. Install portfolio utilities
make install
# OR: pip install -e .

# 4. Start working!
jupyter lab
```

## Using the Makefile (Recommended)

The Makefile provides cross-platform commands that work on Linux, macOS, and Windows (with make installed):

```bash
make help                 # Show all available commands
make install              # Install dependencies
make new-notebook         # Create a new notebook
make export-notebooks     # Export notebooks to markdown
make export-figures       # Export figures to PNG
make clean                # Clean up cache files
```

## Project Path Resolution

The `src/paths.py` module automatically finds your project root using multiple strategies:

1. **Environment variable** (highest priority):
   ```bash
   export PORTFOLIO_PROJECT=employee_attrition_analysis
   ```

2. **Explicit project parameter** in notebooks:
   ```python
   P, df = setup_notebook(project="employee_attrition_analysis")
   ```

3. **Auto-detection** from current working directory (walks up to find `notebooks/` and `docs/`)

This flexibility allows the code to work from anywhere without hardcoded paths!

## Creating a New Case Study

```bash
# 1. Create the directory structure
mkdir -p coursework/your-program/new_case_study/{notebooks,data/{raw,processed},docs/{notes,modeling,stakeholders},reports/{figures,notebooks_md}}

# 2. Set project environment variable (optional but recommended)
export PORTFOLIO_PROJECT=new_case_study

# 3. Create your first notebook
make new-notebook
# Choose: notebooks/ as destination
# Name it: 01_initial_analysis

# 4. In your notebook, start with:
from src.bootstrap import setup_notebook

P, df = setup_notebook(
    raw_filename="your_data.csv",
    proc_filename="your_data_cleaned.csv",
    load="raw",
    project="new_case_study"
)
```

## Shell Aliases (Optional)

For convenience, add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Portfolio shortcuts (adjust path as needed)
export PORTFOLIO_ROOT=~/Documents/portfolio
alias newnb='$PORTFOLIO_ROOT/scripts/new_notebook.sh'
alias exportnb='$PORTFOLIO_ROOT/scripts/export_notebooks_menu.sh'
alias exportfigs='$PORTFOLIO_ROOT/scripts/export_figures_menu.sh'
```

Then reload: `source ~/.bashrc`

## Troubleshooting

### "Module not found" errors
```bash
# Make sure you've installed the package
pip install -e .

# Verify installation
pip list | grep portfolio-src
```

### Path resolution issues
```bash
# Set explicit project
export PORTFOLIO_PROJECT=your_case_study_name

# Or in Python:
P = get_paths_from_notebook(project_name="your_case_study_name")
```

### Scripts not executable
```bash
chmod +x scripts/*.sh
```

## Windows Users

### Using WSL (Recommended)
Install Windows Subsystem for Linux and follow the Linux instructions above.

### Using PowerShell
You can create similar aliases in PowerShell:

```powershell
# In your PowerShell profile ($PROFILE):
function newnb { & "$env:USERPROFILE\Documents\portfolio\scripts\new_notebook.sh" }
function exportnb { & "$env:USERPROFILE\Documents\portfolio\scripts\export_notebooks_menu.sh" }
```

### Using Git Bash
Git Bash supports bash scripts natively - follow the Linux instructions.

## Accessibility Features

All visualizations use:
- Colorblind-friendly palettes (seaborn's "colorblind" palette)
- WCAG contrast checking
- Multiple visual cues (color + line style + markers)
- Hatching patterns for bar charts

Enable with one line:
```python
from src.viz_access import quick_accessibility_setup
quick_accessibility_setup()
```

## Exporting Work

### Export notebooks to markdown
```bash
make export-notebooks
# Follow the interactive menu
```

### Export figures
```bash
make export-figures
# Figures are saved to reports/figures/ with intelligent naming
```

### View exported content
- Markdown notebooks: `reports/notebooks_md/*.md`
- Figures: `reports/figures/notebook_name/*.png`

Both are version controlled and viewable on GitHub!
