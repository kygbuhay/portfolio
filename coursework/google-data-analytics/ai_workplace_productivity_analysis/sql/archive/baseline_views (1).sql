-- ============================================================================
-- AI Productivity ROI Analysis - Baseline Views (All Years Intersection) - CLEAN
-- Date: 2025-10-08
-- Notes:
--   - Uses cleaned tables: 2023_stackoverflow_cleaned, 2024_stackoverflow_cleaned, 2025_stackoverflow_cleaned
--   - Keeps the 27-ish shared columns seen across years (casts for consistency)
--   - Adds Region via a simple country→region mapper (TEMP FUNCTION)
--   - Creates a unified view, an exploded multi-select view, and a materialized table for Tableau
-- ============================================================================

-- 0) Create marts dataset if it doesn't exist
CREATE SCHEMA IF NOT EXISTS `ai-roi-analysis.marts`
OPTIONS(
  description="Mart views for AI workplace productivity analysis",
  location="US"
);

-- --------- REGION MAPPER (TEMP FUNCTION) ----------
CREATE TEMP FUNCTION region_for_country(country STRING)
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
    WHEN LOWER(country) IN ('india','pakistan','bangladesh','sri lanka','nepal','bhutan','maldives','afghanistan')
      THEN 'South Asia'
    -- East Asia & Pacific
    WHEN LOWER(country) IN (
      'china','taiwan','hong kong','japan','south korea','korea, south','north korea','mongolia',
      'singapore','malaysia','thailand','vietnam','cambodia','laos','myanmar','philippines','indonesia','brunei',
      'australia','new zealand','papua new guinea','fiji'
    ) THEN 'East Asia & Pacific'
    ELSE 'Other/Unknown'
  END
);
-- --------- /REGION MAPPER ----------

-- 1) Unified view with harmonized schema across 2023, 2024, 2025
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
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(JobSat AS STRING) AS JobSat,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(MiscTechHaveWorkedWith AS STRING) AS MiscTechHaveWorkedWith,
    CAST(MiscTechWantToWorkWith AS STRING) AS MiscTechWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(WorkExp AS FLOAT64)
    END AS WorkExp,
    CASE
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(YearsCode AS FLOAT64)
    END AS YearsCode,
    COALESCE(region_for_country(Country), 'Other/Unknown') AS Region
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
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(JobSat AS STRING) AS JobSat,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(MiscTechHaveWorkedWith AS STRING) AS MiscTechHaveWorkedWith,
    CAST(MiscTechWantToWorkWith AS STRING) AS MiscTechWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(WorkExp AS FLOAT64)
    END AS WorkExp,
    CASE
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(YearsCode AS FLOAT64)
    END AS YearsCode,
    COALESCE(region_for_country(Country), 'Other/Unknown') AS Region
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
    CAST(Currency AS STRING) AS Currency,
    CAST(DatabaseHaveWorkedWith AS STRING) AS DatabaseHaveWorkedWith,
    CAST(DatabaseWantToWorkWith AS STRING) AS DatabaseWantToWorkWith,
    CAST(DevType AS STRING) AS DevType,
    CAST(EdLevel AS STRING) AS EdLevel,
    CAST(Employment AS STRING) AS Employment,
    CAST(ICorPM AS STRING) AS ICorPM,
    CAST(JobSat AS STRING) AS JobSat,
    CAST(LanguageHaveWorkedWith AS STRING) AS LanguageHaveWorkedWith,
    CAST(LanguageWantToWorkWith AS STRING) AS LanguageWantToWorkWith,
    CAST(MiscTechHaveWorkedWith AS STRING) AS MiscTechHaveWorkedWith,
    CAST(MiscTechWantToWorkWith AS STRING) AS MiscTechWantToWorkWith,
    CAST(OpSysPersonal_use AS STRING) AS OpSysPersonal_use,
    CAST(OpSysProfessional_use AS STRING) AS OpSysProfessional_use,
    CAST(OrgSize AS STRING) AS OrgSize,
    CAST(RemoteWork AS STRING) AS RemoteWork,
    CAST(SOPartFreq AS STRING) AS SOPartFreq,
    CAST(SOVisitFreq AS STRING) AS SOVisitFreq,
    CAST(WebframeHaveWorkedWith AS STRING) AS WebframeHaveWorkedWith,
    CAST(WebframeWantToWorkWith AS STRING) AS WebframeWantToWorkWith,
    CASE
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(WorkExp AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(WorkExp AS FLOAT64)
    END AS WorkExp,
    CASE
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*less\s+than') THEN 0.5
      WHEN REGEXP_CONTAINS(CAST(YearsCode AS STRING), r'(?i)^\s*more\s+than') THEN 50
      ELSE SAFE_CAST(YearsCode AS FLOAT64)
    END AS YearsCode,
    COALESCE(region_for_country(Country), 'Other/Unknown') AS Region
  FROM `ai-roi-analysis.survey_data.2025_stackoverflow_cleaned`
)
SELECT * FROM base_2023
UNION ALL
SELECT * FROM base_2024
UNION ALL
SELECT * FROM base_2025
;

-- 2) Exploded multi-select view (for Tableau-friendly filters/aggregations)
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.combined_msplits` AS
WITH base AS (
  SELECT * FROM `ai-roi-analysis.marts.combined_survey_all_years`
),
ai_split AS (
  SELECT b.*, TRIM(x) AS AI_tool
  FROM base b, UNNEST(SPLIT(IFNULL(b.AISelect,''), ';')) AS x
),
devtype_split AS (
  SELECT b.*, TRIM(y) AS DevType_item
  FROM base b, UNNEST(SPLIT(IFNULL(b.DevType,''), ';')) AS y
)
SELECT
  survey_year, ResponseId, Country, Region, Employment, EdLevel, OrgSize, RemoteWork,
  YearsCode, WorkExp, ConvertedCompYearly, JobSat,
  AI_tool, DevType_item, AISelect, DevType, AISent, AIAcc
FROM ai_split
LEFT JOIN devtype_split USING (survey_year, ResponseId);

-- 3) Convenience table for Tableau extracts (optional materialization)
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.combined_survey_all_years_tbl` AS
SELECT * FROM `ai-roi-analysis.marts.combined_survey_all_years`;
