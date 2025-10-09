# 📁 Portfolio Folder Structure Guide

This document explains the organization and purpose of each folder in your data science portfolio.

## 🎯 **src/ vs scripts/ - When to Use What**

### `/src/` - **Reusable Python Modules**
**Use for:** Code that gets imported and reused across multiple projects

```
src/
├── __init__.py           # Package initialization
├── bootstrap.py          # Notebook setup utilities
├── paths.py             # Project path resolution
├── viz_helpers.py       # Plotting utilities
├── viz_access.py        # Accessibility features
├── data_cleaning.py     # Generic data cleaning functions
├── model_pipeline.py    # ML pipeline utilities
└── model_eval.py        # Model evaluation helpers
```

**Examples of what goes in src/:**
- Utility functions you import: `from src.viz_helpers import barplot_counts`
- Reusable classes and modules
- Shared data processing logic
- Common plotting functions
- Model evaluation metrics

### `/scripts/` - **Executable Tools & Automation**
**Use for:** Standalone tools that you run directly

```
scripts/
├── README.md                    # Documentation for all scripts
├── jn                          # Jupyter notebook launcher
├── new_notebook.sh             # Create new notebooks from templates
├── export_figures.py           # Extract figures from notebooks
├── export_figures_menu.sh      # Interactive figure export menu
├── export_notebooks.py         # Convert notebooks to markdown
├── export_notebooks_menu.sh    # Interactive notebook export menu
├── jupyter_auto_close.py       # Auto-close Jupyter when browser closes
├── jupyter_tab_manager.sh      # Manage Jupyter tabs
└── cleaning/                   # Data processing workflows
    ├── data_inventory_master_pass1.py
    ├── data_inventory_pipeline.md
    ├── run_data_inventory.sh
    └── generate_column_intersection.py
```

**Examples of what goes in scripts/:**
- Command-line tools: `./scripts/export_figures_menu.sh`
- Data processing pipelines: `./scripts/cleaning/run_data_inventory.sh`
- Automation workflows
- Interactive menus and launchers
- Setup and configuration scripts

## 🗂️ **Complete Portfolio Structure**

```
portfolio/
├── 📁 coursework/                 # Academic projects & case studies
│   └── google-data-analytics/
│       └── ai_workplace_productivity_analysis/
│           ├── notebooks/         # Jupyter analysis notebooks
│           ├── data/             # Raw and processed datasets
│           ├── docs/             # Generated documentation
│           └── reports/          # Exported figures and markdown
│
├── 📁 src/                       # ⭐ REUSABLE PYTHON MODULES
│   ├── __init__.py              # Import these in your notebooks
│   ├── bootstrap.py             # `from src.bootstrap import setup_notebook`
│   ├── viz_helpers.py           # `from src.viz_helpers import barplot_counts`
│   └── ...                      # Other utility modules
│
├── 📁 scripts/                   # ⭐ EXECUTABLE AUTOMATION TOOLS
│   ├── jn                       # `./jn 01` to open notebooks
│   ├── export_figures_menu.sh   # `./export_figures_menu.sh`
│   ├── cleaning/                # Data processing workflows
│   └── ...                      # Other automation scripts
│
├── 📁 planning/                  # Project planning & documentation
├── 📁 showcase/                  # Portfolio presentation materials
├── 📄 README.md                  # Main portfolio documentation
├── 📄 FOLDER_STRUCTURE.md        # This file - folder guide
├── 📄 SETUP.md                   # Environment setup instructions
├── 📄 requirements.txt           # Python dependencies
└── 📄 pyproject.toml            # Package configuration
```

## 🤔 **Common Questions Answered**

### **"Should I put my notebook helper functions in src/ or scripts/?"**
- **src/** if you import them: `from src.helpers import my_function`
- **scripts/** if you run them directly: `python scripts/process_data.py`

### **"What about data processing scripts?"**
- **Small utilities that get imported** → `src/data_cleaning.py`
- **Full processing pipelines you execute** → `scripts/cleaning/process_dataset.py`

### **"Where do project-specific modules go?"**
- **Case study specific code** → Inside the case study folder: `coursework/project_name/src/`
- **Portfolio-wide utilities** → Main `src/` folder

### **"What's the difference from 'source' folders I see online?"**
- `src/` and `source/` are the same thing - just naming preferences
- `src/` is more common in Python projects
- You picked the right convention!

## 🛠️ **How to Use This Structure**

### **In Your Notebooks:**
```python
# Import reusable utilities
from src.bootstrap import setup_notebook
from src.viz_helpers import barplot_counts
from src.viz_access import quick_accessibility_setup

# Set up notebook environment
P, df = setup_notebook("my_data.csv", project="my_analysis")

# Use plotting utilities
barplot_counts(df['category'], title="Distribution by Category")
```

### **From Command Line:**
```bash
# Navigate to portfolio root
cd ~/Documents/portfolio

# Use automation scripts
./scripts/export_figures_menu.sh        # Export notebook figures
./scripts/jn 01                         # Open notebook 01
./scripts/cleaning/run_data_inventory.sh # Run data processing pipeline
```

### **Adding New Code:**
```bash
# New reusable function → Add to src/
echo "def my_utility(): pass" >> src/my_module.py

# New automation script → Add to scripts/
cat > scripts/my_automation.py << 'EOF'
#!/usr/bin/env python3
# Standalone automation script
EOF
chmod +x scripts/my_automation.py
```

## 📋 **Best Practices**

### **src/ Guidelines:**
- ✅ Keep functions small and focused
- ✅ Add docstrings to all functions
- ✅ Make modules importable with `from src.module import function`
- ✅ Avoid hardcoded paths - use `src.paths` utilities
- ❌ Don't put executable scripts here

### **scripts/ Guidelines:**
- ✅ Make scripts executable with `chmod +x`
- ✅ Add `#!/usr/bin/env python3` shebang to Python scripts
- ✅ Include help text and argument parsing
- ✅ Group related scripts in subdirectories (like `cleaning/`)
- ❌ Don't put importable modules here

### **General Organization:**
- ✅ Keep README files up to date
- ✅ Use descriptive folder names
- ✅ Document non-obvious scripts and modules
- ✅ Remove duplicate or outdated files regularly
- ❌ Don't nest too deeply (max 3-4 levels)

## 🎉 **Your Structure is Industry-Standard!**

Your choice of `src/` for modules and `scripts/` for automation follows:
- ✅ **Python packaging conventions** (PEP 517/518)
- ✅ **Data science best practices**
- ✅ **Professional software development standards**
- ✅ **Open source project conventions**

Keep this structure - it's exactly what hiring managers expect to see! 🎯

---

**Last Updated:** October 2025
**Maintainer:** Portfolio Organization System