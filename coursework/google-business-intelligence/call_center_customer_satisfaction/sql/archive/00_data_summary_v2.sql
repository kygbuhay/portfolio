-- 00_data_summary.sql (BigQuery) - LINTED
-- Project:  call-resolution-data
-- Dataset:  call_center_data
-- Table:    repeat_calls_all_markets
-- Purpose: Quick, zero-risk diagnostics before KPI calcs.

-- =========================
-- A) Schema inventory
-- =========================
SELECT
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.is_nullable
FROM
  `call-resolution-data.call_center_data.INFORMATION_SCHEMA.COLUMNS` AS c
WHERE
  c.table_name = 'repeat_calls_all_markets'
ORDER BY
  c.ordinal_position;

-- =========================
-- B) Expectation check (what 02_kpi_calculations expects)
--    -> OK or MISSING so you know what to alias in 01_union_all
-- =========================
WITH
  expected AS (
    SELECT 'date_created' AS column_name UNION ALL
    SELECT 'market' UNION ALL
    SELECT 'problem_type' UNION ALL
    SELECT 'contacts_n' UNION ALL
    SELECT 'contacts_n_1' UNION ALL
    SELECT 'contacts_n_2' UNION ALL
    SELECT 'contacts_n_3' UNION ALL
    SELECT 'contacts_n_4' UNION ALL
    SELECT 'contacts_n_5' UNION ALL
    SELECT 'contacts_n_6' UNION ALL
    SELECT 'contacts_n_7'
  ),
  actual AS (
    SELECT
      column_name
    FROM
      `call-resolution-data.call_center_data.INFORMATION_SCHEMA.COLUMNS`
    WHERE
      table_name = 'repeat_calls_all_markets'
  )
SELECT
  e.column_name,
  CASE
    WHEN a.column_name IS NULL
    THEN 'MISSING'
    ELSE 'OK'
  END AS status
FROM
  expected AS e
LEFT JOIN
  actual AS a
  USING (column_name)
ORDER BY
  status DESC,
  e.column_name;

-- =========================
-- C) Quick sample (eyeball values)
-- =========================
SELECT
  *
FROM
  `call-resolution-data.call_center_data.repeat_calls_all_markets`
LIMIT 50;

-- =========================
-- D–F) Deeper stats (run AFTER your aliasing is in place)
-- If any columns are MISSING in step B, either:
--   1) alias them in your data prep script, or
--   2) comment out the sections below that reference them.
-- =========================

-- D) Date range (requires `date_created` to exist & be CASTable to DATE)
-- Note: If 'date_created' is missing, this query will fail.
SELECT
  MIN(CAST(date_created AS DATE)) AS min_date,
  MAX(CAST(date_created AS DATE)) AS max_date
FROM
  `call-resolution-data.call_center_data.repeat_calls_all_markets`;

-- E) Categorical coverage (requires `market`, `problem_type`)
-- Note: If these columns are missing, this query will fail.
SELECT
  'market' AS field,
  COUNT(DISTINCT market) AS distinct_count
FROM
  `call-resolution-data.call_center_data.repeat_calls_all_markets`
UNION ALL
SELECT
  'problem_type' AS field,
  COUNT(DISTINCT problem_type) AS distinct_count
FROM
  `call-resolution-data.call_center_data.repeat_calls_all_markets`;

-- F) Numeric sanity on contacts_n* (requires those columns)
-- Note: This is a refactored, cleaner version of the original query.
WITH
  unpivoted_data AS (
    SELECT
      contact_type,
      contact_value
    FROM
      `call-resolution-data.call_center_data.repeat_calls_all_markets`,
      UNNEST(
        [
          STRUCT('contacts_n' AS contact_type, contacts_n AS contact_value),
          STRUCT('contacts_n_1', contacts_n_1),
          STRUCT('contacts_n_2', contacts_n_2),
          STRUCT('contacts_n_3', contacts_n_3),
          STRUCT('contacts_n_4', contacts_n_4),
          STRUCT('contacts_n_5', contacts_n_5),
          STRUCT('contacts_n_6', contacts_n_6),
          STRUCT('contacts_n_7', contacts_n_7)
        ]
      )
  )
SELECT
  contact_type,
  COUNTIF(contact_value IS NULL) AS nulls,
  COUNTIF(contact_value < 0) AS negatives,
  MIN(contact_value) AS min_val,
  MAX(contact_value) AS max_val,
  ROUND(AVG(contact_value), 2) AS avg_val
FROM
  unpivoted_data
GROUP BY
  contact_type
ORDER BY
  contact_type;

