-- 05_bigqueryml_model.sql
-- Trains a baseline logistic regression to predict AI adoption.
-- Requires the combined view to exist.

CREATE OR REPLACE MODEL `ai-roi-analysis.marts.adoption_lr`
OPTIONS(model_type='logistic_reg',
        input_label_cols=['ai_adopt_flag'],
        auto_class_weights=TRUE)
AS
SELECT
  ai_adopt_flag,
  survey_year,
  SAFE_CAST(WorkExp AS FLOAT64) AS work_years,
  SAFE_CAST(YearsCode AS FLOAT64) AS years_coding,
  CASE WHEN Region IS NULL THEN 'Unknown' ELSE Region END AS region,
  CASE WHEN sentiment_clean IS NULL THEN 'Unknown' ELSE sentiment_clean END AS sentiment_clean
FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE ai_adopt_flag IS NOT NULL;

-- Example evaluation
CREATE OR REPLACE TABLE `ai-roi-analysis.marts.adoption_lr_eval` AS
SELECT *
FROM ML.EVALUATE(MODEL `ai-roi-analysis.marts.adoption_lr`);
