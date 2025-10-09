-- 06_tableau_ready_table.sql
-- Creates a Tableau-optimized materialized table
-- Fixes: NULLs, multi-selects, column explosion, data types
-- Run AFTER 01-05 scripts

-- =============================================================================
-- PART 1: Clean Respondent-Level Table (for filtering/drilling)
-- =============================================================================

CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_respondent_clean` AS
SELECT
  -- Keys
  ResponseId,
  survey_year,
  
  -- Core Demographics (NULL-safe)
  COALESCE(NULLIF(TRIM(Country), ''), 'Unknown') AS Country,
  COALESCE(Region, 'Unknown') AS Region,
  COALESCE(NULLIF(TRIM(Age), ''), 'Unknown') AS Age,
  COALESCE(exp_bucket, 'Unknown') AS ExperienceBucket,
  COALESCE(NULLIF(TRIM(EdLevel), ''), 'Unknown') AS EducationLevel,
  COALESCE(NULLIF(TRIM(Employment), ''), 'Unknown') AS EmploymentStatus,
  COALESCE(NULLIF(TRIM(RemoteWork), ''), 'Unknown') AS RemoteWork,
  COALESCE(NULLIF(TRIM(OrgSize), ''), 'Unknown') AS OrgSize,
  COALESCE(NULLIF(TRIM(Industry), ''), 'Unknown') AS Industry,
  
  -- AI Adoption (clean categories)
  COALESCE(ai_use_category, 'Unknown') AS AI_Usage,
  ai_adopt_flag AS AI_Adopter,  -- 1/0 flag
  
  -- Sentiment (clean categories)  
  COALESCE(sentiment_clean, 'Unknown') AS AI_Sentiment,
  pos_sent_flag AS Positive_Sentiment,  -- 1/0 flag
  
  -- Compensation (cleaned)
  CASE 
    WHEN ConvertedCompYearly IS NULL THEN NULL
    WHEN ConvertedCompYearly <= 0 THEN NULL
    WHEN ConvertedCompYearly > 10000000 THEN NULL  -- Remove outliers >10M
    ELSE ROUND(ConvertedCompYearly, 0)
  END AS AnnualCompensation_USD,
  
  -- Experience (cleaned)
  CASE 
    WHEN WorkExp IS NULL THEN NULL
    WHEN WorkExp < 0 THEN NULL
    WHEN WorkExp > 50 THEN 50  -- Cap at 50
    ELSE ROUND(WorkExp, 1)
  END AS YearsWorkExperience,
  
  CASE 
    WHEN YearsCode IS NULL THEN NULL
    WHEN YearsCode < 0 THEN NULL
    WHEN YearsCode > 50 THEN 50  -- Cap at 50
    ELSE ROUND(YearsCode, 1)
  END AS YearsCoding,
  
  -- Primary Dev Type (simplified - take first value from semicolon list)
  COALESCE(
    NULLIF(TRIM(SPLIT(DevType, ';')[SAFE_OFFSET(0)]), ''),
    'Unknown'
  ) AS PrimaryDevType,
  
  -- Primary Language (simplified - take first value from semicolon list)
  COALESCE(
    NULLIF(TRIM(SPLIT(LanguageHaveWorkedWith, ';')[SAFE_OFFSET(0)]), ''),
    'Unknown'
  ) AS PrimaryLanguage,
  
  -- Flags for common languages (for easy filtering in Tableau)
  CASE WHEN LanguageHaveWorkedWith LIKE '%Python%' THEN 1 ELSE 0 END AS Uses_Python,
  CASE WHEN LanguageHaveWorkedWith LIKE '%JavaScript%' THEN 1 ELSE 0 END AS Uses_JavaScript,
  CASE WHEN LanguageHaveWorkedWith LIKE '%TypeScript%' THEN 1 ELSE 0 END AS Uses_TypeScript,
  CASE WHEN LanguageHaveWorkedWith LIKE '%Java%' AND LanguageHaveWorkedWith NOT LIKE '%JavaScript%' THEN 1 ELSE 0 END AS Uses_Java,
  CASE WHEN LanguageHaveWorkedWith LIKE '%SQL%' THEN 1 ELSE 0 END AS Uses_SQL,
  CASE WHEN LanguageHaveWorkedWith LIKE '%C#%' THEN 1 ELSE 0 END AS Uses_CSharp,
  
  -- Count of languages (for sophistication metric)
  ARRAY_LENGTH(SPLIT(COALESCE(LanguageHaveWorkedWith, ''), ';')) AS LanguageCount

FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE 
  ResponseId IS NOT NULL
  -- Exclude clearly invalid responses
  AND NOT (ConvertedCompYearly > 10000000)  -- No absurd salaries
  AND NOT (WorkExp > 100);  -- No 100+ year careers


-- =============================================================================
-- PART 2: Pre-Aggregated Stats Tables (for KPI scorecards)
-- =============================================================================

-- KPI: AI Adoption by Year & Region
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_kpi_adoption` AS
SELECT
  survey_year AS Year,
  Region,
  COUNT(*) AS Total_Respondents,
  COUNTIF(AI_Adopter = 1) AS AI_Adopters,
  ROUND(COUNTIF(AI_Adopter = 1) / COUNT(*) * 100, 1) AS Adoption_Rate_Pct
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
GROUP BY survey_year, Region
ORDER BY survey_year, Region;


