# Source Code

Reusable modules that support moving from exploratory notebooks toward maintainable pipelines.

## Files
- data_cleaning.py — Utilities for handling duplicates and empty rows.
- model_pipeline.py — Baseline Random Forest classification pipeline (scikit-learn).
- __init__.py — Marks this directory as a Python package.

## Example
Import helpers in a notebook or script:

    from src.data_cleaning import clean_data
    from src.model_pipeline import build_pipeline

    df_clean = clean_data(df)
    pipe = build_pipeline()
