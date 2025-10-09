-- =============================================================================
-- AI ROI ANALYSIS: 2023-2024 ONLY (Working Version)
-- =============================================================================

CREATE OR REPLACE TABLE `ai-roi-analysis.survey_data.ai_adoption_analysis` AS

WITH combined_data AS (
  -- 2023 Data
  SELECT 
    2023 AS survey_year,
    ResponseId,
    YearsCodePro,
    CASE 
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) < 2 THEN 'Junior'
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) BETWEEN 2 AND 5 THEN 'Mid-Level'
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) > 5 THEN 'Senior'
      ELSE 'Unknown'
    END AS experience_level
  FROM `ai-roi-analysis.survey_data.stackoverflow_2023`
  WHERE YearsCodePro IS NOT NULL
  
  UNION ALL
  
  -- 2024 Data  
  SELECT 
    2024 AS survey_year,
    ResponseId,
    YearsCodePro,
    CASE 
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) < 2 THEN 'Junior'
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) BETWEEN 2 AND 5 THEN 'Mid-Level'
      WHEN SAFE_CAST(YearsCodePro AS FLOAT64) > 5 THEN 'Senior'
      ELSE 'Unknown'
    END AS experience_level
  FROM `ai-roi-analysis.survey_data.stackoverflow_2024`
  WHERE YearsCodePro IS NOT NULL
)

SELECT 
  survey_year,
  experience_level,
  COUNT(*) AS developer_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY survey_year), 1) AS pct_of_year
FROM combined_data
WHERE experience_level != 'Unknown'
GROUP BY survey_year, experience_level
ORDER BY survey_year, experience_level;