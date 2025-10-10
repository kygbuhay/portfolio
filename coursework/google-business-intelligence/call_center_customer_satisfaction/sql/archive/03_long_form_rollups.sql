-- 03_long_form_rollups.sql (OPTIONAL - Senior Portfolio Enhancement)
-- Purpose: Transform wide repeat-call data into long form for advanced analysis
-- Use this if you want to analyze repeat behavior by day offset (e.g., "how many people called back on day 3?")

-- This is OPTIONAL for Coursera but shows stronger SQL skills in your portfolio

-- ============================================================
-- UNPIVOT: Wide to Long Format
-- ============================================================
CREATE OR REPLACE TABLE `call_center_data.repeat_calls_long` AS

WITH unpivoted AS (
  SELECT 
    date_created,
    market,
    problem_type,
    0 as days_after_first,
    contacts_n as call_count
  FROM `call_center_data.repeat_calls_all_markets`
  
  UNION ALL
  
  SELECT date_created, market, problem_type, 1, contacts_n_1 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 2, contacts_n_2 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 3, contacts_n_3 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 4, contacts_n_4 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 5, contacts_n_5 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 6, contacts_n_6 FROM `call_center_data.repeat_calls_all_markets`
  UNION ALL
  SELECT date_created, market, problem_type, 7, contacts_n_7 FROM `call_center_data.repeat_calls_all_markets`
)

SELECT *
FROM unpivoted
WHERE call_count > 0;  -- Only keep days with actual calls

-- ============================================================
-- ANALYSIS: Repeat Call Patterns by Day Offset
-- ============================================================

-- Which day after first contact sees the most repeat calls?
SELECT 
  days_after_first,
  SUM(call_count) as total_calls,
  ROUND(SUM(call_count) * 100.0 / (SELECT SUM(call_count) FROM `call_center_data.repeat_calls_long`), 2) as pct_of_total
FROM `call_center_data.repeat_calls_long`
GROUP BY days_after_first
ORDER BY days_after_first;

-- Do certain problem types have longer repeat cycles?
SELECT 
  problem_type,
  days_after_first,
  SUM(call_count) as calls
FROM `call_center_data.repeat_calls_long`
WHERE days_after_first > 0
GROUP BY problem_type, days_after_first
ORDER BY problem_type, days_after_first;

-- Market comparison: When do customers call back?
SELECT 
  market,
  days_after_first,
  SUM(call_count) as calls
FROM `call_center_data.repeat_calls_long`
WHERE days_after_first > 0
GROUP BY market, days_after_first
ORDER BY market, days_after_first;

-- ============================================================
-- PORTFOLIO INSIGHT EXAMPLE
-- ============================================================
-- "Most repeat calls occur within 1-2 days of first contact, 
--  suggesting issues with initial troubleshooting scripts rather 
--  than unresolved technical problems (which would show later spikes)"
