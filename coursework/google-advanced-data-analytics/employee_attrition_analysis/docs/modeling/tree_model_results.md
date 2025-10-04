# Tree-Based Models — Results
_Updated: 2025-10-04 16:56_
- Data: 14999 rows × 11 cols (processed)
- Models evaluated: DecisionTree, RandomForest, XGBoost, LogisticBaseline

## Validation Metrics
| model | accuracy | precision | recall | f1 | roc_auc |
| --- | --- | --- | --- | --- | --- |
| XGBoost | 0.9853 | 0.9827 | 0.9552 | 0.9688 | 0.9945 |
| RandomForest | 0.9767 | 0.9777 | 0.923 | 0.9496 | 0.9907 |
| DecisionTree | 0.924 | 0.7819 | 0.944 | 0.8553 | 0.9466 |
| LogisticBaseline | 0.7727 | 0.5143 | 0.8053 | 0.6277 | 0.8369 |

**Champion model:** XGBoost (by ROC-AUC, tie-broken by F1/Recall).

## Notes
- Trees use OHE only; no scaling required.
- Random Forest reduces variance and often stabilizes recall.
- XGBoost (if available) can improve AUC with careful tuning.