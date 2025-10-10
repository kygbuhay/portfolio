-- 00_data_summary.sql (BigQuery) - CONSOLIDATED & SAVED
-- Project:  call-resolution-data
-- Dataset:  call_center_data
-- Table:    repeat_calls_all_markets
-- Purpose:  Outputs a single, comprehensive summary table for the target dataset.

-- This single query profiles the table's schema, checks for expected columns,
-- and calculates summary statistics for key date, categorical, and numeric columns.

-- By adding this line, the results will be saved to a new table.
CREATE OR REPLACE TABLE `call-resolution-data.call_center_data.data_summary` AS

WITH
  -- Step 1: Calculate aggregate stats over the entire table.
  -- These will be joined to every row of the final output.
  OverallStats AS (
    SELECT
      COUNT(*) AS total_row_count,
      MIN(CAST(date_created AS DATE)) AS min_date,
      MAX(CAST(date_created AS DATE)) AS max_date,
      COUNT(DISTINCT market) AS distinct_markets,
      COUNT(DISTINCT problem_type) AS distinct_problem_types
    FROM
      `call-resolution-data.call_center_data.repeat_calls_all_markets`
  ),

  -- Step 2: Unpivot and calculate stats for all numeric 'contacts_n' columns.
  -- This creates a summary for each numeric column that we can join back to.
  NumericStats AS (
    WITH
      unpivoted_data AS (
        SELECT
          contact_type,
          contact_value
        FROM
          `call-resolution-data.call_center_data.repeat_calls_all_markets`,
          UNNEST(
            [
              STRUCT('contacts_n' AS contact_type, SAFE_CAST(contacts_n AS INT64) AS contact_value),
              STRUCT('contacts_n_1' AS contact_type, SAFE_CAST(contacts_n_1 AS INT64) AS contact_value),
              STRUCT('contacts_n_2' AS contact_type, SAFE_CAST(contacts_n_2 AS INT64) AS contact_value),
              STRUCT('contacts_n_3' AS contact_type, SAFE_CAST(contacts_n_3 AS INT64) AS contact_value),
              STRUCT('contacts_n_4' AS contact_type, SAFE_CAST(contacts_n_4 AS INT64) AS contact_value),
              STRUCT('contacts_n_5' AS contact_type, SAFE_CAST(contacts_n_5 AS INT64) AS contact_value),
              STRUCT('contacts_n_6' AS contact_type, SAFE_CAST(contacts_n_6 AS INT64) AS contact_value),
              STRUCT('contacts_n_7' AS contact_type, SAFE_CAST(contacts_n_7 AS INT64) AS contact_value)
            ]
          )
      )
    SELECT
      contact_type,
      COUNTIF(contact_value IS NULL) AS null_count,
      COUNTIF(contact_value < 0) AS negatives,
      MIN(contact_value) AS min_val,
      MAX(contact_value) AS max_val,
      ROUND(AVG(contact_value), 2) AS avg_val
    FROM
      unpivoted_data
    GROUP BY
      contact_type
  ),

  -- Step 3: Define the list of columns expected by downstream scripts.
  ExpectedColumns AS (
    SELECT 'date_created' AS column_name UNION ALL
    SELECT 'market' UNION ALL
    SELECT 'problem_type' UNION ALL
    SELECT 'contacts_n' UNION ALL
    SELECT 'contacts_n_1' UNION ALL
    SELECT 'contacts_n_2' UNION ALL
    SELECT 'contacts_n_3' UNION ALL
    SELECT 'contacts_n_4' UNION ALL
    SELECT 'contacts_n_5' UNION ALL
    SELECT 'contacts_n_6' UNION ALL
    SELECT 'contacts_n_7'
  ),
  
  -- Step 4: Get the base schema information for all columns.
  SchemaInfo AS (
      SELECT
        ordinal_position,
        column_name,
        data_type,
        is_nullable
      FROM
        `call-resolution-data.call_center_data.INFORMATION_SCHEMA.COLUMNS`
      WHERE
        table_name = 'repeat_calls_all_markets'
  )

-- Final Step: Join all the prepared CTEs to build the final summary table.
SELECT
  s.ordinal_position,
  s.column_name,
  s.data_type,
  CASE
    WHEN e.column_name IS NOT NULL THEN 'OK'
    ELSE 'MISSING'
  END AS expected_column_status,
  
  -- Build a dynamic summary string based on the column type.
  CASE
    WHEN s.column_name = 'date_created' THEN CONCAT('Range: ', CAST(o.min_date AS STRING), ' to ', CAST(o.max_date AS STRING))
    WHEN s.column_name = 'market' THEN CONCAT(CAST(o.distinct_markets AS STRING), ' distinct values')
    WHEN s.column_name = 'problem_type' THEN CONCAT(CAST(o.distinct_problem_types AS STRING), ' distinct values')
    WHEN n.contact_type IS NOT NULL THEN 
        CONCAT(
            'Nulls: ', CAST(n.null_count AS STRING), 
            ', Negatives: ', CAST(n.negatives AS STRING),
            ', Min: ', CAST(n.min_val AS STRING),
            ', Max: ', CAST(n.max_val AS STRING),
            ', Avg: ', CAST(n.avg_val AS STRING)
        )
    ELSE NULL
  END AS summary_statistic

FROM SchemaInfo AS s
CROSS JOIN OverallStats AS o -- Cross join as there is only one row of overall stats.
LEFT JOIN NumericStats AS n ON s.column_name = n.contact_type
LEFT JOIN ExpectedColumns AS e ON s.column_name = e.column_name
ORDER BY
  s.ordinal_position;