-- KPI: Compensation by AI Usage & Experience
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_kpi_compensation` AS
SELECT
  survey_year AS Year,
  AI_Usage,
  ExperienceBucket,
  COUNT(*) AS Respondents,
  ROUND(AVG(AnnualCompensation_USD), 0) AS Avg_Compensation,
  ROUND(APPROX_QUANTILES(AnnualCompensation_USD, 100)[OFFSET(50)], 0) AS Median_Compensation,
  ROUND(APPROX_QUANTILES(AnnualCompensation_USD, 100)[OFFSET(25)], 0) AS P25_Compensation,
  ROUND(APPROX_QUANTILES(AnnualCompensation_USD, 100)[OFFSET(75)], 0) AS P75_Compensation
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
WHERE AnnualCompensation_USD IS NOT NULL
  AND AnnualCompensation_USD > 0
GROUP BY survey_year, AI_Usage, ExperienceBucket
HAVING Respondents >= 10  -- Only include groups with 10+ respondents
ORDER BY survey_year, AI_Usage, ExperienceBucket;


-- KPI: Sentiment Distribution
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_kpi_sentiment` AS
SELECT
  survey_year AS Year,
  Region,
  AI_Sentiment,
  COUNT(*) AS Respondents,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY survey_year, Region) * 100, 1) AS Pct_of_Region
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
GROUP BY survey_year, Region, AI_Sentiment
ORDER BY survey_year, Region, AI_Sentiment;


-- KPI: Experience Distribution by AI Adoption
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_kpi_experience` AS
SELECT
  survey_year AS Year,
  ExperienceBucket,
  AI_Usage,
  COUNT(*) AS Respondents,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY survey_year, ExperienceBucket) * 100, 1) AS Pct_of_Bucket
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
GROUP BY survey_year, ExperienceBucket, AI_Usage
ORDER BY survey_year, 
  CASE ExperienceBucket
    WHEN '0-1' THEN 1
    WHEN '2-4' THEN 2
    WHEN '5-9' THEN 3
    WHEN '10-19' THEN 4
    WHEN '20+' THEN 5
    ELSE 6
  END,
  AI_Usage;


-- KPI: Top Languages (simplified - no explosion)
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_kpi_languages` AS
WITH lang_flags AS (
  SELECT
    survey_year,
    AI_Usage,
    SUM(Uses_Python) AS Python_Users,
    SUM(Uses_JavaScript) AS JavaScript_Users,
    SUM(Uses_TypeScript) AS TypeScript_Users,
    SUM(Uses_Java) AS Java_Users,
    SUM(Uses_SQL) AS SQL_Users,
    SUM(Uses_CSharp) AS CSharp_Users,
    COUNT(*) AS Total_Respondents
  FROM `ai-roi-analysis.marts.tableau_respondent_clean`
  GROUP BY survey_year, AI_Usage
)
SELECT 
  survey_year AS Year,
  AI_Usage,
  'Python' AS Language,
  Python_Users AS Users,
  ROUND(Python_Users / Total_Respondents * 100, 1) AS Pct_Users
