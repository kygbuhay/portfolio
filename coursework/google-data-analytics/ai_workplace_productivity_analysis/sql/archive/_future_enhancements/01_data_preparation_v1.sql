-- =============================================================================
-- 01: Data Exploration & Column Discovery
-- Purpose: Find the AI-related columns and understand the data structure
-- Author: Katherine Ygbuhay
-- =============================================================================

-- STEP 1: Find all AI-related columns across all years
-- =============================================================================
SELECT 
  table_name,
  column_name,
  data_type
FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('stackoverflow_2023', 'stackoverflow_2024', 'stackoverflow_2025')
  AND (
    LOWER(column_name) LIKE '%ai%'
    OR LOWER(column_name) LIKE '%tool%'
    OR LOWER(column_name) LIKE '%tech%'
    OR LOWER(column_name) LIKE '%copilot%'
    OR LOWER(column_name) LIKE '%chatgpt%'
  )
ORDER BY table_name, column_name;

-- STEP 2: Explore key demographic columns
-- =============================================================================
-- 2023 Experience Distribution
SELECT 
  'stackoverflow_2023' AS table_name,
  YearsCodePro,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM `ai-roi-analysis.survey_data.stackoverflow_2023`
WHERE YearsCodePro IS NOT NULL
GROUP BY YearsCodePro
ORDER BY count DESC
LIMIT 15;

-- 2024 Experience Distribution  
SELECT 
  'stackoverflow_2024' AS table_name,
  YearsCodePro,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM `ai-roi-analysis.survey_data.stackoverflow_2024`
WHERE YearsCodePro IS NOT NULL
GROUP BY YearsCodePro
ORDER BY count DESC
LIMIT 15;

-- 2025 Experience Distribution
SELECT 
  'stackoverflow_2025' AS table_name,
  YearsCodePro,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM `ai-roi-analysis.survey_data.stackoverflow_2025`
WHERE YearsCodePro IS NOT NULL
GROUP BY YearsCodePro
ORDER BY count DESC
LIMIT 15;

-- STEP 3: Sample actual data to see what's in the AI columns
-- =============================================================================
-- Once we know column names from STEP 1, we'll examine sample values
-- For now, checking a few potential candidates:

-- Check 2024 sample
SELECT 
  ResponseId,
  YearsCodePro,
  DevType,
  Employment,
  -- Add any AI columns you found in STEP 1 here
FROM `ai-roi-analysis.survey_data.stackoverflow_2024`
LIMIT 100;
