-- 03_productivity_analysis.sql

-- Adoption by region/year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_ai_adoption_by_region_year` AS
SELECT
  survey_year,
  Region,
  AVG(ai_adopt_flag) AS adoption_rate,
  COUNT(*) AS n
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, Region;

-- Median comp by AI use
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_median_comp_by_aiuse` AS
SELECT
  survey_year,
  ai_use_category,
  APPROX_QUANTILES(ConvertedCompYearly, 2)[OFFSET(1)] AS median_comp_usd
FROM `ai-roi-analysis.marts.combined_survey_all_years`
WHERE ConvertedCompYearly IS NOT NULL AND ConvertedCompYearly > 0
GROUP BY survey_year, ai_use_category;

-- Experience buckets
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_experience_buckets` AS
SELECT
  survey_year,
  exp_bucket,
  COUNT(*) AS respondents
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, exp_bucket;

-- Sentiment by region/year
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_sentiment_by_region_year` AS
SELECT
  survey_year,
  Region,
  sentiment_clean,
  COUNT(*) AS n
FROM `ai-roi-analysis.marts.combined_survey_all_years`
GROUP BY survey_year, Region, sentiment_clean;

-- Multiselect splitter (languages, etc.)
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.msplits` AS
WITH src AS (
  SELECT survey_year, ResponseId, 'LanguageHaveWorkedWith' AS src_col, LanguageHaveWorkedWith AS list FROM `ai-roi-analysis.marts.combined_survey_all_years`
  UNION ALL
  SELECT survey_year, ResponseId, 'LanguageWantToWorkWith' AS src_col, LanguageWantToWorkWith AS list FROM `ai-roi-analysis.marts.combined_survey_all_years`
),
split AS (
  SELECT
    survey_year,
    ResponseId,
    src_col,
    TRIM(item) AS item
  FROM src,
  UNNEST(SPLIT(COALESCE(list, ''), ';')) AS item
)
SELECT * FROM split
WHERE item IS NOT NULL AND item != '' AND LOWER(item) != 'nan';

-- Top languages by distinct users
CREATE OR REPLACE VIEW `ai-roi-analysis.marts.kpi_top_languages` AS
SELECT
  survey_year,
  src_col,
  item,
  COUNT(DISTINCT ResponseId) AS users
FROM `ai-roi-analysis.marts.msplits`
WHERE src_col IN ('LanguageHaveWorkedWith', 'LanguageWantToWorkWith')
  AND item IS NOT NULL
  AND item != ''
  AND item != 'nan'
GROUP BY survey_year, src_col, item;

