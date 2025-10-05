# Executive Summary

**Project:** Employee Attrition Analysis
**Owner:** Katherine Ygbuhay
**Updated:** October 2025

---

## Business Objective
Salifort's leadership asked: *"Why are employees leaving, and what can we do to reduce attrition?"*
The business goal is to identify key drivers of turnover and develop a predictive model to guide proactive retention strategies.

---

## Dataset Overview
The dataset represents HR records of employees (n ≈ 15k), including demographic, performance, and workplace attributes.

**Highlights:**
- **Imbalance:** Only ~23–25% of employees left.
- **Departments:** Sales, technical, and support functions dominate the workforce.
- **Sensitive proxies:** Salary bands and department may indirectly encode equity concerns.

![Class Balance](../../reports/figures/03_exploratory_analysis/class_balance_attrition_left.png)
![Department Distribution](../../reports/figures/03_exploratory_analysis/department_distribution.png)

---

## Approach Summary
We followed a structured pipeline:

1. **EDA:** Explored attrition patterns across satisfaction, workload, and department.
2. **Baseline model:** Logistic regression with balanced class weights.
3. **Tree-based models:** Random Forest and XGBoost for non-linear patterns.
4. **Model selection:** Chose champion via validation metrics (ROC-AUC prioritized, with F1/recall tie-breakers).
5. **Ethics review:** Identified bias risks, proxy variables, and mitigations.

![Satisfaction vs Attrition](../../reports/figures/03_exploratory_analysis/satisfaction_level_vs_attrition.png)

---

## Key Findings
- **Satisfaction level is the single strongest predictor:** Employees with low satisfaction are disproportionately likely to leave.
- **Tenure and workload interact:** Short tenure + high projects correlate with attrition risk.
- **Department matters:** Sales and support see elevated attrition rates compared to R&D or management.

---

## Model Performance (Lay Translation)
- **Champion model:** Random Forest (after comparing to Logistic Regression).
- **Validation ROC-AUC ~0.85:** The model can correctly rank leavers vs. stayers 85% of the time.
- **Recall ~0.72 for "leavers":** Roughly 7 out of 10 at-risk employees are identified.
- **Interpretability trade-off:** Logistic regression is simpler, but trees provide better recall and stability.

![Confusion Matrix](../../reports/figures/06_model_selection/confusion_matrix.png)
![ROC Curve](../../reports/figures/06_model_selection/roc_curve.png)

---

## Actionable Recommendations
- **Retention focus:** Target interventions for low-satisfaction and high-project-load employees.
- **Manager training:** Equip supervisors in sales/support to detect early risk signals.
- **Workload balancing:** Monitor projects per employee, especially in first 1–2 years.
- **Policy safeguards:** Use model output for supportive outreach, not punitive actions.

## Conclusion
This analysis shows that attrition at Salifort is **driven most strongly by low satisfaction, early tenure, and workload imbalances**, with department-level disparities. A Random Forest model provides a strong predictive foundation, but success depends on **responsible use**: coupling predictions with human judgment, regular monitoring, and ethical safeguards.

---

## Appendix: Additional Figures

### Salary Distribution
![Salary Distribution](../../reports/figures/03_exploratory_analysis/salary_distribution.png)

### Numeric Feature Distributions
![Numeric Feature Distributions](../../reports/figures/03_exploratory_analysis/numeric_feature_distributions.png)

### Last Evaluation vs Attrition
![Last Evaluation vs Attrition](../../reports/figures/03_exploratory_analysis/last_evaluation_vs_attrition.png)

### Average Monthly Hours vs Attrition
![Average Monthly Hours vs Attrition](../../reports/figures/03_exploratory_analysis/average_montly_hours_vs_attrition.png)

### Time Spent at Company vs Attrition
![Time Spent at Company vs Attrition](../../reports/figures/03_exploratory_analysis/time_spend_company_vs_attrition.png)

### Correlation Heatmap
![Correlation Heatmap](../../reports/figures/03_exploratory_analysis/correlation_heatmap.png)

### Baseline Confusion Matrix
![Baseline Confusion Matrix](../../reports/figures/04_baseline_logreg/confusion_matrix_baseline_logistic_regression.png)

### Baseline ROC Curve
![Baseline ROC Curve](../../reports/figures/04_baseline_logreg/roc_curve_baseline_logistic_regression.png)

### Top Logistic Regression Coefficients
![Top Logistic Regression Coefficients](../../reports/figures/04_baseline_logreg/top_coefficient_magnitudes_baseline_logistic_regression.png)

### ROC Curves - Tree Models
![ROC Curves - Tree Models](../../reports/figures/05_tree_models/roc_curves_tree_based_models.png)

### Feature Importance (Tree Models)
![Feature Importance (Tree Models)](../../reports/figures/05_tree_models/feature_importance_plots.png)

### Feature Importance (Tree Models) 2
![Feature Importance (Tree Models) 2](../../reports/figures/05_tree_models/feature_importance_plots_2.png)

### Feature Importance (Tree Models) 3
![Feature Importance (Tree Models) 3](../../reports/figures/05_tree_models/feature_importance_plots_3.png)

### Precision-Recall Curve
![Precision-Recall Curve](../../reports/figures/06_model_selection/precisionrecall_curve.png)

### Attrition by Salary Band (Ethics)
![Attrition by Salary Band (Ethics)](../../reports/figures/07_ethics_bias_review/attrition_rate_by_salary.png)