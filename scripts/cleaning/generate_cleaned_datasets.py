#!/usr/bin/env python3
"""
Clean and Process CSV Files for BigQuery Upload

Creates cleaned versions of the raw CSV files and generates BigQuery-compatible
schema files for easy upload and analysis.

Outputs:
- data/processed/{year}_stackoverflow_cleaned.csv
- data/processed/{year}_stackoverflow_schema.json
"""

import json
import argparse
import pandas as pd
from pathlib import Path
from typing import Dict, List, Any, Optional
import re

def clean_csv_for_bigquery(file_path: str, year: int, output_dir: Path) -> Dict[str, Any]:
    """Clean a CSV file and prepare it for BigQuery upload."""

    print(f"\n🔧 Processing {year} dataset...")

    # Try multiple encodings like our inventory script does
    encodings_to_try = ['utf-8-sig', 'utf-8', 'latin-1', 'cp1252']
    df = None
    encoding_used = None

    for encoding in encodings_to_try:
        try:
            df = pd.read_csv(
                file_path,
                encoding=encoding,
                dtype=str,  # Load everything as string initially
                on_bad_lines='skip',
                engine='python',  # More robust parsing
                quotechar='"',
                doublequote=True,
                skipinitialspace=True
            )
            encoding_used = encoding
            print(f"  ✅ Loaded with {encoding} encoding")
            break
        except Exception as e:
            continue

    if df is None:
        raise ValueError(f"Could not read {file_path} with any encoding")

    # Clean BOM from column names if present
    if len(df.columns) > 0 and df.columns[0].startswith('\ufeff'):
        df.columns = [df.columns[0].lstrip('\ufeff')] + list(df.columns[1:])

    original_rows = len(df)

    # 1. Clean column names for BigQuery compatibility
    cleaned_columns = {}
    for col in df.columns:
        # BigQuery column name rules:
        # - Must start with letter or underscore
        # - Can contain letters, numbers, underscores
        # - Max 128 characters
        clean_col = re.sub(r'[^a-zA-Z0-9_]', '_', col)
        clean_col = re.sub(r'^([0-9])', r'col_\1', clean_col)  # Prefix numbers
        clean_col = re.sub(r'_+', '_', clean_col)  # Collapse multiple underscores
        clean_col = clean_col.strip('_')  # Remove leading/trailing underscores
        clean_col = clean_col[:128]  # Truncate if too long

        # Handle duplicates
        counter = 1
        original_clean = clean_col
        while clean_col in cleaned_columns.values():
            clean_col = f"{original_clean}_{counter}"
            counter += 1

        cleaned_columns[col] = clean_col

    # Rename columns
    df = df.rename(columns=cleaned_columns)
    print(f"  📝 Cleaned {len(cleaned_columns)} column names for BigQuery")

    # 2. Remove completely empty rows
    df = df.dropna(how='all')
    empty_rows_removed = original_rows - len(df)
    if empty_rows_removed > 0:
        print(f"  🗑️ Removed {empty_rows_removed} completely empty rows")

    # 3. Clean salary fields for BigQuery compatibility
    salary_fields = ['CompTotal', 'ConvertedCompYearly']
    for col in salary_fields:
        if col in df.columns:
            print(f"  💰 Cleaning salary field: {col}")
            # Convert to numeric, handling scientific notation and extreme values
            numeric_series = pd.to_numeric(df[col], errors='coerce')

            # Set extreme outliers (>1e9) to null
            numeric_series = numeric_series.where(numeric_series <= 1e9)

            # Convert back to string for CSV export, preserving null as empty
            df[col] = numeric_series.astype(str).replace('nan', '')

            outliers_removed = (pd.to_numeric(df[col], errors='coerce') > 1e9).sum()
            if outliers_removed > 0:
                print(f"    ⚠️ Removed {outliers_removed} extreme outliers (>1e9) from {col}")

    # 4. Clean problematic characters that might cause CSV issues
    for col in df.columns:
        if col not in ['survey_year', 'processing_timestamp', 'source_encoding']:
            # Aggressive text cleaning to prevent CSV parsing issues
            df[col] = df[col].astype(str)
            df[col] = df[col].str.replace('\x00', '', regex=False)
            df[col] = df[col].str.replace('\r\n', ' ', regex=False)
            df[col] = df[col].str.replace('\r', ' ', regex=False)
            df[col] = df[col].str.replace('\n', ' ', regex=False)
            df[col] = df[col].str.replace('"', "'", regex=False)  # Replace quotes
            df[col] = df[col].replace(['nan', 'NaN', 'NULL', 'null'], '')

    # 5. Add metadata columns
    df['survey_year'] = year
    df['processing_timestamp'] = pd.Timestamp.now().isoformat()
    df['source_encoding'] = encoding_used

    # 6. Save cleaned CSV with robust quoting
    output_file = output_dir / f"{year}_stackoverflow_cleaned.csv"

    # Use csv module for proper quoting to handle problematic text
    import csv
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_ALL, escapechar='\\')

        # Write header
        writer.writerow(df.columns.tolist())

        # Write data row by row
        for _, row in df.iterrows():
            writer.writerow([str(val) if pd.notna(val) else '' for val in row])

    print(f"  💾 Saved cleaned CSV: {output_file}")
    print(f"    📊 CSV uses QUOTE_ALL for robust parsing - use --skip_leading_rows=1 for BigQuery")

    return {
        'year': year,
        'output_file': str(output_file),
        'original_rows': original_rows,
        'cleaned_rows': len(df),
        'original_columns': len(cleaned_columns),
        'final_columns': len(df.columns),
        'encoding_used': encoding_used,
        'column_mapping': cleaned_columns,
        'dataframe': df  # For schema generation
    }

