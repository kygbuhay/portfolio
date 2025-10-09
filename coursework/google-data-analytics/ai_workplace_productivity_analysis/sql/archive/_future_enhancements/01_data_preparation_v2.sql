-- ============================================================================
-- 01_data_preparation.sql
-- Project: AI Productivity ROI Analysis (Stack Overflow 2023–2025)
-- Purpose: Schema exploration + defensive prep for evolving column names
-- Author: Kat + BestieGPT
-- How to run: Paste the whole file into BigQuery UI, then highlight & run ONE STEP at a time.
-- ============================================================================

/* -------------------------------------------------------------------------- */
/* STEP 1: Explore schema (run by itself)                                      */
/* -------------------------------------------------------------------------- */

-- 1A) Full column inventory (all tables that start with 'stackoverflow_')
SELECT
  table_name,
  ordinal_position,
  column_name,
  data_type
FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name LIKE 'stackoverflow_%'
ORDER BY table_name, ordinal_position;

-- 1B) Presence checks for tricky columns (rename drift from year to year)
--     This helps you verify which names exist BEFORE writing transformations.
SELECT
  '2023' AS survey_year,
  ARRAY(
    SELECT column_name FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = 'stackoverflow_2023'
      AND column_name IN ('YearsCodePro','YearsCode','LearnCodeAI','AISelect','Employment','DevType')
    ORDER BY column_name
  ) AS present_columns
UNION ALL
SELECT
  '2024' AS survey_year,
  ARRAY(
    SELECT column_name FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = 'stackoverflow_2024'
      AND column_name IN ('YearsCodePro','YearsCode','LearnCodeAI','AISelect','Employment','DevType')
    ORDER BY column_name
  )
UNION ALL
SELECT
  '2025' AS survey_year,
  ARRAY(
    SELECT column_name FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = 'stackoverflow_2025'
      AND column_name IN ('YearsCodePro','YearsCode','LearnCodeAI','AISelect','Employment','DevType')
    ORDER BY column_name
  );

/* -------------------------------------------------------------------------- */
/* STEP 2: Quick peeks (run individually as needed)                            */
/* -------------------------------------------------------------------------- */

