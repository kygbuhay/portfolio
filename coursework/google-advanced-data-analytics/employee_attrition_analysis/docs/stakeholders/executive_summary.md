# Executive Summary — Salifort Attrition

**Objective.** Predict employee attrition and identify actionable drivers to reduce turnover cost and improve retention.

**Data.** 14,999 employees; 10 features (satisfaction, evaluation, projects, hours, tenure, accident, promotion, department, salary); target `left` (0/1).

**Approach.**
- Baseline logistic regression for interpretability.
- Tree-based models (DT/RF/XGB) for potential lift.
- Metrics emphasized: recall & F1 for `left=1` (catch likely leavers), plus ROC-AUC.

**Key Findings.**
- Top drivers (directionality): _[fill from model]_  
- Class balance: _[ratio]_ ; addressed via _[class_weight / resampling]_  
- Best model: _[name]_ with F1=_[x]_, Recall=_[y]_, ROC-AUC=_[z]_ on validation.

**Recommendations.**
- _[Action 1 tied to driver]_  
- _[Action 2]_  
- _[Pilot/AB test design + expected impact]_  

**Ethical Notes.** Avoid using features that proxy protected classes; monitor false positives/negatives impacts.

