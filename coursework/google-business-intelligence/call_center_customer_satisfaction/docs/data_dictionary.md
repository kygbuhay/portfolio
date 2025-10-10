# Dataset README (Integrated)
- **File:** `data_summary.csv`
- **Rows:** 11
- **Columns:** 5
- **Generated:** 2025-10-10 04:57
- **Schema Signature:** `e64147f631ed`

## KPI Formulas (parsed from SQL)
_No KPI formulas detected — add `-- KPI: name = expression` comments or `AS kpi_*` in SQL to populate._

## Column Summary (auto-profile)

| Column | Type | Nulls | Distinct | Derived From |
|---|---|---:|---:|---|
| `ordinal_position` | `int64` | 0 | 11 | — |
| `column_name` | `object` | 0 | 11 | — |
| `data_type` | `object` | 0 | 2 | — |
| `expected_column_status` | `object` | 0 | 1 | — |
| `summary_statistic` | `object` | 0 | 11 | — |

## Column Details
### `ordinal_position`
- **Derived From:** —
- **Type:** `int64`
- **Nulls:** 0 (0.0%)
- **Distinct:** 11
- **Range:** 1 — 11
- **Mean/Median/Std:** 6.0 / 6.0 / 3.1623
- **Sample values:** `1`, `2`, `3`, `4`, `5`
- **Top categories:**
| Value | Count | % |
|---|---:|---:|
| `1` | 1 | 9.09% |
| `2` | 1 | 9.09% |
| `3` | 1 | 9.09% |
| `4` | 1 | 9.09% |
| `5` | 1 | 9.09% |
| `6` | 1 | 9.09% |
| `7` | 1 | 9.09% |
| `8` | 1 | 9.09% |
| `9` | 1 | 9.09% |
| `10` | 1 | 9.09% |

### `column_name`
- **Derived From:** —
- **Type:** `object`
- **Nulls:** 0 (0.0%)
- **Distinct:** 11
- **Sample values:** `date_created`, `contacts_n`, `contacts_n_1`, `contacts_n_2`, `contacts_n_3`
- **Top categories:**
| Value | Count | % |
|---|---:|---:|
| `date_created` | 1 | 9.09% |
| `contacts_n` | 1 | 9.09% |
| `contacts_n_1` | 1 | 9.09% |
| `contacts_n_2` | 1 | 9.09% |
| `contacts_n_3` | 1 | 9.09% |
| `contacts_n_4` | 1 | 9.09% |
| `contacts_n_5` | 1 | 9.09% |
| `contacts_n_6` | 1 | 9.09% |
| `contacts_n_7` | 1 | 9.09% |
| `problem_type` | 1 | 9.09% |

### `data_type`
- **Derived From:** —
- **Type:** `object`
- **Nulls:** 0 (0.0%)
- **Distinct:** 2
- **Sample values:** `DATE`, `STRING`
- **Top categories:**
| Value | Count | % |
|---|---:|---:|
| `STRING` | 10 | 90.91% |
| `DATE` | 1 | 9.09% |

### `expected_column_status`
- **Derived From:** —
- **Type:** `object`
- **Nulls:** 0 (0.0%)
- **Distinct:** 1
- **Sample values:** `OK`
- **Top categories:**
| Value | Count | % |
|---|---:|---:|
| `OK` | 11 | 100.00% |

### `summary_statistic`
- **Derived From:** —
- **Type:** `object`
- **Nulls:** 0 (0.0%)
- **Distinct:** 11
- **Sample values:** `Range: 2022-01-01 to 2022-03-31`, `Nulls: 182, Negatives: 0, Min: 1, Max: 599, Avg: 55.6`, `Nulls: 458, Negatives: 0, Min: 0, Max: 138, Avg: 6.28`, `Nulls: 529, Negatives: 0, Min: 0, Max: 108, Avg: 4.24`, `Nulls: 572, Negatives: 0, Min: 0, Max: 21, Avg: 3.47`
- **Top categories:**
| Value | Count | % |
|---|---:|---:|
| `Range: 2022-01-01 to 2022-03-31` | 1 | 9.09% |
| `Nulls: 182, Negatives: 0, Min: 1, Max: 599, Avg: 55.6` | 1 | 9.09% |
| `Nulls: 458, Negatives: 0, Min: 0, Max: 138, Avg: 6.28` | 1 | 9.09% |
| `Nulls: 529, Negatives: 0, Min: 0, Max: 108, Avg: 4.24` | 1 | 9.09% |
| `Nulls: 572, Negatives: 0, Min: 0, Max: 21, Avg: 3.47` | 1 | 9.09% |
| `Nulls: 611, Negatives: 0, Min: 0, Max: 27, Avg: 3.11` | 1 | 9.09% |
| `Nulls: 631, Negatives: 0, Min: 0, Max: 24, Avg: 3.05` | 1 | 9.09% |
| `Nulls: 634, Negatives: 0, Min: 0, Max: 20, Avg: 2.77` | 1 | 9.09% |
| `Nulls: 617, Negatives: 0, Min: 0, Max: 28, Avg: 2.7` | 1 | 9.09% |
| `5 distinct values` | 1 | 9.09% |

## Problem Type Mapping
_No `problem_type_lookup.csv` found. Add one with columns `code,label` to populate this table._

## Business Interpretation (stakeholder notes)
_Add brief narrative: why the metrics matter, targets (e.g., `FCR > 85%`), and operational caveats._

