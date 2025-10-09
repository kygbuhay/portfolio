-- ============================================================================
-- AI Productivity Analysis - Complete Pipeline with Window Functions & CTEs
-- Minimal Fixes applied to v2: uses_ai parsing & JobSat handling; stable lift
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

-- Step 2: Create experience segments & AI user flag  (MIN FIX #1 & #2)
--  - uses_ai: parse "yes/no" semantics instead of "any text = yes"
--  - satisfaction_score: NULL when JobSat missing (2023) so AVG ignores it
-- ============================================================================
segmented AS (
  SELECT
    survey_year,
    CASE 
      WHEN YearsCodePro IN ('Less than 1 year', '1', '2') THEN 'Junior'
      WHEN YearsCodePro IN ('3','4','5','6','7','8','9','10') THEN 'Mid-Level'
      ELSE 'Senior'
    END AS experience_segment,

    CASE
      WHEN AISelect IS NULL OR TRIM(AISelect) = '' THEN NULL
      WHEN REGEXP_CONTAINS(LOWER(AISelect), r'(yes|use|currently)') THEN 'Yes'
      WHEN REGEXP_CONTAINS(LOWER(AISelect), r'(no|do not|don’t|dont|none)') THEN 'No'
      ELSE NULL
    END AS uses_ai,

    CASE 
      WHEN JobSat IS NULL THEN NULL
      WHEN JobSat IN ('Very satisfied','Slightly satisfied') THEN 100
      WHEN JobSat = 'Neither satisfied nor dissatisfied' THEN 50
      WHEN JobSat IN ('Slightly dissatisfied','Very dissatisfied') THEN 0
      ELSE NULL
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
  WHERE experience_segment IS NOT NULL
  GROUP BY survey_year, experience_segment, uses_ai
),

-- Step 4: WINDOW FUNCTIONS - Calculate lift from AI usage (MIN FIX #3)
--  - compute baseline explicitly from non-users to avoid ORDER BY pitfalls
-- ============================================================================
with_lift AS (
  SELECT
    a.*,
    AVG(CASE WHEN uses_ai = 'No' THEN avg_satisfaction END)
      OVER (PARTITION BY survey_year, experience_segment) AS nonuser_avg_satisfaction,

    CASE
      WHEN uses_ai = 'Yes' AND
           AVG(CASE WHEN uses_ai = 'No' THEN avg_satisfaction END)
             OVER (PARTITION BY survey_year, experience_segment) IS NOT NULL
      THEN avg_satisfaction -
           AVG(CASE WHEN uses_ai = 'No' THEN avg_satisfaction END)
             OVER (PARTITION BY survey_year, experience_segment)
      ELSE NULL
    END AS satisfaction_lift,

    AVG(avg_satisfaction) OVER (PARTITION BY survey_year) AS overall_avg_satisfaction_year,

    RANK() OVER (PARTITION BY survey_year, uses_ai ORDER BY avg_satisfaction DESC) AS satisfaction_rank
  FROM aggregated a
)

-- Step 5: (optional) Create partitioned + clustered table
-- Uncomment after verifying the SELECT:
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
