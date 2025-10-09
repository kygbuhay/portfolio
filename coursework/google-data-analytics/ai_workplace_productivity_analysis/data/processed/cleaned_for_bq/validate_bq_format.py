#!/usr/bin/env python3
"""
Validate CSV and Schema Format for BigQuery Compatibility
"""

import json
import pandas as pd
from pathlib import Path

def validate_csv_and_schema(year: int):
    """Validate a CSV and its corresponding BigQuery schema."""

    base_path = Path(".")
    csv_file = base_path / f"{year}_stackoverflow_cleaned.csv"
    schema_file = base_path / f"{year}_stackoverflow_bq_schema.json"

    print(f"\n📊 Validating {year} Dataset")
    print(f"CSV: {csv_file}")
    print(f"Schema: {schema_file}")

    # Check files exist
    if not csv_file.exists():
        print(f"❌ CSV file not found: {csv_file}")
        return False

    if not schema_file.exists():
        print(f"❌ Schema file not found: {schema_file}")
        return False

    # Load schema
    with open(schema_file, 'r') as f:
        schema = json.load(f)

    # Load CSV header
    df_sample = pd.read_csv(csv_file, nrows=5)

    # Check schema format
    if isinstance(schema, list):
        print("✅ Schema format: Top-level array (BigQuery compatible)")
        schema_fields = schema
    elif isinstance(schema, dict) and 'schema' in schema:
        print("⚠️ Schema format: Wrapped in 'schema' object (use *_bq_schema.json)")
        return False
    else:
        print("❌ Invalid schema format")
        return False

    # Check column count
    csv_columns = len(df_sample.columns)
    schema_columns = len(schema_fields)

    if csv_columns == schema_columns:
        print(f"✅ Column count matches: {csv_columns}")
    else:
        print(f"❌ Column count mismatch: CSV={csv_columns}, Schema={schema_columns}")
        return False

    # Check column names
    csv_col_names = df_sample.columns.tolist()
    schema_col_names = [field['name'] for field in schema_fields]

    mismatched_columns = []
    for i, (csv_col, schema_col) in enumerate(zip(csv_col_names, schema_col_names)):
        if csv_col != schema_col:
            mismatched_columns.append(f"Position {i}: CSV='{csv_col}' vs Schema='{schema_col}'")

    if not mismatched_columns:
        print("✅ All column names match between CSV and schema")
    else:
        print("❌ Column name mismatches:")
        for mismatch in mismatched_columns[:5]:  # Show first 5
            print(f"   {mismatch}")
        return False

    # Check salary field types
    salary_fields = ['CompTotal', 'ConvertedCompYearly']
    for field in schema_fields:
        if field['name'] in salary_fields:
            if field['type'] == 'FLOAT':
                print(f"✅ {field['name']}: FLOAT type (correct for decimal values)")
            else:
                print(f"❌ {field['name']}: {field['type']} type (should be FLOAT)")
                return False

    # Check ResponseId type
    response_id_field = next((f for f in schema_fields if f['name'] == 'ResponseId'), None)
    if response_id_field:
        if response_id_field['type'] in ['INTEGER', 'INT64']:
            print(f"✅ ResponseId: {response_id_field['type']} type")
        else:
            print(f"⚠️ ResponseId: {response_id_field['type']} type (unusual)")

    # Sample data validation
    print(f"✅ CSV sample data:")
    for col in salary_fields:
        if col in df_sample.columns:
            sample_values = df_sample[col].dropna().head(3).tolist()
            print(f"   {col}: {sample_values}")

    print(f"✅ Dataset {year} is ready for BigQuery!")
    return True

def main():
    """Validate all datasets."""
    print("🔍 BigQuery Format Validation")
    print("=" * 50)

    all_valid = True
    for year in [2023, 2024, 2025]:
        try:
            if not validate_csv_and_schema(year):
                all_valid = False
        except Exception as e:
            print(f"❌ Error validating {year}: {e}")
            all_valid = False

    print("\n" + "=" * 50)
    if all_valid:
        print("🎉 All datasets are valid and ready for BigQuery!")
        print("\nRecommended load command:")
        print("bq load --source_format=CSV --skip_leading_rows=1 --max_bad_records=0 --autodetect=false --schema=YEAR_stackoverflow_bq_schema.json YOUR_DATASET.YOUR_TABLE YEAR_stackoverflow_cleaned.csv")
    else:
        print("❌ Some datasets have issues. Please fix before loading to BigQuery.")

if __name__ == "__main__":
    main()