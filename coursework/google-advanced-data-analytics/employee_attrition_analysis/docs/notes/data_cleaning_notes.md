# Data Cleaning Notes

**Source file:** `salifort_employee_attrition_raw.csv`
**Cleaned output:** `data/processed/salifort_employee_attrition_cleaned.csv`
**Rows/Cols (cleaned):** 14999 / 11

## Missing Values
- Strategy: >40% missing → drop column; numeric → median; categorical → mode.
- Dropped columns: None

## Format Fixes
- Standardized categorical strings to lowercase/trimmed.
- Coerced likely numerics to numeric with `errors='coerce'`, re-imputed.

## Outliers
- Domain filters applied where applicable.
- Winsorized numeric features at 1st/99th percentiles.

## Encodings
- `salary → salary_level {low:0, medium:1, high:2}` (unknown→-1).
- `department → department_code` via pandas category codes.

## Reproducibility
- Random seed fixed; paths resolved via `src` helpers; raw preserved.