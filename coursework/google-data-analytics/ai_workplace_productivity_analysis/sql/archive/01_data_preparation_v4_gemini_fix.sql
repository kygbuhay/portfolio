WITH
  combined_years AS (
    SELECT
      2023 AS survey_year,
      YearsCodePro,
      AISelect,
      CAST(NULL AS STRING) AS JobSat,
      ConvertedCompYearly
    FROM
      `ai-roi-analysis`.survey_data.stackoverflow_2023
    WHERE
      YearsCodePro IS NOT NULL
    UNION ALL
    SELECT
      2024 AS survey_year,
      YearsCodePro,
      AISelect,
      JobSat,
      ConvertedCompYearly
    FROM
      `ai-roi-analysis`.survey_data.stackoverflow_2024
    WHERE
      YearsCodePro IS NOT NULL
  ),
  segmented AS (
    SELECT
      survey_year,
      CASE
        WHEN YearsCodePro IN ('Less than 1 year', '1', '2') THEN 'Junior'
        WHEN YearsCodePro IN ('3', '4', '5', '6', '7', '8', '9', '10') THEN 'Mid-Level'
        ELSE 'Senior'
      END AS experience_segment,
      CASE
        WHEN AISelect = 'Yes' THEN 'Yes'
        WHEN AISelect IN ('No, and I don' 't plan to', 'No, but I plan to soon', 'NA') THEN 'No'
        ELSE NULL
      END AS uses_ai,
      CASE
        WHEN JobSat = 'Very favorable' THEN 100
        WHEN JobSat = 'Favorable' THEN 75
        WHEN JobSat = 'Indifferent' THEN 50
        WHEN JobSat = 'Unfavorable' THEN 25
        WHEN JobSat = 'Very poor at handling complex tasks' THEN 0
        WHEN JobSat = 'NA' THEN NULL
        WHEN JobSat IS NULL THEN NULL
        ELSE NULL
      END AS satisfaction_score,
      SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS salary
    FROM
      combined_years
  ),
  aggregated AS (
    SELECT
      survey_year,
      experience_segment,
      uses_ai,
      COUNT(*) AS developer_count,
      ROUND(AVG(satisfaction_score), 1) AS avg_satisfaction,
      ROUND(AVG(salary), 0) AS avg_salary
    FROM
      segmented
    WHERE
      experience_segment IS NOT NULL AND uses_ai IS NOT NULL
    GROUP BY survey_year, experience_segment, uses_ai
  ),
  with_lift AS (
    SELECT
      *,
      avg_satisfaction - LAG(avg_satisfaction) OVER (PARTITION BY survey_year, experience_segment
        ORDER BY uses_ai DESC) AS satisfaction_lift,
      AVG(avg_satisfaction) OVER (PARTITION BY survey_year) AS overall_avg_satisfaction_year,
      RANK() OVER (PARTITION BY survey_year, uses_ai
        ORDER BY avg_satisfaction DESC) AS satisfaction_rank
    FROM
      aggregated
  )
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
FROM
  with_lift
ORDER BY survey_year, experience_segment, uses_ai DESC;
