-- 01_union_all.sql
-- Purpose: Union three market CSVs into single analytical table
-- Output: repeat_calls_all_markets view

-- Instructions:
-- 1. Upload your 3 CSVs to BigQuery dataset (e.g., 'fiber')
-- 2. Run this to create unified view

CREATE OR REPLACE VIEW `call_center_data.repeat_calls_all_markets` AS

-- Market 1
SELECT 
  DATE(date_created) AS date_created,
  contacts_n,
  contacts_n_1,
  contacts_n_2,
  contacts_n_3,
  contacts_n_4,
  contacts_n_5,
  contacts_n_6,
  contacts_n_7,
  new_type AS problem_type,
  'market_1' AS market
FROM `call_center_data.market_1`
WHERE date_created IS NOT NULL  -- Data quality check

UNION ALL

-- Market 2
SELECT 
  DATE(date_created) AS date_created,
  contacts_n,
  contacts_n_1,
  contacts_n_2,
  contacts_n_3,
  contacts_n_4,
  contacts_n_5,
  contacts_n_6,
  contacts_n_7,
  new_type AS problem_type,
  'market_2' AS market
FROM `call_center_data.market_2`
WHERE date_created IS NOT NULL

UNION ALL

-- Market 3
SELECT 
  DATE(date_created) AS date_created,
  contacts_n,
  contacts_n_1,
  contacts_n_2,
  contacts_n_3,
  contacts_n_4,
  contacts_n_5,
  contacts_n_6,
  contacts_n_7,
  new_type AS problem_type,
  'market_3' AS market
FROM `call_center_data.market_3`
WHERE date_created IS NOT NULL;

-- ============================================================
-- VALIDATION QUERIES (run these after creating view)
-- ============================================================

-- Check row counts per market
SELECT 
  market,
  COUNT(*) as row_count,
  MIN(date_created) as first_date,
  MAX(date_created) as last_date
FROM `call_center_data.repeat_calls_all_markets`
GROUP BY market
ORDER BY market;

-- Check problem type distribution
SELECT 
  problem_type,
  COUNT(*) as frequency,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct
FROM `call_center_data.repeat_calls_all_markets`
GROUP BY problem_type
ORDER BY frequency DESC;

-- Sample rows to verify data looks correct
SELECT *
FROM `call_center_data.repeat_calls_all_markets`
LIMIT 100;
