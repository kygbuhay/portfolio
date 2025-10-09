-- 04_roi_framework.sql
-- Lightweight ROI inputs derived from combined survey. Adjust assumptions as needed.

CREATE OR REPLACE VIEW `ai-roi-analysis.marts.roi_inputs` AS
SELECT
  survey_year,
  ResponseId,
  ai_use_category,
  ai_adopt_flag,
  sentiment_clean,
  pos_sent_flag,
  Region,
  Country,
  COALESCE(NULLIF(CAST(Industry AS STRING), ''), 'Unknown') AS Industry,
  COALESCE(NULLIF(CAST(ICorPM AS STRING), ''), 'Unknown') AS RoleType,
  SAFE_CAST(ConvertedCompYearly AS FLOAT64) AS yearly_comp_usd,
  -- Estimated hourly rate (work-year 2,000 hours)
  CASE WHEN SAFE_CAST(ConvertedCompYearly AS FLOAT64) IS NOT NULL
       THEN SAFE_CAST(ConvertedCompYearly AS FLOAT64) / 2000.0
       ELSE NULL END AS est_hourly_rate_usd
FROM `ai-roi-analysis.marts.combined_survey_all_years`;

-- Example ROI rollup (median comp by adoption & sentiment)
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.roi_rollup_example` AS
SELECT
  survey_year,
  ai_use_category,
  sentiment_clean,
  APPROX_QUANTILES(yearly_comp_usd, 2)[OFFSET(1)] AS median_comp_usd,
  COUNT(*) AS n
FROM `ai-roi-analysis.marts.roi_inputs`
WHERE yearly_comp_usd IS NOT NULL AND yearly_comp_usd > 0
GROUP BY survey_year, ai_use_category, sentiment_clean;

