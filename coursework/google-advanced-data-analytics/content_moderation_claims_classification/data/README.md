# Data

Sample data used for this case study.

## Files
- raw/tiktok_dataset.csv — Educational/simulated dataset (19,383 rows × 12 columns).

## Notes
- Only lightweight, non-sensitive data is versioned; large/sensitive files are excluded via `.gitignore`.
- See docs/reference/data_dictionary.md for field definitions.
- Loading example:

    import pandas as pd
    df = pd.read_csv("data/raw/tiktok_dataset.csv")
