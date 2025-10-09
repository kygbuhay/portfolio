-- 01_data_preparation.sql
-- Creates schema and region mapper UDF. Run first.
-- Safe to re-run (idempotent).

-- Dataset (mart) for analysis artifacts
CREATE SCHEMA IF NOT EXISTS `ai-roi-analysis.marts`
OPTIONS(
  description="Mart views for AI workplace productivity analysis",
  location="US"
);

-- Permanent UDF: Region mapper (call with `ai-roi-analysis.marts`.region_for_country)
CREATE OR REPLACE FUNCTION `ai-roi-analysis.marts.region_for_country`(country STRING)
RETURNS STRING
AS (CASE
    WHEN country IS NULL OR TRIM(country) = '' THEN 'Other/Unknown'
    -- Americas
    WHEN LOWER(country) IN (
      'united states','usa','us','canada','mexico'
    ) THEN 'North America'
    WHEN LOWER(country) IN (
      'colombia','venezuela','ecuador','peru','bolivia','chile','argentina','uruguay','paraguay','brazil',
      'cuba','dominican republic','haiti','puerto rico','jamaica','trinidad and tobago','bahamas','barbados'
    ) THEN 'Latin America & Caribbean'
    -- Europe
    WHEN LOWER(country) IN (
      'united kingdom','england','scotland','wales','northern ireland','ireland','germany','france','italy',
      'spain','portugal','netherlands','belgium','sweden','norway','denmark','finland','iceland',
      'switzerland','austria','poland','czechia','czech republic','slovakia','hungary','romania','bulgaria',
      'greece','croatia','slovenia','serbia','bosnia and herzegovina','north macedonia','albania',
      'estonia','latvia','lithuania','ukraine','moldova'
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
    WHEN LOWER(country) IN ('india','pakistan','bangladesh','sri lanka','nepal','bhutan','maldives','afghanistan') THEN 'South Asia'
    -- East Asia & Pacific
    WHEN LOWER(country) IN (
      'china','taiwan','hong kong','japan','south korea','korea, south','north korea','mongolia',
      'singapore','malaysia','thailand','vietnam','cambodia','laos','myanmar','philippines','indonesia','brunei',
      'australia','new zealand','papua new guinea','fiji'
    ) THEN 'East Asia & Pacific'
    ELSE 'Other/Unknown'
  END);