FROM lang_flags
UNION ALL
SELECT survey_year, AI_Usage, 'JavaScript', JavaScript_Users, ROUND(JavaScript_Users / Total_Respondents * 100, 1) FROM lang_flags
UNION ALL
SELECT survey_year, AI_Usage, 'TypeScript', TypeScript_Users, ROUND(TypeScript_Users / Total_Respondents * 100, 1) FROM lang_flags
UNION ALL
SELECT survey_year, AI_Usage, 'Java', Java_Users, ROUND(Java_Users / Total_Respondents * 100, 1) FROM lang_flags
UNION ALL
SELECT survey_year, AI_Usage, 'SQL', SQL_Users, ROUND(SQL_Users / Total_Respondents * 100, 1) FROM lang_flags
UNION ALL
SELECT survey_year, AI_Usage, 'C#', CSharp_Users, ROUND(CSharp_Users / Total_Respondents * 100, 1) FROM lang_flags
ORDER BY Year, AI_Usage, Users DESC;


-- =============================================================================
-- PART 3: Single "Master" Table for General Exploration (Optional)
-- =============================================================================
-- This combines respondent data with key aggregates for maximum flexibility

CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_master` AS
WITH region_stats AS (
  SELECT 
    survey_year,
    Region,
    AVG(AnnualCompensation_USD) AS region_avg_comp,
    APPROX_QUANTILES(AnnualCompensation_USD, 100)[OFFSET(50)] AS region_median_comp
  FROM `ai-roi-analysis.marts.tableau_respondent_clean`
  WHERE AnnualCompensation_USD IS NOT NULL
  GROUP BY survey_year, Region
),
exp_stats AS (
  SELECT
    survey_year,
    ExperienceBucket,
    AVG(AnnualCompensation_USD) AS exp_avg_comp,
    APPROX_QUANTILES(AnnualCompensation_USD, 100)[OFFSET(50)] AS exp_median_comp
  FROM `ai-roi-analysis.marts.tableau_respondent_clean`
  WHERE AnnualCompensation_USD IS NOT NULL
  GROUP BY survey_year, ExperienceBucket
)
SELECT
  r.*,
  -- Add region aggregates (for LOD expression comparisons)
  ROUND(rs.region_avg_comp, 0) AS Region_Avg_Compensation,
  ROUND(rs.region_median_comp, 0) AS Region_Median_Compensation,
  -- Add experience bucket aggregates (for LOD expression comparisons)
  ROUND(es.exp_avg_comp, 0) AS Experience_Avg_Compensation,
  ROUND(es.exp_median_comp, 0) AS Experience_Median_Compensation,
  -- Calculate deltas (for quick insights)
  CASE 
    WHEN r.AnnualCompensation_USD IS NOT NULL AND rs.region_median_comp IS NOT NULL
    THEN ROUND((r.AnnualCompensation_USD - rs.region_median_comp) / rs.region_median_comp * 100, 1)
    ELSE NULL
  END AS Pct_Above_Region_Median,
  CASE 
    WHEN r.AnnualCompensation_USD IS NOT NULL AND es.exp_median_comp IS NOT NULL
    THEN ROUND((r.AnnualCompensation_USD - es.exp_median_comp) / es.exp_median_comp * 100, 1)
    ELSE NULL
  END AS Pct_Above_Experience_Median
FROM `ai-roi-analysis.marts.tableau_respondent_clean` r
LEFT JOIN region_stats rs 
  ON r.survey_year = rs.survey_year 
  AND r.Region = rs.Region
LEFT JOIN exp_stats es
  ON r.survey_year = es.survey_year 
  AND r.ExperienceBucket = es.ExperienceBucket;


-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Check record counts
SELECT 
  'tableau_respondent_clean' AS table_name,
  COUNT(*) AS row_count,
  COUNT(DISTINCT survey_year) AS years,
  COUNT(DISTINCT Region) AS regions
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
UNION ALL
SELECT 
  'tableau_master' AS table_name,
  COUNT(*) AS row_count,
  COUNT(DISTINCT survey_year) AS years,
  COUNT(DISTINCT Region) AS regions
FROM `ai-roi-analysis.marts.tableau_master`;

-- Check for NULLs in key dimensions (should be minimal)
SELECT
  COUNTIF(Region = 'Unknown') AS unknown_region,
  COUNTIF(AI_Usage = 'Unknown') AS unknown_ai_usage,
  COUNTIF(AI_Sentiment = 'Unknown') AS unknown_sentiment,
  COUNTIF(ExperienceBucket = 'Unknown') AS unknown_experience,
  COUNTIF(AnnualCompensation_USD IS NULL) AS null_compensation,
  COUNT(*) AS total_rows
FROM `ai-roi-analysis.marts.tableau_respondent_clean`;

-- Show sample data
SELECT * 
FROM `ai-roi-analysis.marts.tableau_respondent_clean`
LIMIT 100;
