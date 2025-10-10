-- 03_long_form_rollups.sql - LINTED
-- Purpose: Transform wide repeat-call data into long form for advanced analysis
-- Use this if you want to analyze repeat behavior by day offset (e.g., "how many people called back on day 3?")

-- This version is corrected to handle the STRING data type of the contact columns.

-- ============================================================
-- UNPIVOT: Wide to Long Format
-- ============================================================
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.repeat_calls_long` AS

WITH unpivoted AS (
  -- Unpivot each contacts_n column, casting it to INT64 and handling nulls
  SELECT 
    date_created,
    market,
    problem_type,
    0 AS days_after_first,
    COALESCE(SAFE_CAST(contacts_n AS INT64), 0) AS call_count
  FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  
  UNION ALL
  
  SELECT date_created, market, problem_type, 1, COALESCE(SAFE_CAST(contacts_n_1 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 2, COALESCE(SAFE_CAST(contacts_n_2 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 3, COALESCE(SAFE_CAST(contacts_n_3 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 4, COALESCE(SAFE_CAST(contacts_n_4 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 5, COALESCE(SAFE_CAST(contacts_n_5 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 6, COALESCE(SAFE_CAST(contacts_n_6 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 7, COALESCE(SAFE_CAST(contacts_n_7 AS INT64), 0) FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
)

SELECT *
FROM unpivoted
WHERE call_count > 0;  -- Only keep rows with actual calls

-- ============================================================
-- ANALYSIS: Repeat Call Patterns by Day Offset
-- ============================================================

-- Which day after first contact sees the most repeat calls?
SELECT 
  days_after_first,
  SUM(call_count) as total_calls,
  ROUND(SUM(call_count) * 100.0 / (SELECT SUM(call_count) FROM `call-resolution-data.call_center_data.repeat_calls_long`), 2) as pct_of_total
FROM `call-resolution-data.call_center_data.repeat_calls_long`
GROUP BY days_after_first
ORDER BY days_after_first;

-- Do certain problem types have longer repeat cycles?
SELECT 
  problem_type,
  days_after_first,
  SUM(call_count) as calls
FROM `call-resolution-data.call_center_data.repeat_calls_long`
WHERE days_after_first > 0
GROUP BY problem_type, days_after_first
ORDER BY problem_type, days_after_first;

-- Market comparison: When do customers call back?
SELECT 
  market,
  days_after_first,
  SUM(call_count) as calls
FROM `call-resolution-data.call_center_data.repeat_calls_long`
WHERE days_after_first > 0
GROUP BY market, days_after_first
ORDER BY market, days_after_first;

