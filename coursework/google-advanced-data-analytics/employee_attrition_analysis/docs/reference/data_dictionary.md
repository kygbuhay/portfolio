
# Data Dictionary – Employee Attrition Dataset

| Column                | Type      | Description                                                                 |
|------------------------|-----------|-----------------------------------------------------------------------------|
| satisfaction_level     | float     | Employee’s self-reported satisfaction (0–1 scale).                         |
| last_evaluation        | float     | Performance evaluation score by management (0–1 scale).                    |
| number_project         | int       | Number of projects the employee has worked on.                             |
| average_montly_hours   | int       | Average number of hours worked per month (*note the misspelling retained*).|
| time_spend_company     | int       | Number of years the employee has been with the company.                     |
| Work_accident          | int (0/1) | Whether the employee had a workplace accident (1 = yes).                   |
| left                   | int (0/1) | Target variable: whether the employee left the company (1 = yes).          |
| promotion_last_5years  | int (0/1) | Whether the employee was promoted in the last 5 years.                     |
| Department             | category  | Department name (e.g., sales, support, technical).                         |
| salary                 | category  | Salary category: low, medium, or high.                                     |

---

### Data Quality Notes
- No missing values detected across columns.
- `average_montly_hours` has a spelling error but will be kept as-is for reproducibility.
- `salary` and `Department` are categorical variables requiring encoding for modeling.
- Target (`left`) is imbalanced: ~24% of employees left vs. ~76% retained.
