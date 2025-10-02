# Source Code

Reusable Python modules to support analysis workflows and help transition from exploratory notebooks to maintainable, production-style pipelines.

## Files
- **data_cleaning.py** — Functions for handling duplicates, missing values, and basic preprocessing.  
- **model_pipeline.py** — Baseline Random Forest classification pipeline using scikit-learn (can be extended).  
- **viz_access.py** — Utilities for colorblind-friendly and accessible plotting defaults.  
- **__init__.py** — Marks this directory as a Python package.  
- **README.md** — Documentation for this folder.  

## Example Usage
Import helpers directly into a notebook or script:

```python
from src.data_cleaning import clean_data
from src.model_pipeline import build_pipeline
from src.viz_access import quick_accessibility_setup

# Apply accessibility settings for plots
quick_accessibility_setup()

# Clean data
df_clean = clean_data(df)

# Build baseline model pipeline
pipe = build_pipeline()
