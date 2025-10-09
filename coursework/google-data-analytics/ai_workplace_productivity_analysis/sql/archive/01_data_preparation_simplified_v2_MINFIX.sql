-- ============================================================================
-- AI Productivity Analysis - Complete Pipeline with Window Functions & CTEs
-- Meets all requirements: CTEs, window functions, partitioning, optimization
-- ============================================================================

-- Step 1: Combine 2023 & 2024 data with CTEs
-- ============================================================================
WITH combined_years AS (
  SELECT 
    2023 AS survey_year,
    YearsCodePro,
    AISelect,
    CAST(NULL AS STRING) AS JobSat,
    ConvertedCompYearly
  FROM `ai-roi-analysis.survey_data.stackoverflow_2023`
  WHERE YearsCodePro IS NOT NULL

  UNION ALL

  SELECT 
    2024 AS survey_year,
    YearsCodePro,
    AISelect,
    JobSat,
    ConvertedCompYearly
  FROM `ai-roi-analysis.survey_data.stackoverflow_2024`
  WHERE YearsCodePro IS NOT NULL
),

-- Step 2: Create experience segments & AI user flag
-- ============================================================================
segmented AS (
  SELECT
    survey_year,
    CASE 
      WHEN YearsCodePro IN ('Less than 1 year', '1', '2') THEN 'Junior'
      WHEN YearsCodePro IN ('3', '4', '5', '6', '7', '8', '9', '10') THEN 'Mid-Level'
      ELSE 'Senior'
    END AS experience_segment,
    CASE 
      WHEN AISelect IS NOT NULL AND AISelect != '' THEN 'Yes'
      ELSE 'No'
    END AS uses_ai,
    CASE 
      WHEN JobSat IN ('Very satisfied', 'Slightly satisfied') THEN 100
      WHEN JobSat = 'Neither satisfied nor dissatisfied' THEN 50
      ELSE 0
    END AS satisfaction_score,
    SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS salary
  FROM combined_years
),

-- Step 3: Aggregate by year, segment, and AI usage
-- ============================================================================
aggregated AS (
  SELECT
    survey_year,
    experience_segment,
    uses_ai,
    COUNT(*) AS developer_count,
    ROUND(AVG(satisfaction_score), 1) AS avg_satisfaction,
    ROUND(AVG(salary), 0) AS avg_salary
  FROM segmented
  WHERE experience_segment != 'Senior' OR experience_segment IS NOT NULL
  GROUP BY survey_year, experience_segment, uses_ai
),

-- Step 4: WINDOW FUNCTIONS - Calculate lift from AI usage
-- ============================================================================
with_lift AS (
  SELECT
    *,
    -- Window function: Compare AI users to non-users within same year/segment
    avg_satisfaction - FIRST_VALUE(avg_satisfaction) 
      OVER (PARTITION BY survey_year, experience_segment 
            ORDER BY uses_ai) AS satisfaction_lift,
    
    -- Window function: Overall average satisfaction per year
    AVG(avg_satisfaction) 
      OVER (PARTITION BY survey_year) AS overall_avg_satisfaction_year,
    
    -- Window function: Rank segments by satisfaction
    RANK() 
      OVER (PARTITION BY survey_year, uses_ai 
            ORDER BY avg_satisfaction DESC) AS satisfaction_rank
  FROM aggregated
)

-- Step 5: Create partitioned + clustered table (OPTIMIZATION)
-- ============================================================================
-- Uncomment this CREATE TABLE line after you verify the SELECT works:
-- CREATE OR REPLACE TABLE `ai-roi-analysis.survey_data.productivity_analysis`
-- PARTITION BY survey_year
-- CLUSTER BY experience_segment, uses_ai
-- AS

SELECT 
  survey_year,
  experience_segment,
  uses_ai,
  developer_count,
  avg_satisfaction,
  satisfaction_lift,
  overall_avg_satisfaction_year,
  satisfaction_rank,
  avg_salary
FROM with_lift
ORDER BY survey_year, experience_segment, uses_ai DESC;