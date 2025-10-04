# Baseline Logistic Regression — Results
- Data: 14999 rows × 11 cols (processed)
- Split: train=11999, val=3000 (stratified)

## Metrics (validation)
- Accuracy: 0.7727
- Precision: 0.5143
- Recall: 0.8053
- F1: 0.6277
- ROC-AUC: 0.8369

## Baselines
- Naive 'all stay' accuracy: 0.762
- Logistic vs Naive: IMPROVED

## Notes
- Class weighting enabled (`class_weight='balanced'`).
- Numeric features scaled; any string categoricals one-hot encoded.
- Coefficients inspected for top positive/negative drivers.