def infer_bigquery_type(series: pd.Series, column_name: str) -> Dict[str, Any]:
    """Infer BigQuery-compatible data type from pandas series."""

    # Convert to string and get non-null values for analysis
    non_null_values = series.dropna().astype(str)
    non_null_values = non_null_values[non_null_values != '']

    if len(non_null_values) == 0:
        return {
            'name': column_name,
            'type': 'STRING',
            'mode': 'NULLABLE',
            'description': f'Column {column_name} (all null values)'
        }

    sample_values = non_null_values.head(1000)  # Sample for performance

    # Special handling for salary fields
    if column_name in ['CompTotal', 'ConvertedCompYearly']:
        return {
            'name': column_name,
            'type': 'FLOAT',
            'mode': 'NULLABLE',
            'description': f'Salary field: {column_name} (cleaned, outliers >1e9 removed)'
        }

    # Special handling for JobSatPoints fields (they contain decimals)
    if column_name.startswith('JobSatPoints_'):
        return {
            'name': column_name,
            'type': 'FLOAT',
            'mode': 'NULLABLE',
            'description': f'Job satisfaction points: {column_name} (decimal values)'
        }

    # Special handling for ResponseId - should be INTEGER for BigQuery
    if column_name == 'ResponseId':
        return {
            'name': column_name,
            'type': 'INTEGER',
            'mode': 'NULLABLE',
            'description': f'Response ID: {column_name}'
        }

    # Try to identify the type
    # 1. Check for integers
    try:
        pd.to_numeric(sample_values, errors='raise').astype(int)
        return {
            'name': column_name,
            'type': 'INTEGER',
            'mode': 'NULLABLE',
            'description': f'Integer column: {column_name}'
        }
    except (ValueError, OverflowError):
        pass

    # 2. Check for floats
    try:
        numeric_vals = pd.to_numeric(sample_values, errors='raise')
        if not all(numeric_vals.apply(lambda x: x.is_integer())):
            return {
                'name': column_name,
                'type': 'FLOAT',
                'mode': 'NULLABLE',
                'description': f'Float column: {column_name}'
            }
    except (ValueError, OverflowError):
        pass

    # 3. Check for booleans
    bool_values = {'true', 'false', 'yes', 'no', '1', '0', 'y', 'n'}
    unique_lower = set(sample_values.str.lower().unique())
    if unique_lower.issubset(bool_values) and len(unique_lower) <= 4:
        return {
            'name': column_name,
            'type': 'BOOLEAN',
            'mode': 'NULLABLE',
            'description': f'Boolean column: {column_name}'
        }

    # 4. Check for dates
    date_patterns = [
        r'^\d{4}-\d{2}-\d{2}$',  # YYYY-MM-DD
        r'^\d{1,2}[/-]\d{1,2}[/-]\d{2,4}$',  # MM/DD/YYYY or MM-DD-YYYY
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}',  # ISO datetime
    ]

    for pattern in date_patterns:
        if sample_values.str.match(pattern).mean() > 0.7:
            return {
                'name': column_name,
                'type': 'TIMESTAMP',
                'mode': 'NULLABLE',
                'description': f'Timestamp column: {column_name}'
            }

    # 5. Default to STRING
    return {
        'name': column_name,
        'type': 'STRING',
        'mode': 'NULLABLE',
        'description': f'String column: {column_name}'
    }

def generate_bigquery_schema(df: pd.DataFrame, year: int, output_dir: Path,
                           column_mapping: Dict[str, str]) -> str:
    """Generate BigQuery schema JSON file."""

    print(f"  📋 Generating BigQuery schema for {year}...")

    schema_fields = []

    for col in df.columns:
        field_info = infer_bigquery_type(df[col], col)

        # Add original column name in description if it was changed
        original_name = None
        for orig, clean in column_mapping.items():
            if clean == col:
                original_name = orig
                break

        if original_name and original_name != col:
            field_info['description'] += f' (originally: {original_name})'

        schema_fields.append(field_info)

    # Save BigQuery-compatible schema (top-level array)
    schema_file = output_dir / f"{year}_stackoverflow_bq_schema.json"
    with open(schema_file, 'w', encoding='utf-8') as f:
        json.dump(schema_fields, f, indent=2)

    print(f"  📄 Saved BigQuery schema: {schema_file}")
    print(f"    🎯 Schema format: top-level array (BigQuery compatible)")

    # Also save the old format for reference
    legacy_schema = {
        'schema': {
            'fields': schema_fields
        },
        'metadata': {
            'year': year,
            'total_fields': len(schema_fields),
            'generated_timestamp': pd.Timestamp.now().isoformat(),
            'source': f'{year}_stackoverflow_cleaned.csv',
            'table_description': f'StackOverflow Developer Survey {year} - Cleaned and processed for analysis'
        }
    }

    legacy_schema_file = output_dir / f"{year}_stackoverflow_schema.json"
    with open(legacy_schema_file, 'w', encoding='utf-8') as f:
        json.dump(legacy_schema, f, indent=2)

    return str(schema_file)

