-- ============================================================================
-- AI Productivity ROI Analysis - Baseline Views (All Years Intersection) - CORRECTED
-- Author: Katherine Ygbuhay with ChatGPT and Claude AI
-- Date: 2025-10-08
-- Notes:
--   - CORRECTED for actual uploaded table names and column structure
--   - Source tables: 2023_stackoverflow_cleaned, 2024_stackoverflow_cleaned, 2025_stackoverflow_cleaned
--   - Fixed column names and target dataset
-- ============================================================================

-- 0) Create marts dataset if it doesn't exist
----------- REGION MAPPER (TEMP FUNCTION) ----------

CREATE SCHEMA IF NOT EXISTS `ai-roi-analysis.marts`
OPTIONS(
  description="Mart views for AI workplace productivity analysis",
  location="US"
);

CREATE OR REPLACE FUNCTION `ai-roi-analysis.marts.region_for_country`(country STRING)
RETURNS STRING AS (
  CASE
    -- North America
    WHEN LOWER(country) IN ('united states','usa','us','u.s.','u.s.a.','canada') THEN 'North America'
    -- Latin America & Caribbean
    WHEN LOWER(country) IN (
      'mexico','guatemala','honduras','el salvador','nicaragua','costa rica','panama',
      'colombia','venezuela','ecuador','peru','bolivia','chile','argentina','uruguay','paraguay','brazil',
      'cuba','dominican republic','haiti','puerto rico','jamaica','trinidad and tobago','bahamas','barbados'
    ) THEN 'Latin America & Caribbean'
    -- Europe
    WHEN LOWER(country) IN (
      'united kingdom','england','scotland','wales','northern ireland','ireland','germany','france','italy',
      'spain','portugal','netherlands','belgium','sweden','norway','denmark','finland','iceland',
      'switzerland','austria','poland','czechia','czech republic','slovakia','hungary','romania','bulgaria',
      'greece','croatia','slovenia','serbia','bosnia and herzegovina','north macedonia','albania','estonia','latvia','lithuania',
      'ukraine','moldova'
    ) THEN 'Europe'
    -- Sub-Saharan Africa
    WHEN LOWER(country) IN (
      'nigeria','ghana','kenya','ethiopia','tanzania','uganda','rwanda','senegal','cameroon',
      'ivory coast','cote d\'ivoire','south africa','namibia','botswana','zambia','zimbabwe','angola','mozambique'
    ) THEN 'Sub-Saharan Africa'
    -- Middle East & North Africa
    WHEN LOWER(country) IN (
      'morocco','algeria','tunisia','libya','egypt','sudan',
      'saudi arabia','united arab emirates','uae','qatar','kuwait','bahrain','oman','yemen',
      'turkiye','turkey','lebanon','jordan','israel','palestine','iraq','iran','syria'
    ) THEN 'Middle East & North Africa'
    -- South Asia
    WHEN LOWER(country) IN ('india','pakistan','bangladesh','sri lanka','nepal','bhutan','maldives','afghanistan') THEN 'South Asia'
    -- East Asia & Pacific
    WHEN LOWER(country) IN (
      'china','taiwan','hong kong','japan','south korea','korea, south','north korea','mongolia',
      'singapore','malaysia','thailand','vietnam','cambodia','laos','myanmar','philippines','indonesia','brunei',
      'australia','new zealand','papua new guinea','fiji'
    ) THEN 'East Asia & Pacific'
    ELSE 'Other/Unknown'
  END
);

-- ============================================================================
-- 1) Combined survey data 2023–2025
-- Combines all cleaned survey years and adds Region via persistent UDF
-- ============================================================================

