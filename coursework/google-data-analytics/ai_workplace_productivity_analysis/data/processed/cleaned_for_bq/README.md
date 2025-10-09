# AI Workplace Productivity Analysis - Processed Data

## 📊 Overview

This directory contains cleaned and processed StackOverflow Developer Survey data (2023-2025) ready for BigQuery analysis. All datasets have been successfully loaded into BigQuery dataset: `ai-roi-analysis:survey_data`.

## 📁 Directory Contents

### ✅ Final Cleaned Datasets
- `2023_stackoverflow_cleaned.csv` - 89,184 rows, 87 columns
- `2024_stackoverflow_cleaned.csv` - 65,437 rows, 117 columns
- `2025_stackoverflow_cleaned.csv` - 49,122 rows, 173 columns

### 🗂️ BigQuery Schemas
- `2023_stackoverflow_bq_schema.json` - BigQuery-compatible schema (top-level array)
- `2024_stackoverflow_bq_schema.json` - BigQuery-compatible schema (top-level array)
- `2025_stackoverflow_bq_schema.json` - BigQuery-compatible schema (top-level array)

### 📋 Legacy Schemas (Reference Only)
- `2023_stackoverflow_schema.json` - Legacy wrapped format
- `2024_stackoverflow_schema.json` - Legacy wrapped format
- `2025_stackoverflow_schema.json` - Legacy wrapped format

### 📖 Documentation
- `BIGQUERY_UPLOAD_INSTRUCTIONS.md` - Complete upload guide with troubleshooting
- `validate_bq_format.py` - Validation script for CSV/schema compatibility

## 🔧 Processing Applied

### Data Quality Fixes
1. **Column Name Cleaning**: BigQuery-compatible naming (alphanumeric + underscores)
2. **Encoding Issues**: Removed BOM characters, standardized to UTF-8
3. **Empty Row Removal**: Filtered out completely empty rows
4. **Text Cleaning**: Removed null bytes, embedded newlines, problematic quotes
5. **CSV Quoting**: Applied QUOTE_ALL to handle complex text fields

### Schema Corrections
1. **Salary Fields**: `CompTotal`, `ConvertedCompYearly` → FLOAT (was INTEGER)
2. **JobSatPoints Fields**: `JobSatPoints_*` → FLOAT (was INTEGER)
3. **ResponseId**: INTEGER type for proper indexing
4. **Metadata Addition**: `survey_year`, `processing_timestamp`, `source_encoding`

### Data Type Issues Resolved
- **Issue**: JobSatPoints fields contained decimals (37.5, 12.5) but were typed as INTEGER
- **Solution**: Auto-detect and set JobSatPoints_* fields to FLOAT type
- **Issue**: 2025 CSV had malformed rows with inconsistent column counts
- **Solution**: Aggressive text cleaning + QUOTE_ALL CSV format

## 🚀 BigQuery Status

All datasets successfully loaded into `ai-roi-analysis:survey_data`:

```sql
-- Verify table status
SELECT
  table_name,
  row_count,
  size_bytes / 1024 / 1024 as size_mb
FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.TABLES`
WHERE table_type = 'BASE TABLE'
ORDER BY table_name;
```

### Load Commands Used
```bash
# 2023 Dataset
bq load --source_format=CSV --skip_leading_rows=1 --max_bad_records=0 --autodetect=false --schema=2023_stackoverflow_bq_schema.json survey_data.2023_stackoverflow_cleaned 2023_stackoverflow_cleaned.csv

# 2024 Dataset
bq load --replace --source_format=CSV --skip_leading_rows=1 --max_bad_records=0 --autodetect=false --schema=2024_stackoverflow_bq_schema.json survey_data.2024_stackoverflow_cleaned 2024_stackoverflow_cleaned.csv

# 2025 Dataset
bq load --source_format=CSV --skip_leading_rows=1 --max_bad_records=0 --autodetect=false --schema=2025_stackoverflow_bq_schema.json survey_data.2025_stackoverflow_cleaned 2025_stackoverflow_cleaned.csv
```

## 🔍 Validation

Run the validation script to verify data integrity:

```bash
python3 validate_bq_format.py
```

Expected output: ✅ All datasets are valid and ready for BigQuery!

## 📈 Analysis Ready

The data is now ready for comprehensive analysis including:
- AI tool adoption trends (2023-2025)
- Developer productivity metrics
- Salary analysis by technology stack
- Job satisfaction correlations
- Cross-year trend analysis

## 🛠️ Regenerating Data

To regenerate the cleaned datasets (if needed):

```bash
cd ../../../scripts/cleaning
python3 generate_cleaned_datasets.py
```

The updated script includes all the fixes discovered during BigQuery upload:
- Robust CSV parsing for problematic text data
- JobSatPoints field type detection
- QUOTE_ALL CSV output format
- Aggressive text cleaning

## ⚠️ Important Notes

- **Use `*_bq_schema.json` files** for BigQuery uploads (not legacy schemas)
- **CSV format**: Uses QUOTE_ALL for robust parsing
- **Column counts**: Verified consistent across all rows
- **BigQuery compatibility**: All field types tested and validated

---

✨ **Status**: All datasets successfully processed and loaded into BigQuery!
🗓️ **Last Updated**: October 8, 2025
👤 **Processed by**: Claude Code AI Assistant