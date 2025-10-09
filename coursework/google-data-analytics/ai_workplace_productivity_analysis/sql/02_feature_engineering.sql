-- 02_feature_engineering.sql
-- Combined, cleaned view + optional materialized table for Tableau extracts

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
unified AS (
  SELECT * FROM base_2023
  UNION ALL
  SELECT * FROM base_2024
  UNION ALL
  SELECT * FROM base_2025
),
enriched AS (
  SELECT
    u.*,

    -- A) Normalized AI adoption category
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
  FROM unified u
)
SELECT * FROM enriched;

-- Optional: convenience table for Tableau extracts
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.combined_survey_all_years_tbl` AS
SELECT * FROM `ai-roi-analysis.marts.combined_survey_all_years`;
