# Source Code

Reusable Python modules to support analysis workflows across all portfolio case studies. These utilities help transition from exploratory notebooks to maintainable, production-style pipelines.

## Files
- **bootstrap.py** — Notebook setup with theme, accessibility, paths, and data loading
- **paths.py** — Project path resolution with multi-fallback strategy for flexible project structure
- **viz_helpers.py** — Plot utilities (pretty labels, bar charts, histograms, boxplots)
- **viz_access.py** — Accessibility helpers (colorblind palettes, WCAG contrast checking, hatching patterns)
- **data_cleaning.py** — Generic data cleaning utilities (duplicates, missing values, preprocessing)
- **model_pipeline.py** — Baseline modeling pipelines (can be extended per project)
- **__init__.py** — Package initialization exposing key functions

## Example Usage
Import helpers directly into a notebook or script:

```python
from src.bootstrap import setup_notebook, write_notes
from src.viz_access import quick_accessibility_setup
from src.viz_helpers import pretty_label, barplot_counts

# Setup notebook with accessibility and project paths
P, df = setup_notebook(
    raw_filename="your_data_raw.csv",
    proc_filename="your_data_cleaned.csv",
    load="proc",
    project="your_case_study_name"
)

# Visualizations with accessibility built in
barplot_counts(df['category'], title="Distribution by Category")