def create_upload_instructions(output_dir: Path, results: List[Dict]) -> None:
    """Create instructions for BigQuery upload."""

    instructions_file = output_dir / "BIGQUERY_UPLOAD_INSTRUCTIONS.md"

    md_content = """# BigQuery Upload Instructions

## 📊 Cleaned Datasets Ready for Upload

The following files have been processed and are ready for BigQuery:

"""

    for result in results:
        year = result['year']
        md_content += f"""
### {year} Dataset
- **CSV File:** `{year}_stackoverflow_cleaned.csv`
- **BigQuery Schema:** `{year}_stackoverflow_bq_schema.json`
- **Legacy Schema:** `{year}_stackoverflow_schema.json`
- **Rows:** {result['cleaned_rows']:,} (from {result['original_rows']:,} original)
- **Columns:** {result['final_columns']} (cleaned from {result['original_columns']} original)
- **Encoding:** {result['encoding_used']}
- **Salary Fields:** CompTotal, ConvertedCompYearly cleaned (outliers >1e9 removed)

"""

    md_content += """
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
   - Advanced options:
     - Header rows to skip: 1
     - Field delimiter: Comma
     - Encoding: UTF-8

### Option 2: Command Line (bq tool)

```bash
# Load 2023 data
bq load \\
  --source_format=CSV \\
  --skip_leading_rows=1 \\
  --max_bad_records=0 \\
  --schema=2023_stackoverflow_bq_schema.json \\
  stackoverflow_survey.survey_2023 \\
  2023_stackoverflow_cleaned.csv

# Load 2024 data
bq load \\
  --source_format=CSV \\
  --skip_leading_rows=1 \\
  --max_bad_records=0 \\
  --schema=2024_stackoverflow_bq_schema.json \\
  stackoverflow_survey.survey_2024 \\
  2024_stackoverflow_cleaned.csv

# Load 2025 data
bq load \\
  --source_format=CSV \\
  --skip_leading_rows=1 \\
  --max_bad_records=0 \\
  --schema=2025_stackoverflow_bq_schema.json \\
  stackoverflow_survey.survey_2025 \\
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

## 🎯 Ready for Analysis!

Your data is now clean and ready for the analysis outlined in:
- `comprehensive_column_analysis.md` - EDA strategy
- `sql_column_reference.sql` - Ready-to-use queries

Happy analyzing! 🚀
"""

    with open(instructions_file, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"\n📋 Created upload instructions: {instructions_file}")

def main():
    parser = argparse.ArgumentParser(description="Clean CSV files and generate BigQuery schemas")
    parser.add_argument('--raw-dir', type=str,
                       default='../../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/raw',
                       help='Directory containing raw CSV files')
    parser.add_argument('--output-dir', type=str,
                       default='../../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/processed',
                       help='Output directory for cleaned files')
    args = parser.parse_args()

    raw_dir = Path(args.raw_dir)
    output_dir = Path(args.output_dir)

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"📁 Output directory: {output_dir}")

    # Process each year
    years_and_files = [
        (2023, raw_dir / 'stackoverflow_2023.csv'),
        (2024, raw_dir / 'stackoverflow_2024.csv'),
        (2025, raw_dir / 'stackoverflow_2025.csv')
    ]

    results = []

    for year, file_path in years_and_files:
        if not file_path.exists():
            print(f"⚠️ Skipping {year}: {file_path} not found")
            continue

        try:
            result = clean_csv_for_bigquery(str(file_path), year, output_dir)

            # Generate schema
            schema_file = generate_bigquery_schema(
                result['dataframe'],
                year,
                output_dir,
                result['column_mapping']
            )
            result['schema_file'] = schema_file

            # Remove dataframe from result (too large to keep)
            del result['dataframe']
            results.append(result)

            print(f"  ✅ {year} processing complete")

        except Exception as e:
            print(f"  ❌ Error processing {year}: {str(e)}")
            continue

    # Create upload instructions
    if results:
        create_upload_instructions(output_dir, results)

    # Summary
    print(f"\n🎉 Processing Complete!")
    print(f"   Processed {len(results)} datasets")
    print(f"   Output location: {output_dir}")
    print(f"   Ready for BigQuery upload! 🚀")

    return 0

if __name__ == '__main__':
    exit(main())