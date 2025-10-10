-- 02_kpi_calculations.sql
-- Purpose: Calculate Repeat Call Rate (RCR) and First Contact Resolution (FCR)
-- This creates aggregated tables ready for Tableau visualization

-- ============================================================
-- KPI DEFINITIONS
-- ============================================================
-- Total Calls = contacts_n + sum(contacts_n_1 through contacts_n_7)
-- Repeat Calls = sum(contacts_n_1 through contacts_n_7)
-- Repeat Call Rate (RCR) = Repeat Calls / Total Calls
-- First Contact Resolution (FCR) = 1 - RCR

-- ============================================================
-- TABLE 1: Daily KPIs by Market & Problem Type
-- ============================================================
CREATE OR REPLACE TABLE `call_center_data.kpi_daily` AS
SELECT 
  date_created,
  market,
  problem_type,
  
  -- Call volume metrics
  SUM(contacts_n) as first_calls,
  SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
      contacts_n_5 + contacts_n_6 + contacts_n_7) as repeat_calls,
  SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
      contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7) as total_calls,
  
  -- Calculated KPIs
  SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as repeat_call_rate,
  
  1 - SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as first_contact_resolution

FROM `call_center_data.repeat_calls_all_markets`
GROUP BY date_created, market, problem_type
HAVING total_calls > 0;  -- Filter out zero-call days

-- ============================================================
-- TABLE 2: Weekly KPIs (for trend analysis)
-- ============================================================
CREATE OR REPLACE TABLE `call_center_data.kpi_weekly` AS
SELECT 
  DATE_TRUNC(date_created, WEEK) as week_start,
  market,
  problem_type,
  
  SUM(contacts_n) as first_calls,
  SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
      contacts_n_5 + contacts_n_6 + contacts_n_7) as repeat_calls,
  SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
      contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7) as total_calls,
  
  SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as repeat_call_rate,
  
  1 - SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as first_contact_resolution

FROM `call_center_data.repeat_calls_all_markets`
GROUP BY week_start, market, problem_type
HAVING total_calls > 0;

-- ============================================================
-- TABLE 3: Monthly KPIs (for executive reporting)
-- ============================================================
CREATE OR REPLACE TABLE `call_center_data.kpi_monthly` AS
SELECT 
  DATE_TRUNC(date_created, MONTH) as month_start,
  market,
  problem_type,
  
  SUM(contacts_n) as first_calls,
  SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
      contacts_n_5 + contacts_n_6 + contacts_n_7) as repeat_calls,
  SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
      contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7) as total_calls,
  
  SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as repeat_call_rate,
  
  1 - SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) as first_contact_resolution

FROM `call_center_data.repeat_calls_all_markets`
GROUP BY month_start, market, problem_type
HAVING total_calls > 0;

-- ============================================================
-- TABLE 4: Overall Market Summary (for KPI cards)
-- ============================================================
CREATE OR REPLACE TABLE `call_center_data.kpi_market_summary` AS
SELECT 
  market,
  
  SUM(contacts_n) as first_calls,
  SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
      contacts_n_5 + contacts_n_6 + contacts_n_7) as repeat_calls,
  SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
      contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7) as total_calls,
  
  ROUND(SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  ) * 100, 2) as rcr_pct,
  
  ROUND((1 - SAFE_DIVIDE(
    SUM(contacts_n_1 + contacts_n_2 + contacts_n_3 + contacts_n_4 + 
        contacts_n_5 + contacts_n_6 + contacts_n_7),
    SUM(contacts_n + contacts_n_1 + contacts_n_2 + contacts_n_3 + 
        contacts_n_4 + contacts_n_5 + contacts_n_6 + contacts_n_7)
  )) * 100, 2) as fcr_pct

FROM `call_center_data.repeat_calls_all_markets`
GROUP BY market;

-- ============================================================
-- VALIDATION QUERIES
-- ============================================================

-- Check market-level KPIs
SELECT 
  market,
  total_calls,
  CONCAT(CAST(rcr_pct AS STRING), '%') as repeat_call_rate,
  CONCAT(CAST(fcr_pct AS STRING), '%') as first_contact_resolution
FROM `call_center_data.kpi_market_summary`
ORDER BY rcr_pct DESC;

-- Check problem type distribution
SELECT 
  problem_type,
  SUM(total_calls) as total_calls,
  ROUND(AVG(repeat_call_rate) * 100, 2) as avg_rcr_pct
FROM `call_center_data.kpi_daily`
GROUP BY problem_type
ORDER BY avg_rcr_pct DESC;

-- Check weekly trends
SELECT 
  week_start,
  SUM(total_calls) as weekly_calls,
  ROUND(AVG(repeat_call_rate) * 100, 2) as avg_rcr_pct
FROM `call_center_data.kpi_weekly`
GROUP BY week_start
ORDER BY week_start;