CREATE OR REPLACE VIEW `ai-roi-analysis.marts.combined_survey_all_years` AS
WITH base_2023 AS (
  SELECT
    2023 AS survey_year,
    CAST(ResponseId AS STRING) AS ResponseId,
    CAST(AIAcc AS STRING) AS AIAcc,
    CAST(AISelect AS STRING) AS AISelect,
    CAST(AISent AS STRING) AS AISent,
    CAST(Age AS STRING) AS Age,
    SAFE_CAST(CompTotal AS FLOAT64) AS CompTotal,
    SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS ConvertedCompYearly,
    CAST(Country AS STRING) AS Country,
    COALESCE(`ai-roi-analysis.marts`.region_for_country(Country), 'Other/Unknown') AS Region,
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(Industry AS STRING) AS Industry,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(LearnCode AS STRING) AS LearnCode,
    CAST(MainBranch AS STRING) AS MainBranch,
    CAST(OfficeStackAsyncHaveWorkedWith AS STRING) AS OfficeStackAsyncHaveWorkedWith,
    CAST(OfficeStackAsyncWantToWorkWith AS STRING) AS OfficeStackAsyncWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(PlatformHaveWorkedWith AS STRING) AS PlatformHaveWorkedWith,
    CAST(PlatformWantToWorkWith AS STRING) AS PlatformWantToWorkWith,
    CAST(PurchaseInfluence AS STRING) AS PurchaseInfluence,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOAccount AS STRING) AS SOAccount,
    CAST(SOComm AS STRING) AS SOComm,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN SAFE_CAST(WorkExp AS FLOAT64) IS NOT NULL THEN SAFE_CAST(WorkExp AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS WorkExp,
    CASE
      WHEN SAFE_CAST(YearsCode AS FLOAT64) IS NOT NULL THEN SAFE_CAST(YearsCode AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS YearsCode
  FROM `ai-roi-analysis.survey_data.2023_stackoverflow_cleaned`
),
base_2024 AS (
  SELECT
    2024 AS survey_year,
    CAST(ResponseId AS STRING) AS ResponseId,
    CAST(AIAcc AS STRING) AS AIAcc,
    CAST(AISelect AS STRING) AS AISelect,
    CAST(AISent AS STRING) AS AISent,
    CAST(Age AS STRING) AS Age,
    SAFE_CAST(CompTotal AS FLOAT64) AS CompTotal,
    SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS ConvertedCompYearly,
    CAST(Country AS STRING) AS Country,
    COALESCE(`ai-roi-analysis.marts`.region_for_country(Country), 'Other/Unknown') AS Region,
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(Industry AS STRING) AS Industry,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(LearnCode AS STRING) AS LearnCode,
    CAST(MainBranch AS STRING) AS MainBranch,
    CAST(OfficeStackAsyncHaveWorkedWith AS STRING) AS OfficeStackAsyncHaveWorkedWith,
    CAST(OfficeStackAsyncWantToWorkWith AS STRING) AS OfficeStackAsyncWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(PlatformHaveWorkedWith AS STRING) AS PlatformHaveWorkedWith,
    CAST(PlatformWantToWorkWith AS STRING) AS PlatformWantToWorkWith,
    CAST(PurchaseInfluence AS STRING) AS PurchaseInfluence,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOAccount AS STRING) AS SOAccount,
    CAST(SOComm AS STRING) AS SOComm,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN SAFE_CAST(WorkExp AS FLOAT64) IS NOT NULL THEN SAFE_CAST(WorkExp AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS WorkExp,
    CASE
      WHEN SAFE_CAST(YearsCode AS FLOAT64) IS NOT NULL THEN SAFE_CAST(YearsCode AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS YearsCode
  FROM `ai-roi-analysis.survey_data.2024_stackoverflow_cleaned`
),
base_2025 AS (
  SELECT
    2025 AS survey_year,
    CAST(ResponseId AS STRING) AS ResponseId,
    CAST(AIAcc AS STRING) AS AIAcc,
    CAST(AISelect AS STRING) AS AISelect,
    CAST(AISent AS STRING) AS AISent,
    CAST(Age AS STRING) AS Age,
    SAFE_CAST(CompTotal AS FLOAT64) AS CompTotal,
    SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS ConvertedCompYearly,
    CAST(Country AS STRING) AS Country,
    COALESCE(`ai-roi-analysis.marts`.region_for_country(Country), 'Other/Unknown') AS Region,
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(Industry AS STRING) AS Industry,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(LearnCode AS STRING) AS LearnCode,
    CAST(MainBranch AS STRING) AS MainBranch,
    CAST(OfficeStackAsyncHaveWorkedWith AS STRING) AS OfficeStackAsyncHaveWorkedWith,
    CAST(OfficeStackAsyncWantToWorkWith AS STRING) AS OfficeStackAsyncWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(PlatformHaveWorkedWith AS STRING) AS PlatformHaveWorkedWith,
    CAST(PlatformWantToWorkWith AS STRING) AS PlatformWantToWorkWith,
    CAST(PurchaseInfluence AS STRING) AS PurchaseInfluence,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOAccount AS STRING) AS SOAccount,
    CAST(SOComm AS STRING) AS SOComm,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN SAFE_CAST(WorkExp AS FLOAT64) IS NOT NULL THEN SAFE_CAST(WorkExp AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS WorkExp,
    CASE
      WHEN SAFE_CAST(YearsCode AS FLOAT64) IS NOT NULL THEN SAFE_CAST(YearsCode AS FLOAT64)
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE NULL
    END AS YearsCode
  FROM `ai-roi-analysis.survey_data.2025_stackoverflow_cleaned`
)
SELECT * FROM base_2023
UNION ALL
SELECT * FROM base_2024
UNION ALL
SELECT * FROM base_2025;

-- 2) Helper view to explode multi-selects into tidy rows for Tableau
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.msplits` AS
SELECT
  cs.survey_year,
  cs.ResponseId,
  TRIM(item) AS item,
  entry.src_col
FROM `ai-roi-analysis.marts.combined_survey_all_years` AS cs,
UNNEST([
  STRUCT('LanguageHaveWorkedWith' AS src_col, SPLIT(cs.LanguageHaveWorkedWith, r';\s*') AS arr),
  STRUCT('LanguageWantToWorkWith' AS src_col, SPLIT(cs.LanguageWantToWorkWith, r';\s*') AS arr),
  STRUCT('DatabaseHaveWorkedWith' AS src_col, SPLIT(cs.DatabaseHaveWorkedWith, r';\s*') AS arr),
  STRUCT('DatabaseWantToWorkWith' AS src_col, SPLIT(cs.DatabaseWantToWorkWith, r';\s*') AS arr),
  STRUCT('PlatformHaveWorkedWith' AS src_col, SPLIT(cs.PlatformHaveWorkedWith, r';\s*') AS arr),
  STRUCT('PlatformWantToWorkWith' AS src_col, SPLIT(cs.PlatformWantToWorkWith, r';\s*') AS arr),
  STRUCT('WebframeHaveWorkedWith' AS src_col, SPLIT(cs.WebframeHaveWorkedWith, r';\s*') AS arr),
  STRUCT('WebframeWantToWorkWith' AS src_col, SPLIT(cs.WebframeWantToWorkWith, r';\s*') AS arr),
  STRUCT('OfficeStackAsyncHaveWorkedWith' AS src_col, SPLIT(cs.OfficeStackAsyncHaveWorkedWith, r';\s*') AS arr),
  STRUCT('OfficeStackAsyncWantToWorkWith' AS src_col, SPLIT(cs.OfficeStackAsyncWantToWorkWith, r';\s*') AS arr)
]) AS entry,
UNNEST(entry.arr) AS item
WHERE item IS NOT NULL
  AND item != ''
  AND item != 'nan';

-- 3) KPI views

-- 3a) AI adoption by year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_ai_adoption_by_year` AS
SELECT
  survey_year,
  SAFE_DIVIDE(SUM(CASE WHEN AISelect = 'Yes' THEN 1 ELSE 0 END), COUNT(1)) AS adoption_rate
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year
ORDER BY survey_year;

-- 3b) Sentiment distribution by year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_sentiment_by_year` AS
SELECT
  survey_year,
  AISent,
  COUNT(1) AS n
FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE AISent IS NOT NULL
  AND AISent != 'nan'
  AND AISent != ''
GROUP BY survey_year, AISent
ORDER BY survey_year, AISent;

-- 3c) Compensation vs AI usage (median by year)
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_median_comp_by_aiuse` AS
WITH base AS (
  SELECT
    survey_year,
    AISelect,
    ConvertedCompYearly
  FROM `ai-roi-analysis.marts.combined_survey_all_years`
  WHERE ConvertedCompYearly IS NOT NULL
    AND ConvertedCompYearly > 0
)
SELECT
  survey_year,
  AISelect,
  APPROX_QUANTILES(ConvertedCompYearly, 100)[OFFSET(50)] AS median_comp
