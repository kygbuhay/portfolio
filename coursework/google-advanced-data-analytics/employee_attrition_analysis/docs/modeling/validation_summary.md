# Model Selection & Validation — Results
_Updated: 2025-10-04 16:58_
- **Champion:** XGBoost
- Cross-val ROC-AUC (5-fold): 0.9943 ± 0.0059

## Validation Metrics (Held-out Set)
- Accuracy: 0.9857
- Precision: 0.9827
- Recall (left=1): 0.9566
- F1: 0.9695
- ROC-AUC: 0.9947

## Combined Ranking (LogReg + Tree Models)
| model | accuracy | precision | recall | f1 | roc_auc |
| --- | --- | --- | --- | --- | --- |
| XGBoost | 0.9853 | 0.9827 | 0.9552 | 0.9688 | 0.9945 |
| RandomForest | 0.9767 | 0.9777 | 0.923 | 0.9496 | 0.9907 |
| DecisionTree | 0.924 | 0.7819 | 0.944 | 0.8553 | 0.9466 |
| LogisticBaseline | 0.7727 | 0.5143 | 0.8053 | 0.6277 | 0.8369 |

## Justification
- XGBoost selected on ROC-AUC (tie-broken by F1 and Recall).
- Confusion matrix and ROC/PR curves (see §4) confirm acceptable recall on positive class (`left=1`).
- Trade-offs: performance vs. interpretability; tree ensembles offer feature importances.