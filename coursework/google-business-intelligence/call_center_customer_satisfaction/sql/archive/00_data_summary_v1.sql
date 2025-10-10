-- 00_data_summary.sql  (BigQuery)
-- Project:  call-resolution-data
-- Dataset:  call_center_data
-- Table:    repeat_calls_all_markets
-- Purpose: quick, zero-risk diagnostics before KPI calcs.

DECLARE project_id STRING DEFAULT 'call-resolution-data';
DECLARE dataset_id STRING DEFAULT 'call_center_data';
DECLARE table_id   STRING DEFAULT 'repeat_calls_all_markets';

-- =========================
-- A) Schema inventory
-- =========================
SELECT
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.is_nullable
FROM `${project_id}.${dataset_id}.INFORMATION_SCHEMA.COLUMNS` AS c
WHERE c.table_name = table_id
ORDER BY c.ordinal_position;

-- =========================
-- B) Expectation check (what 02_kpi_calculations expects)
--    -> OK or MISSING so you know what to alias in 01_union_all
-- =========================
WITH expected AS (
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
  SELECT column_name
  FROM `${project_id}.${dataset_id}.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = table_id
)
SELECT
  e.column_name,
  CASE WHEN a.column_name IS NULL THEN 'MISSING' ELSE 'OK' END AS status
FROM expected e
LEFT JOIN actual a USING (column_name)
ORDER BY status DESC, e.column_name;

-- =========================
-- C) Quick sample (eyeball values)
-- =========================
SELECT *
FROM `${project_id}.${dataset_id}.${table_id}`
LIMIT 50;

-- =========================
-- D–F) Deeper stats (run AFTER your 01/02 aliasing is in place)
-- If any of these columns are still MISSING above, either:
--   1) alias them in 01_union_all, or
--   2) comment out the sections that reference them.
-- =========================

-- D) Date range (requires `date_created` to exist & be CASTable to DATE)
SELECT
  MIN(CAST(date_created AS DATE)) AS min_date,
  MAX(CAST(date_created AS DATE)) AS max_date
FROM `${project_id}.${dataset_id}.${table_id}`;

-- E) Categorical coverage (requires `market`, `problem_type`)
SELECT
  'market' AS field, COUNT(DISTINCT market) AS distinct_count
FROM `${project_id}.${dataset_id}.${table_id}`
UNION ALL
SELECT
  'problem_type' AS field, COUNT(DISTINCT problem_type) AS distinct_count
FROM `${project_id}.${dataset_id}.${table_id}`;

-- F) Numeric sanity on contacts_n* (requires those columns)
WITH base AS (
  SELECT
    contacts_n,
    contacts_n_1, contacts_n_2, contacts_n_3, contacts_n_4,
    contacts_n_5, contacts_n_6, contacts_n_7
  FROM `${project_id}.${dataset_id}.${table_id}`
)
SELECT
  'contacts_n'   AS col, COUNTIF(contacts_n   IS NULL) AS nulls, COUNTIF(contacts_n   < 0) AS negatives, MIN(contacts_n)   AS min_val, MAX(contacts_n)   AS max_val, AVG(contacts_n)   AS avg_val
FROM base
UNION ALL SELECT 'contacts_n_1', COUNTIF(contacts_n_1 IS NULL), COUNTIF(contacts_n_1 < 0), MIN(contacts_n_1), MAX(contacts_n_1), AVG(contacts_n_1) FROM base
UNION ALL SELECT 'contacts_n_2', COUNTIF(contacts_n_2 IS NULL), COUNTIF(contacts_n_2 < 0), MIN(contacts_n_2), MAX(contacts_n_2), AVG(contacts_n_2) FROM base
UNION ALL SELECT 'contacts_n_3', COUNTIF(contacts_n_3 IS NULL), COUNTIF(contacts_n_3 < 0), MIN(contacts_n_3), MAX(contacts_n_3), AVG(contacts_n_3) FROM base
UNION ALL SELECT 'contacts_n_4', COUNTIF(contacts_n_4 IS NULL), COUNTIF(contacts_n_4 < 0), MIN(contacts_n_4), MAX(contacts_n_4), AVG(contacts_n_4) FROM base
UNION ALL SELECT 'contacts_n_5', COUNTIF(contacts_n_5 IS NULL), COUNTIF(contacts_n_5 < 0), MIN(contacts_n_5), MAX(contacts_n_5), AVG(contacts_n_5) FROM base
UNION ALL SELECT 'contacts_n_6', COUNTIF(contacts_n_6 IS NULL), COUNTIF(contacts_n_6 < 0), MIN(contacts_n_6), MAX(contacts_n_6), AVG(contacts_n_6) FROM base
UNION ALL SELECT 'contacts_n_7', COUNTIF(contacts_n_7 IS NULL), COUNTIF(contacts_n_7 < 0), MIN(contacts_n_7), MAX(contacts_n_7), AVG(contacts_n_7) FROM base;