FROM base
GROUP BY survey_year, AISelect
ORDER BY survey_year, AISelect;

-- 3d) Experience buckets vs AI usage
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_experience_buckets` AS
WITH buckets AS (
  SELECT
    survey_year,
    AISelect,
    YearsCode,
    CASE
      WHEN YearsCode IS NULL THEN 'Unknown'
      WHEN YearsCode < 2 THEN '0-1'
      WHEN YearsCode < 5 THEN '2-4'
      WHEN YearsCode < 10 THEN '5-9'
      WHEN YearsCode < 20 THEN '10-19'
      ELSE '20+'
    END AS exp_bucket
  FROM `ai-roi-analysis.marts.combined_survey_all_years`
)
SELECT
  survey_year,
  AISelect,
  exp_bucket,
  COUNT(1) AS n
FROM buckets
GROUP BY survey_year, AISelect, exp_bucket
ORDER BY survey_year, exp_bucket, AISelect;

-- 3e) Top 15 languages used vs want-to-use by year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_top_languages` AS
SELECT
  survey_year,
  src_col,
  item,
  COUNT(DISTINCT ResponseId) AS users
FROM `ai-roi-analysis.marts.msplits`
WHERE src_col IN ('LanguageHaveWorkedWith', 'LanguageWantToWorkWith')
  AND item IS NOT NULL
  AND item != ''
  AND item != 'nan'
GROUP BY survey_year, src_col, item
ORDER BY survey_year, src_col, users DESC;

-- 4) Convenience table for Tableau extracts (optional materialized view)
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.combined_survey_all_years_tbl` AS
SELECT * FROM `ai-roi-analysis.marts.combined_survey_all_years`;

-- ============================================================================
-- CORRECTIONS APPLIED:
-- 1. Fixed table names: stackoverflow_YYYY -> YYYY_stackoverflow_cleaned
-- 2. Fixed column names: OpSysPersonal use -> OpSysPersonal_use (underscore)
-- 3. Added marts dataset creation
-- 4. Enhanced NULL/empty string filtering
-- 5. Added ConvertedCompYearly > 0 filter for compensation analysis
-- ============================================================================
