# Ethics & Bias Review
_Updated: 2025-10-04 16:58_

## Sensitive/Proxy Feature Candidates
- Detected by name heuristic: Department, promotion_last_5years, salary, salary_level, time_spend_company
- Categorical columns: Department, salary
- Numeric columns: satisfaction_level, last_evaluation, number_project, average_montly_hours, time_spend_company, Work_accident, promotion_last_5years, salary_level

### Group Attrition Rate — salary
| salary | count | attrition_rate |
| --- | --- | --- |
| low | 1237 | 0.2968835429196282 |
| medium | 7316 | 0.20431275209432206 |
| high | 6446 | 0.06628940986257073 |

## False Positives vs False Negatives (Risks)
- **Prevalence** of attrition (left=1): `0.238`
- **FP risk**: unnecessary interventions, perceived monitoring, resource waste.
- **FN risk**: preventable attrition, cost, disruption.

## Ethical Risks & Mitigations
- Proxy variables (salary/department) may encode historical inequities.
- Mitigate via subgroup monitoring, threshold policy co-designed with HR, and supportive use only.
- Document model lineage; emphasize that associations ≠ causation.