-- Sample a few rows to eyeball values & spot odd encodings
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2023` LIMIT 10;
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2024` LIMIT 10;
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2025` LIMIT 10;

/* -------------------------------------------------------------------------- */
/* STEP 3: Normalize & prepare per-year cleaned tables (idempotent)            */
/*         (Run each CREATE OR REPLACE on purpose; safe to rerun anytime)      */
/* -------------------------------------------------------------------------- */

-- 3A) 2023 cleaned
CREATE OR REPLACE TABLE `ai-roi-analysis.survey_data.stackoverflow_2023_cleaned` AS
SELECT
  ResponseId,

  -- Years of professional coding (unified across possible names)
  COALESCE(YearsCodePro, YearsCode) AS YearsCodeUnified,

  -- Defensive numeric conversion for later bucketing
  COALESCE(
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'Less than 1 year' THEN 0.5 END,
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'More than 50 years' THEN 50.0 END,
    SAFE_CAST(COALESCE(YearsCodePro, YearsCode) AS FLOAT64)
  ) AS YearsCodeUnified_num,

  -- Other commonly used downstream fields (keep as strings; cast later as needed)
  CAST(DevType AS STRING)     AS DevType,
  CAST(Employment AS STRING)  AS Employment,

  -- AI usage raw fields (not all exist in 2023, but COALESCE is cheap & safe)
  CAST(COALESCE(LearnCodeAI, AISelect) AS STRING) AS AIUsageUnified_raw

FROM `ai-roi-analysis.survey_data.stackoverflow_2023`;

-- 3B) 2024 cleaned
CREATE OR REPLACE TABLE `ai-roi-analysis.survey_data.stackoverflow_2024_cleaned` AS
SELECT
  ResponseId,
  COALESCE(YearsCodePro, YearsCode) AS YearsCodeUnified,
  COALESCE(
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'Less than 1 year' THEN 0.5 END,
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'More than 50 years' THEN 50.0 END,
    SAFE_CAST(COALESCE(YearsCodePro, YearsCode) AS FLOAT64)
  ) AS YearsCodeUnified_num,
  CAST(DevType AS STRING)     AS DevType,
  CAST(Employment AS STRING)  AS Employment,
  CAST(COALESCE(LearnCodeAI, AISelect) AS STRING) AS AIUsageUnified_raw
FROM `ai-roi-analysis.survey_data.stackoverflow_2024`;

-- 3C) 2025 cleaned (noting that YearsCodePro commonly becomes YearsCode in 2025)
CREATE OR REPLACE TABLE `ai-roi-analysis.survey_data.stackoverflow_2025_cleaned` AS
SELECT
  ResponseId,
  COALESCE(YearsCodePro, YearsCode) AS YearsCodeUnified,
  COALESCE(
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'Less than 1 year' THEN 0.5 END,
    CASE WHEN COALESCE(YearsCodePro, YearsCode) = 'More than 50 years' THEN 50.0 END,
    SAFE_CAST(COALESCE(YearsCodePro, YearsCode) AS FLOAT64)
  ) AS YearsCodeUnified_num,
  CAST(DevType AS STRING)     AS DevType,
  CAST(Employment AS STRING)  AS Employment,
  CAST(COALESCE(LearnCodeAI, AISelect) AS STRING) AS AIUsageUnified_raw
FROM `ai-roi-analysis.survey_data.stackoverflow_2025`;

/* -------------------------------------------------------------------------- */
/* STEP 4: Optional useful views (lightweight, no storage)                     */
/*         These standardize buckets + a simple AI-usage flag.                 */
/* -------------------------------------------------------------------------- */

-- Experience bucketing logic reused across years
CREATE OR REPLACE VIEW `ai-roi-analysis.survey_data._experience_buckets` AS
SELECT 0.0 AS min_years, 2.0 AS max_years, 'Junior'   AS experience_level UNION ALL
SELECT 2.0, 5.0000001, 'Mid-Level'                   UNION ALL
SELECT 5.0, 9.9e9, 'Senior';

-- Per-year standardized view: adds bucket + AI flag from unified raw fields
CREATE OR REPLACE VIEW `ai-roi-analysis.survey_data.stackoverflow_2023_std` AS
SELECT
  c.* EXCEPT(YearsCodeUnified_num),
  b.experience_level,
  CASE
    -- if LearnCodeAI was present and indicates true-ish, mark Yes (rare in 2023)
    WHEN LOWER(TRIM(AIUsageUnified_raw)) IN ('yes','y','true','1') THEN 'Yes'
    -- otherwise fallback: any 'ai' mention in employment is a soft signal
    WHEN LOWER(Employment) LIKE '%ai%' THEN 'Yes'
    ELSE 'No'
  END AS uses_ai_tools
FROM `ai-roi-analysis.survey_data.stackoverflow_2023_cleaned` c
LEFT JOIN `ai-roi-analysis.survey_data._experience_buckets` b
  ON c.YearsCodeUnified_num >= b.min_years AND c.YearsCodeUnified_num < b.max_years;

CREATE OR REPLACE VIEW `ai-roi-analysis.survey_data.stackoverflow_2024_std` AS
SELECT
  c.* EXCEPT(YearsCodeUnified_num),
  b.experience_level,
  CASE
    WHEN LOWER(TRIM(AIUsageUnified_raw)) IN ('yes','y','true','1') THEN 'Yes'
    WHEN LOWER(Employment) LIKE '%ai%' THEN 'Yes'
    ELSE 'No'
  END AS uses_ai_tools
FROM `ai-roi-analysis.survey_data.stackoverflow_2024_cleaned` c
LEFT JOIN `ai-roi-analysis.survey_data._experience_buckets` b
  ON c.YearsCodeUnified_num >= b.min_years AND c.YearsCodeUnified_num < b.max_years;

CREATE OR REPLACE VIEW `ai-roi-analysis.survey_data.stackoverflow_2025_std` AS
SELECT
  c.* EXCEPT(YearsCodeUnified_num),
  b.experience_level,
  CASE
    -- 2025 often has LearnCodeAI; treat explicit Yes/True/1 OR non-empty non-No as usage
    WHEN LOWER(TRIM(AIUsageUnified_raw)) IN ('yes','y','true','1') THEN 'Yes'
    WHEN TRIM(AIUsageUnified_raw) IS NOT NULL AND TRIM(AIUsageUnified_raw) != '' 
         AND LOWER(TRIM(AIUsageUnified_raw)) NOT IN ('no','false','0') THEN 'Yes'
    ELSE 'No'
  END AS uses_ai_tools
FROM `ai-roi-analysis.survey_data.stackoverflow_2025_cleaned` c
LEFT JOIN `ai-roi-analysis.survey_data._experience_buckets` b
  ON c.YearsCodeUnified_num >= b.min_years AND c.YearsCodeUnified_num < b.max_years;

/* -------------------------------------------------------------------------- */
/* STEP 5: Sanity checks                                                       */
/* -------------------------------------------------------------------------- */

-- Counts per year after cleaning
SELECT '2023' AS year, COUNT(*) AS rows FROM `ai-roi-analysis.survey_data.stackoverflow_2023_cleaned`
UNION ALL SELECT '2024', COUNT(*) FROM `ai-roi-analysis.survey_data.stackoverflow_2024_cleaned`
UNION ALL SELECT '2025', COUNT(*) FROM `ai-roi-analysis.survey_data.stackoverflow_2025_cleaned`;

-- Spot-check the standardized views
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2023_std` LIMIT 10;
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2024_std` LIMIT 10;
SELECT * FROM `ai-roi-analysis.survey_data.stackoverflow_2025_std` LIMIT 10;

/* -------------------------------------------------------------------------- */
/* NOTES                                                                       */
/* - Use COALESCE to unify columns that drift year to year (YearsCodePro/YearsCode, etc.).
   - Use SAFE_CAST to avoid runtime errors on numeric conversion.
   - Favor CREATE OR REPLACE to keep the script idempotent (safe to rerun).
   - Run blocks individually: highlight one STEP and execute, review, then proceed. */
/* -------------------------------------------------------------------------- */
