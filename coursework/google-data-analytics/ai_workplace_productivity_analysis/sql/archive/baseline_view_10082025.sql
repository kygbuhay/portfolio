-- ============================================================================
-- AI ROI CASE STUDY — ONE-SHOT BUILD SCRIPT (BigQuery)
-- Creates dataset, UDF, combined view/table, and KPI views ready for Tableau
-- ============================================================================

-- 0) DATASET (idempotent)
CREATE SCHEMA IF NOT EXISTS `ai-roi-analysis.marts`
OPTIONS(
  description="Mart views for AI workplace productivity analysis",
  location="US"
);

-- 0.1) Permanent UDF: Region mapper (call with `ai-roi-analysis.marts`.region_for_country)
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
      'greece','croatia','slovenia','serbia','bosnia and herzegovina','north macedonia','albania',
      'estonia','latvia','lithuania','ukraine','moldova'
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

-- 1) Combined, cleaned view (adds ai_use_category, ai_adopt_flag, sentiment_clean, pos_sent_flag, exp_bucket)
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
),
unioned AS (
  SELECT * FROM base_2023
  UNION ALL SELECT * FROM base_2024
  UNION ALL SELECT * FROM base_2025
)
SELECT
  u.*,

  -- A) Clean adoption category (Yes / Plan to Adopt / No / Unknown)
  CASE
    WHEN LEFT(LOWER(TRIM(u.AISelect)), 3) = 'yes' THEN 'Yes'
    WHEN LOWER(TRIM(u.AISelect)) LIKE 'no, but i plan%' THEN 'Plan to Adopt'
    WHEN LOWER(TRIM(u.AISelect)) LIKE 'no, and i don%' THEN 'No'
    WHEN u.AISelect IS NULL OR TRIM(u.AISelect) = '' THEN 'Unknown'
    ELSE 'Unknown'
  END AS ai_use_category,

  -- B) Strict adoption flag (1/0)
  CASE WHEN LEFT(LOWER(TRIM(u.AISelect)), 3) = 'yes' THEN 1 ELSE 0 END AS ai_adopt_flag,

  -- C) Clean sentiment plus positive flag
  CASE
    WHEN LOWER(TRIM(u.AISent)) IN ('positive','pos') THEN 'Positive'
    WHEN LOWER(TRIM(u.AISent)) IN ('neutral','neut') THEN 'Neutral'
    WHEN LOWER(TRIM(u.AISent)) IN ('negative','neg') THEN 'Negative'
    WHEN u.AISent IS NULL OR TRIM(u.AISent) = '' OR LOWER(TRIM(u.AISent))='nan' THEN 'Unknown'
    ELSE u.AISent
  END AS sentiment_clean,
  CASE WHEN LOWER(TRIM(u.AISent)) IN ('positive','pos') THEN 1 ELSE 0 END AS pos_sent_flag,

  -- D) Experience bucket
  CASE
    WHEN u.YearsCode IS NULL THEN 'Unknown'
    WHEN u.YearsCode < 2 THEN '0-1'
    WHEN u.YearsCode < 5 THEN '2-4'
    WHEN u.YearsCode < 10 THEN '5-9'
    WHEN u.YearsCode < 20 THEN '10-19'
    ELSE '20+'
  END AS exp_bucket

FROM unioned u
;

-- 1.1) Materialized table for Tableau extracts
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.combined_survey_all_years_tbl` AS
SELECT * FROM `ai-roi-analysis.marts.combined_survey_all_years`;

-- 2) KPI views (drag-and-drop ready)

-- 2.1) AI adoption by Region × Year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_ai_adoption_by_region_year` AS
SELECT
  survey_year,
  Region,
  AVG(ai_adopt_flag) AS adoption_rate
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, Region;

-- 2.2) Median comp by AI Use Category × Year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_median_comp_by_aiuse` AS
SELECT
  survey_year,
  ai_use_category,
  APPROX_QUANTILES(ConvertedCompYearly, 100)[OFFSET(50)] AS median_comp_usd
FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE ConvertedCompYearly IS NOT NULL AND ConvertedCompYearly > 0
GROUP BY survey_year, ai_use_category;

-- 2.3) Experience bucket distribution × Year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_experience_buckets` AS
SELECT
  survey_year,
  exp_bucket,
  COUNT(*) AS n
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, exp_bucket;

-- 2.4) Sentiment share by Region × Year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_sentiment_by_region_year` AS
SELECT
  survey_year,
  Region,
  sentiment_clean,
  COUNT(*) AS n,
  COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY survey_year, Region) AS pct
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, Region, sentiment_clean;

-- 3) Helper view for multi-select columns → tidy rows (languages/platforms/etc.)
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

-- 3.1) KPI: Top languages (users = distinct respondents)
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
GROUP BY survey_year, src_col, item;
