-- 02_kpi_calculations.sql - FINAL (with Market Summary)
-- Purpose: Calculate all KPIs and create aggregated tables for visualization.
-- This version is complete, handles data types, and includes daily, weekly, monthly, and market-level rollups.

-- ============================================================
-- TABLE 1: Daily KPIs by Market & Problem Type
-- ============================================================
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.kpi_daily` AS
WITH DailyAgg AS (
  SELECT
    date_created,
    market,
    problem_type,
    SUM(COALESCE(SAFE_CAST(contacts_n AS INT64), 0)) AS first_calls,
    SUM(
      COALESCE(SAFE_CAST(contacts_n_1 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_2 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_3 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_4 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_5 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_6 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_7 AS INT64), 0)
    ) AS repeat_calls
  FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  GROUP BY date_created, market, problem_type
)
SELECT
  date_created,
  market,
  problem_type,
  first_calls,
  repeat_calls,
  (first_calls + repeat_calls) AS total_calls,
  SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS repeat_call_rate,
  1 - SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS first_contact_resolution
FROM DailyAgg
WHERE (first_calls + repeat_calls) > 0;

-- ============================================================
-- TABLE 2: Weekly KPIs by Market & Problem Type
-- ============================================================
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.kpi_weekly` AS
WITH WeeklyAgg AS (
  SELECT
    DATE_TRUNC(date_created, WEEK) AS week_start,
    market,
    problem_type,
    SUM(COALESCE(SAFE_CAST(contacts_n AS INT64), 0)) AS first_calls,
    SUM(
      COALESCE(SAFE_CAST(contacts_n_1 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_2 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_3 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_4 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_5 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_6 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_7 AS INT64), 0)
    ) AS repeat_calls
  FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  GROUP BY week_start, market, problem_type
)
SELECT
  week_start,
  market,
  problem_type,
  first_calls,
  repeat_calls,
  (first_calls + repeat_calls) AS total_calls,
  SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS repeat_call_rate,
  1 - SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS first_contact_resolution
FROM WeeklyAgg
WHERE (first_calls + repeat_calls) > 0;

-- ============================================================
-- TABLE 3: Monthly KPIs by Market & Problem Type
-- ============================================================
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.kpi_monthly` AS
WITH MonthlyAgg AS (
  SELECT
    DATE_TRUNC(date_created, MONTH) AS month_start,
    market,
    problem_type,
    SUM(COALESCE(SAFE_CAST(contacts_n AS INT64), 0)) AS first_calls,
    SUM(
      COALESCE(SAFE_CAST(contacts_n_1 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_2 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_3 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_4 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_5 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_6 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_7 AS INT64), 0)
    ) AS repeat_calls
  FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  GROUP BY month_start, market, problem_type
)
SELECT
  month_start,
  market,
  problem_type,
  first_calls,
  repeat_calls,
  (first_calls + repeat_calls) AS total_calls,
  SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS repeat_call_rate,
  1 - SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) AS first_contact_resolution
FROM MonthlyAgg
WHERE (first_calls + repeat_calls) > 0;

-- ============================================================
-- TABLE 4: Overall Market Summary (for KPI cards)
-- ============================================================
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.kpi_market_summary` AS
WITH MarketAgg AS (
  SELECT
    market,
    SUM(COALESCE(SAFE_CAST(contacts_n AS INT64), 0)) AS first_calls,
    SUM(
      COALESCE(SAFE_CAST(contacts_n_1 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_2 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_3 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_4 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_5 AS INT64), 0) + COALESCE(SAFE_CAST(contacts_n_6 AS INT64), 0) +
      COALESCE(SAFE_CAST(contacts_n_7 AS INT64), 0)
    ) AS repeat_calls
  FROM `call-resolution-data.call_center_data.repeat_calls_all_markets`
  GROUP BY market
)
SELECT
  market,
  first_calls,
  repeat_calls,
  (first_calls + repeat_calls) AS total_calls,
  ROUND(SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls)) * 100, 2) AS rcr_pct,
  ROUND((1 - SAFE_DIVIDE(repeat_calls, (first_calls + repeat_calls))) * 100, 2) AS fcr_pct
FROM MarketAgg
WHERE (first_calls + repeat_calls) > 0;
