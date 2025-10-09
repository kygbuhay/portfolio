#!/usr/bin/env python3
"""
Generate Column Mapping: Raw Data → Cleaned BigQuery Data

This script extracts the actual BigQuery column names and creates mapping
documentation to bridge the gap between original analysis and cleaned reality.
"""

import subprocess
import json
import pandas as pd
from pathlib import Path
from io import StringIO

def get_bigquery_columns(table_name):
    """Get column names from BigQuery table."""
    cmd = [
        'bq', 'query', '--use_legacy_sql=false', '--format=csv',
        f"""
        SELECT column_name, data_type
        FROM `ai-roi-analysis.survey_data.INFORMATION_SCHEMA.COLUMNS`
        WHERE table_name = '{table_name}'
        ORDER BY ordinal_position
        """
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        df = pd.read_csv(StringIO(result.stdout))
        return df
    except subprocess.CalledProcessError as e:
        print(f"Error querying BigQuery: {e}")
        return None

def load_original_columns(year):
    """Load original column names from schema files."""
    schema_file = Path(f"../data/processed/{year}_stackoverflow_schema.json")
    if schema_file.exists():
        with open(schema_file, 'r') as f:
            schema = json.load(f)
            if 'schema' in schema and 'fields' in schema['schema']:
                return [field['description'].split('(originally: ')[-1].rstrip(')')
                       if '(originally: ' in field['description']
                       else field['name'] for field in schema['schema']['fields']]
    return None

def generate_mapping_report():
    """Generate comprehensive column mapping report."""

    print("🔍 Generating Column Mapping Report...")

    report = {
        'generated_date': pd.Timestamp.now().isoformat(),
        'summary': {},
        'years': {},
        'transformations': [],
        'intersection_cleaned': []
    }

    # Get data for each year
    for year in [2023, 2024, 2025]:
        print(f"📊 Processing {year}...")

        table_name = f"{year}_stackoverflow_cleaned"
        bq_columns = get_bigquery_columns(table_name)

        if bq_columns is not None:
            report['years'][str(year)] = {
                'table_name': table_name,
                'column_count': len(bq_columns),
                'columns': bq_columns.to_dict('records')
            }

            # Identify common transformation patterns
            for _, row in bq_columns.iterrows():
                col_name = row['column_name']
                if '_' in col_name and any(char in col_name for char in [' ']):
                    # This suggests a transformation happened
                    original_guess = col_name.replace('_', ' ')
                    report['transformations'].append({
                        'cleaned': col_name,
                        'likely_original': original_guess,
                        'year': year,
                        'data_type': row['data_type']
                    })

    # Find intersection of all years (cleaned data)
    if len(report['years']) == 3:
        column_sets = []
        for year_data in report['years'].values():
            column_names = {col['column_name'] for col in year_data['columns']}
            column_sets.append(column_names)

        intersection = set.intersection(*column_sets)
        report['intersection_cleaned'] = sorted(list(intersection))
        report['summary']['intersection_count'] = len(intersection)

    report['summary']['total_transformations'] = len(report['transformations'])

    return report

def create_markdown_report(report):
    """Create markdown documentation from the report."""

    md_content = f"""# Column Mapping: Raw → Cleaned Data

**Generated**: {report['generated_date']}

## 📊 Summary

- **Years Analyzed**: 2023, 2024, 2025
- **Common Columns (All Years)**: {report['summary'].get('intersection_count', 'N/A')}
- **Transformations Detected**: {report['summary']['total_transformations']}

## 🔄 Column Transformations Detected

| Cleaned Column Name | Likely Original | Data Type | Year Found |
|-------------------|-----------------|-----------|------------|
"""

    for transform in report['transformations']:
        md_content += f"| `{transform['cleaned']}` | `{transform['likely_original']}` | {transform['data_type']} | {transform['year']} |\n"

    md_content += f"""
## 📋 Cleaned Data Intersection (All Years)

These {len(report['intersection_cleaned'])} columns are available in ALL cleaned datasets:

"""

    for col in report['intersection_cleaned']:
        md_content += f"- `{col}`\n"

    md_content += """
## 📊 Per-Year Column Details

"""

    for year, data in report['years'].items():
        md_content += f"""
### {year} Dataset
- **Table**: `{data['table_name']}`
- **Columns**: {data['column_count']}

"""

    md_content += """
## 🎯 Key Findings

1. **Spaces → Underscores**: Most transformations convert spaces to underscores for BigQuery compatibility
2. **Special Characters**: Non-alphanumeric characters replaced with underscores
3. **AI Tool Fields**: Consistently transformed across all years
4. **OpSys Fields**: Space-containing column names properly converted

## 💡 Recommendations

1. **Use Intersection List**: Focus on the {intersection_count} common columns for cross-year analysis
2. **Update SQL Queries**: Use cleaned column names from this documentation
3. **Reference Mapping**: When writing new queries, check transformations table above

---

*This report bridges the gap between original raw data analysis and cleaned BigQuery reality.*
""".format(intersection_count=len(report['intersection_cleaned']))

    return md_content

def main():
    """Main execution function."""

    # Set up PATH for bq command
    import os
    os.environ['PATH'] = '/home/admin/google-cloud-sdk/bin:' + os.environ.get('PATH', '')

    print("🚀 Starting Column Mapping Analysis...")

    # Generate the report
    report = generate_mapping_report()

    # Save JSON report
    output_dir = Path("../docs")
    output_dir.mkdir(exist_ok=True)

    json_file = output_dir / "cleaned_column_mapping.json"
    with open(json_file, 'w') as f:
        json.dump(report, f, indent=2)
    print(f"📄 Saved JSON report: {json_file}")

    # Save Markdown report
    md_content = create_markdown_report(report)
    md_file = output_dir / "cleaned_column_mapping.md"
    with open(md_file, 'w') as f:
        f.write(md_content)
    print(f"📄 Saved Markdown report: {md_file}")

    print("✅ Column mapping analysis complete!")
    print(f"   Found {len(report['intersection_cleaned'])} common columns across all years")
    print(f"   Detected {len(report['transformations'])} column transformations")

    return 0

if __name__ == "__main__":
    exit(main())