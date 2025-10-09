# BigQuery Upload Instructions

## 📊 Cleaned Datasets Ready for Upload

The following files have been processed and are ready for BigQuery:


### 2023 Dataset
- **CSV File:** `2023_stackoverflow_cleaned.csv`
- **BigQuery Schema:** `2023_stackoverflow_bq_schema.json`
- **Legacy Schema:** `2023_stackoverflow_schema.json`
- **Rows:** 89,184 (from 89,184 original)
- **Columns:** 87 (cleaned from 84 original)
- **Encoding:** utf-8-sig
- **Salary Fields:** CompTotal, ConvertedCompYearly cleaned (outliers >1e9 removed)


### 2024 Dataset
- **CSV File:** `2024_stackoverflow_cleaned.csv`
- **BigQuery Schema:** `2024_stackoverflow_bq_schema.json`
- **Legacy Schema:** `2024_stackoverflow_schema.json`
- **Rows:** 65,437 (from 65,437 original)
- **Columns:** 117 (cleaned from 114 original)
- **Encoding:** utf-8-sig
- **Salary Fields:** CompTotal, ConvertedCompYearly cleaned (outliers >1e9 removed)


### 2025 Dataset
- **CSV File:** `2025_stackoverflow_cleaned.csv`
- **BigQuery Schema:** `2025_stackoverflow_bq_schema.json`
- **Legacy Schema:** `2025_stackoverflow_schema.json`
- **Rows:** 49,123 (from 49,123 original)
- **Columns:** 173 (cleaned from 170 original)
- **Encoding:** utf-8-sig
- **Salary Fields:** CompTotal, ConvertedCompYearly cleaned (outliers >1e9 removed)


## 🚀 BigQuery Upload Steps

### Option 1: Web UI Upload

1. **Go to BigQuery Console:** https://console.cloud.google.com/bigquery
2. **Create Dataset** (if needed):
   ```sql
   CREATE SCHEMA stackoverflow_survey
   OPTIONS(
     description="StackOverflow Developer Survey Data 2023-2025",
     location="US"
   );
   ```

3. **Upload Each Year:**
   - Click "Create Table"
   - Source: "Upload"
   - Select the CSV file (e.g., `2023_stackoverflow_cleaned.csv`)
   - Choose your dataset: `stackoverflow_survey`
   - Table name: `survey_2023` (or similar)
   - **Schema:** Click "Edit as text" and paste the contents of the schema JSON file
   - **⚠️ IMPORTANT:** Turn OFF "Auto detect schema and input parameters"
   - Advanced options:
     - Header rows to skip: 1
     - Field delimiter: Comma
     - Encoding: UTF-8

### Option 2: Command Line (bq tool)

```bash
# Load 2023 data
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --max_bad_records=0 \
  --autodetect=false \
  --schema=2023_stackoverflow_bq_schema.json \
  stackoverflow_survey.survey_2023 \
  2023_stackoverflow_cleaned.csv

# Load 2024 data
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --max_bad_records=0 \
  --autodetect=false \
  --schema=2024_stackoverflow_bq_schema.json \
  stackoverflow_survey.survey_2024 \
  2024_stackoverflow_cleaned.csv

# Load 2025 data
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --max_bad_records=0 \
  --autodetect=false \
  --schema=2025_stackoverflow_bq_schema.json \
  stackoverflow_survey.survey_2025 \
  2025_stackoverflow_cleaned.csv
```

### Option 3: Create Combined Table

```sql
-- Create a unified table with all years
CREATE TABLE stackoverflow_survey.survey_combined AS
SELECT *, 2023 as survey_year FROM stackoverflow_survey.survey_2023
UNION ALL
SELECT *, 2024 as survey_year FROM stackoverflow_survey.survey_2024
UNION ALL
SELECT *, 2025 as survey_year FROM stackoverflow_survey.survey_2025;
```

## 🔍 Test Your Upload

```sql
-- Check row counts
SELECT survey_year, COUNT(*) as row_count
FROM stackoverflow_survey.survey_combined
GROUP BY survey_year
ORDER BY survey_year;

-- Sample data check
SELECT survey_year, ResponseId, Age, DevType, AISelect
FROM stackoverflow_survey.survey_combined
WHERE ResponseId IS NOT NULL
LIMIT 10;
```

## ⚠️ Important Notes

- **Column names** have been cleaned for BigQuery compatibility
- **Original column mappings** are preserved in the schema descriptions
- **Encoding issues** have been resolved (BOM characters removed)
- **Empty rows** have been filtered out
- **Survey year** has been added as a column for easy filtering
- **Salary fields** (CompTotal, ConvertedCompYearly) now use FLOAT type to handle decimal values
- **JobSatPoints fields** (JobSatPoints_1, JobSatPoints_4, etc.) now use FLOAT type for decimal satisfaction scores
- **CSV quoting** has been improved with QUOTE_ALL to handle problematic text data

## 🔧 Troubleshooting

### Error: "column_name 'ResponseId' value 'ResponseId'"
This means BigQuery is reading the header row as data. **Solutions:**
1. **Command line:** Ensure you're using `--skip_leading_rows=1`
2. **Web UI:** Set "Header rows to skip" to 1 in Advanced options
3. **Critical:** Turn OFF autodetect (`--autodetect=false` or uncheck in UI)

### Error: "Invalid FLOAT value" or "Invalid INTEGER value"
1. Ensure CompTotal/ConvertedCompYearly are set to FLOAT type in schema
2. Use the `*_bq_schema.json` files (not the legacy `*_schema.json` files)
3. Check that `--max_bad_records=0` is set to catch parsing issues early

### Error: "Unable to parse; INTEGER value '37.5'" (JobSatPoints fields)
This error occurs when JobSatPoints fields are typed as INTEGER but contain decimal values:
1. **Root cause:** JobSatPoints_* fields contain satisfaction scores like "37.5", "12.5", "33.33"
2. **Solution:** All JobSatPoints_* fields should be FLOAT type in schema
3. **Fixed in:** Updated schemas automatically detect and set JobSatPoints as FLOAT

### Error: "CSV table references column position X, but line contains only Y columns"
This indicates malformed CSV rows with inconsistent column counts:
1. **Root cause:** Unescaped quotes, commas, or newlines in survey text responses
2. **Solution:** Use cleaned CSV files generated with QUOTE_ALL option
3. **Prevention:** Updated cleaning script now aggressively cleans problematic characters

### Load Command Template
```bash
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --max_bad_records=0 \
  --autodetect=false \
  --schema=YEAR_stackoverflow_bq_schema.json \
  YOUR_DATASET.YOUR_TABLE \
  YEAR_stackoverflow_cleaned.csv
```

## 🎯 Ready for Analysis!

Your data is now clean and ready for the analysis outlined in:
- `comprehensive_column_analysis.md` - EDA strategy
- `sql_column_reference.sql` - Ready-to-use queries

Happy analyzing! 🚀
