-- 06_tableau_ready_table.sql
-- Creates ONE ultra-condensed table for Tableau baseline dashboard
-- Everything pre-processed, minimal columns, zero calculated fields needed in Tableau
-- Run AFTER baseline_view_10082025.sql

-- =============================================================================
-- THE ONE TABLE YOU NEED
-- =============================================================================

CREATE OR REPLACE TABLE `ai-roi-analysis.marts.tableau_baseline` AS
SELECT
  -- === IDENTIFIERS (for row-level detail if needed) ===
  ResponseId,
  survey_year AS Year,
  
  -- === GEOGRAPHY (region, not country - no explosion) ===
  COALESCE(Region, 'Other/Unknown') AS Region,
  
  -- === AI ADOPTION (clean categories, ready for filters) ===
  COALESCE(ai_use_category, 'Unknown') AS AI_Usage,
  ai_adopt_flag AS Is_AI_Adopter,  -- 1/0 for easy SUM() in Tableau
  
  -- === SENTIMENT (clean categories) ===
  COALESCE(sentiment_clean, 'Unknown') AS AI_Sentiment,
  pos_sent_flag AS Is_Positive_Sentiment,  -- 1/0 for easy SUM()
  
  -- === EXPERIENCE (bucketed & cleaned) ===
  COALESCE(exp_bucket, 'Unknown') AS Experience_Level,
  CASE 
    WHEN YearsCode IS NULL THEN NULL
    WHEN YearsCode < 0 THEN NULL
    WHEN YearsCode > 50 THEN 50
    ELSE ROUND(YearsCode, 1)
  END AS Years_Coding,
  
  -- === COMPENSATION (cleaned, outliers removed) ===
  CASE 
    WHEN ConvertedCompYearly IS NULL THEN NULL
    WHEN ConvertedCompYearly <= 0 THEN NULL
    WHEN ConvertedCompYearly > 10000000 THEN NULL  -- Remove absurd outliers
    ELSE ROUND(ConvertedCompYearly, 0)
  END AS Annual_Salary_USD,
  
  -- === LANGUAGE FLAGS (for language charts - no multi-select explosion!) ===
  CASE WHEN LanguageHaveWorkedWith LIKE '%Python%' THEN 1 ELSE 0 END AS Uses_Python,
  CASE WHEN LanguageHaveWorkedWith LIKE '%JavaScript%' THEN 1 ELSE 0 END AS Uses_JavaScript,
  CASE WHEN LanguageHaveWorkedWith LIKE '%TypeScript%' THEN 1 ELSE 0 END AS Uses_TypeScript,
  CASE WHEN LanguageHaveWorkedWith LIKE '%Java%' AND LanguageHaveWorkedWith NOT LIKE '%JavaScript%' THEN 1 ELSE 0 END AS Uses_Java,
  CASE WHEN LanguageHaveWorkedWith LIKE '%SQL%' THEN 1 ELSE 0 END AS Uses_SQL,
  CASE WHEN LanguageHaveWorkedWith LIKE '%C#%' THEN 1 ELSE 0 END AS Uses_CSharp,
  CASE WHEN LanguageHaveWorkedWith LIKE '%Go%' THEN 1 ELSE 0 END AS Uses_Go,
  CASE WHEN LanguageHaveWorkedWith LIKE '%Rust%' THEN 1 ELSE 0 END AS Uses_Rust,
  CASE WHEN LanguageHaveWorkedWith LIKE '%Ruby%' THEN 1 ELSE 0 END AS Uses_Ruby,
  CASE WHEN LanguageHaveWorkedWith LIKE '%PHP%' THEN 1 ELSE 0 END AS Uses_PHP,
  
  -- === OPTIONAL: Demographics (if you want them for extra slicing) ===
  COALESCE(NULLIF(TRIM(Employment), ''), 'Unknown') AS Employment_Status,
  COALESCE(NULLIF(TRIM(RemoteWork), ''), 'Unknown') AS Remote_Work,
  COALESCE(NULLIF(TRIM(OrgSize), ''), 'Unknown') AS Organization_Size

FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE 
  ResponseId IS NOT NULL
  -- Remove clearly invalid data
  AND NOT (ConvertedCompYearly > 10000000)
  AND NOT (WorkExp > 100);


-- =============================================================================
-- VERIFICATION: Check the table
-- =============================================================================

-- Row counts by year
SELECT 
  Year,
  COUNT(*) AS Total_Rows,
  COUNT(DISTINCT Region) AS Unique_Regions,
  COUNTIF(Is_AI_Adopter = 1) AS AI_Adopters,
  ROUND(AVG(Is_AI_Adopter) * 100, 1) AS Adoption_Rate_Pct
FROM `ai-roi-analysis.marts.tableau_baseline`
GROUP BY Year
ORDER BY Year;

-- Check for problematic NULLs (should be minimal)
SELECT
  COUNTIF(Region = 'Other/Unknown') AS unknown_region,
  COUNTIF(AI_Usage = 'Unknown') AS unknown_ai_usage,
  COUNTIF(AI_Sentiment = 'Unknown') AS unknown_sentiment,
  COUNTIF(Experience_Level = 'Unknown') AS unknown_experience,
  COUNTIF(Annual_Salary_USD IS NULL) AS null_salary,
  COUNT(*) AS total_rows
FROM `ai-roi-analysis.marts.tableau_baseline`;

-- Sample the data
SELECT * 
FROM `ai-roi-analysis.marts.tableau_baseline`
LIMIT 100;
