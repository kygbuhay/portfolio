#!/usr/bin/env python3
"""
Comprehensive Column Analysis Across All Years (2023, 2024, 2025)

Generates EDA-ready documentation and SQL guidance for multi-year analysis.
Analyzes column intersections, availability patterns, and provides practical guidance.
"""

import json
import argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, Set, List, Any

def load_column_data(docs_dir: Path) -> Dict[int, Dict[str, Any]]:
    """Load column data from data dictionary files."""
    data_by_year = {}

    # Try to load combined file first
    combined_file = docs_dir / 'data_dictionary.json'
    if combined_file.exists():
        with open(combined_file, 'r') as f:
            combined_data = json.load(f)
            for year_data in combined_data:
                year = year_data.get('year')
                if year and year_data.get('loaded_ok'):
                    data_by_year[year] = year_data

    # Also try individual files as fallback/validation
    for year in [2023, 2024, 2025]:
        year_file = docs_dir / f'data_dictionary_{year}.json'
        if year_file.exists() and year not in data_by_year:
            with open(year_file, 'r') as f:
                year_data = json.load(f)
                if year_data.get('loaded_ok'):
                    data_by_year[year] = year_data

    return data_by_year

def extract_column_info(data_by_year: Dict[int, Dict[str, Any]]) -> Dict[int, Dict[str, Dict]]:
    """Extract detailed column information by year."""
    columns_by_year = {}

    for year, year_data in data_by_year.items():
        columns_info = {}
        for col_data in year_data.get('columns', []):
            col_name = col_data['name']
            columns_info[col_name] = {
                'index': col_data.get('index', 0),
                'null_pct': col_data.get('null_pct', 0),
                'is_numeric': col_data.get('is_numeric', False),
                'looks_like_date': col_data.get('looks_like_date', False),
                'is_multiselect': col_data.get('is_multiselect', False),
                'unique_approx': col_data.get('unique_approx', 0),
                'examples': col_data.get('examples', [])[:3]  # First 3 examples
            }
        columns_by_year[year] = columns_info

    return columns_by_year

def calculate_intersections(columns_by_year: Dict[int, Dict[str, Dict]]) -> Dict[str, Set[str]]:
    """Calculate all possible column intersections."""
    intersections = {}

    # Get column names by year
    cols_2023 = set(columns_by_year.get(2023, {}).keys())
    cols_2024 = set(columns_by_year.get(2024, {}).keys())
    cols_2025 = set(columns_by_year.get(2025, {}).keys())

    # All combinations
    intersections['all_three'] = cols_2023 & cols_2024 & cols_2025
    intersections['2023_2024'] = cols_2023 & cols_2024
    intersections['2023_2025'] = cols_2023 & cols_2025
    intersections['2024_2025'] = cols_2024 & cols_2025
    intersections['union_all'] = cols_2023 | cols_2024 | cols_2025

    # Year-specific (not in others)
    intersections['only_2023'] = cols_2023 - cols_2024 - cols_2025
    intersections['only_2024'] = cols_2024 - cols_2023 - cols_2025
    intersections['only_2025'] = cols_2025 - cols_2023 - cols_2024

    # Two-year combinations (not in third)
    intersections['2023_2024_not_2025'] = (cols_2023 & cols_2024) - cols_2025
    intersections['2023_2025_not_2024'] = (cols_2023 & cols_2025) - cols_2024
    intersections['2024_2025_not_2023'] = (cols_2024 & cols_2025) - cols_2023

    return intersections

def categorize_columns_for_analysis(columns_by_year: Dict[int, Dict[str, Dict]],
                                  intersections: Dict[str, Set[str]]) -> Dict[str, List[str]]:
    """Categorize columns by their relevance for EDA and analysis."""
    categories = {
        'core_identifiers': [],
        'demographics': [],
        'ai_usage': [],
        'productivity_metrics': [],
        'experience': [],
        'technology_stack': [],
        'survey_meta': [],
        'year_specific_features': []
    }

    # Get all columns with some metadata
    all_cols = intersections['union_all']

    # Categorization patterns
    patterns = {
        'core_identifiers': ['ResponseId', 'MainBranch'],
        'demographics': ['Age', 'Country', 'Employment', 'EdLevel', 'RemoteWork', 'OrgSize', 'Industry'],
        'ai_usage': [col for col in all_cols if any(x in col.upper() for x in ['AI', 'TOOL'])],
        'productivity_metrics': ['ConvertedCompYearly', 'CompTotal', 'JobSat', 'WorkExp'],
        'experience': ['YearsCode', 'YearsCodePro', 'DevType', 'LearnCode'],
        'technology_stack': [col for col in all_cols if any(x in col for x in ['Language', 'Database', 'Platform', 'Framework', 'Tech'])],
        'survey_meta': ['SurveyLength', 'SurveyEase', 'SOVisitFreq', 'SOAccount', 'TimeSearching', 'TimeAnswering']
    }

    categorized = set()

    # Apply patterns
    for category, pattern_list in patterns.items():
        if isinstance(pattern_list[0], str) and not any('Have' in pattern_list[0] for pattern_list in [pattern_list]):
            # Direct matches
            for col in pattern_list:
                if col in all_cols:
                    categories[category].append(col)
                    categorized.add(col)
        else:
            # Pattern matches (for ai_usage and technology_stack)
            categories[category] = pattern_list
            categorized.update(pattern_list)

    # Everything else goes to year_specific_features
    categories['year_specific_features'] = sorted(all_cols - categorized)

    return categories

def generate_comprehensive_overview(docs_dir: Path, data_by_year: Dict[int, Dict[str, Any]],
                                  columns_by_year: Dict[int, Dict[str, Dict]],
                                  intersections: Dict[str, Set[str]],
                                  categories: Dict[str, List[str]]) -> None:
    """Generate comprehensive analysis overview."""

    output_file = docs_dir / 'comprehensive_column_analysis.md'

    # Get row counts
    row_counts = {year: data['rows_loaded'] for year, data in data_by_year.items()}

    md_content = f"""# Comprehensive Column Analysis: 2023-2025 StackOverflow Survey

**Generated:** Auto-generated analysis for EDA and SQL query planning

## 📊 **Dataset Overview**

| Year | Rows | Columns | Status | File Size |
|------|------|---------|--------|-----------|
| 2023 | {row_counts.get(2023, 'N/A'):,} | {len(columns_by_year.get(2023, {})):,} | ✅ Clean | {data_by_year.get(2023, {}).get('file_size_mb', 'N/A')} MB |
| 2024 | {row_counts.get(2024, 'N/A'):,} | {len(columns_by_year.get(2024, {})):,} | ✅ Clean | {data_by_year.get(2024, {}).get('file_size_mb', 'N/A')} MB |
| 2025 | {row_counts.get(2025, 'N/A'):,} | {len(columns_by_year.get(2025, {})):,} | ✅ Clean | {data_by_year.get(2025, {}).get('file_size_mb', 'N/A')} MB |

**Total unique columns across all years:** {len(intersections['union_all']):,}

## 🎯 **Column Intersection Analysis**

### **Core Intersections for Analysis**

| Intersection Type | Count | Use Case |
|------------------|-------|----------|
| **All 3 years** (2023 ∩ 2024 ∩ 2025) | **{len(intersections['all_three'])}** | **Longitudinal trends, core metrics** |
| 2023 ∩ 2024 (baseline) | {len(intersections['2023_2024'])} | Pre-AI adoption comparison |
| 2024 ∩ 2025 (recent) | {len(intersections['2024_2025'])} | Recent AI adoption trends |
| 2023 ∩ 2025 (evolution) | {len(intersections['2023_2025'])} | Long-term changes |

### **Year-Specific Columns (New Features)**

| Year | Unique Columns | Key Focus Areas |
|------|----------------|-----------------|
| 2023 only | {len(intersections['only_2023'])} | Pre-AI baseline features |
| 2024 only | {len(intersections['only_2024'])} | Early AI adoption questions |
| 2025 only | {len(intersections['only_2025'])} | Advanced AI agent features |

## 🔍 **EDA Strategy by Analysis Type**

### **1. Longitudinal Analysis (All 3 Years)**
**Use these {len(intersections['all_three'])} core columns for trend analysis:**

```sql
-- Core demographic and experience trends
SELECT year, Age, DevType, YearsCodePro, Employment, RemoteWork
FROM combined_data
WHERE year IN (2023, 2024, 2025);
```

**Key columns available in all years:**
"""

    # Add core columns available in all years
    core_cols = sorted(intersections['all_three'])
    for i, col in enumerate(core_cols):
        if i % 4 == 0:
            md_content += "\n- "
        md_content += f"`{col}`"
        if i < len(core_cols) - 1:
            md_content += ", "

    md_content += f"""

### **2. AI Adoption Analysis (2024-2025 Focus)**
**Use these {len(intersections['2024_2025'])} columns for AI trend analysis:**

```sql
-- AI tool usage evolution
SELECT year, AISelect, AIAcc, AIComplex,
       COUNT(*) as respondents
FROM combined_data
WHERE year IN (2024, 2025)
  AND AISelect IS NOT NULL
GROUP BY year, AISelect, AIAcc, AIComplex;
```

### **3. Baseline Comparison (2023 vs 2024)**
**Use these {len(intersections['2023_2024'])} columns for pre/early AI adoption:**

```sql
-- Pre-AI vs Early AI adoption productivity metrics
SELECT year,
       AVG(ConvertedCompYearly) as avg_salary,
       AVG(CASE WHEN YearsCodePro ~ '^[0-9]+$'
                THEN CAST(YearsCodePro AS INTEGER) END) as avg_experience
FROM combined_data
WHERE year IN (2023, 2024)
  AND ConvertedCompYearly IS NOT NULL
GROUP BY year;
```

## 📋 **Analysis-Ready Column Categories**

### **🎯 Core Identifiers & Demographics**
*Essential for all analyses*
"""

    # Add categorized columns
    for category, cols in categories.items():
        if not cols:
            continue

        category_names = {
            'core_identifiers': '🎯 Core Identifiers & Demographics',
            'demographics': '👥 Demographics & Background',
            'ai_usage': '🤖 AI Usage & Adoption',
            'productivity_metrics': '📈 Productivity & Compensation',
            'experience': '🎓 Experience & Learning',
            'technology_stack': '💻 Technology Stack',
            'survey_meta': '📝 Survey Metadata',
            'year_specific_features': '🔄 Year-Specific Features'
        }

        if category in category_names:
            md_content += f"\n\n### **{category_names[category]}**\n"

            # Add availability info for each column
            for col in sorted(cols)[:10]:  # Limit to first 10 to keep readable
                availability = []
                for year in [2023, 2024, 2025]:
                    if col in columns_by_year.get(year, {}):
                        availability.append(str(year))

                md_content += f"- `{col}` ({', '.join(availability)})\n"

            if len(cols) > 10:
                md_content += f"- *...and {len(cols) - 10} more columns*\n"

    md_content += f"""

## 🗃️ **SQL Query Templates**

### **Create Combined View for Analysis**
```sql
-- Union all years with year identifier
CREATE VIEW combined_survey AS
SELECT *, 2023 as survey_year FROM stackoverflow_2023
UNION ALL
SELECT *, 2024 as survey_year FROM stackoverflow_2024
UNION ALL
SELECT *, 2025 as survey_year FROM stackoverflow_2025;
```

### **AI Adoption Trend Analysis**
```sql
-- Track AI tool adoption over time
WITH ai_adoption AS (
  SELECT survey_year,
         AISelect,
         COUNT(*) as respondents,
         COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY survey_year) as percentage
  FROM combined_survey
  WHERE survey_year IN (2024, 2025)  -- AI questions started in 2024
    AND AISelect IS NOT NULL
  GROUP BY survey_year, AISelect
)
SELECT * FROM ai_adoption
ORDER BY survey_year, percentage DESC;
```

### **Productivity Impact Analysis**
```sql
-- Compare productivity metrics by AI usage
SELECT
  survey_year,
  AISelect as ai_usage,
  COUNT(*) as respondents,
  AVG(ConvertedCompYearly) as avg_salary,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ConvertedCompYearly) as median_salary
FROM combined_survey
WHERE survey_year IN (2024, 2025)
  AND ConvertedCompYearly BETWEEN 10000 AND 500000  -- Remove outliers
  AND AISelect IS NOT NULL
GROUP BY survey_year, AISelect
ORDER BY survey_year, avg_salary DESC;
```

### **Experience vs AI Adoption**
```sql
-- Analyze AI adoption by experience level
SELECT
  CASE
    WHEN YearsCodePro ~ '^[0-9]+$' AND CAST(YearsCodePro AS INTEGER) < 5 THEN 'Junior (0-5 years)'
    WHEN YearsCodePro ~ '^[0-9]+$' AND CAST(YearsCodePro AS INTEGER) BETWEEN 5 AND 10 THEN 'Mid (5-10 years)'
    WHEN YearsCodePro ~ '^[0-9]+$' AND CAST(YearsCodePro AS INTEGER) > 10 THEN 'Senior (10+ years)'
    ELSE 'Other'
  END as experience_level,
  AISelect as ai_usage,
  COUNT(*) as respondents
FROM combined_survey
WHERE survey_year = 2025  -- Most recent AI data
  AND YearsCodePro IS NOT NULL
  AND AISelect IS NOT NULL
GROUP BY experience_level, ai_usage
ORDER BY experience_level, respondents DESC;
```

## 📈 **Recommended EDA Workflow**

### **Phase 1: Data Quality Assessment**
1. **Missing data patterns** across years
2. **Sample size** by key demographic segments
3. **Outlier detection** in numeric fields

### **Phase 2: Baseline Understanding (2023)**
1. **Developer demographics** and experience distribution
2. **Technology stack** preferences and patterns
3. **Compensation** and satisfaction baselines

### **Phase 3: AI Adoption Tracking (2024-2025)**
1. **Adoption rates** by demographic segments
2. **Tool preferences** and usage patterns
3. **Productivity correlations** with AI usage

### **Phase 4: Longitudinal Trends**
1. **Salary evolution** by experience and location
2. **Technology stack** shifts over time
3. **Remote work** pattern changes

## ⚠️ **Important Notes for Analysis**

### **Data Compatibility**
- **2025 has the most comprehensive AI features** ({len(intersections['only_2025'])} new columns)
- **Core demographic questions consistent** across all years
- **Some 2023 columns deprecated** in later years

### **Sample Considerations**
- **2023:** {row_counts.get(2023, 'N/A'):,} responses (pre-AI baseline)
- **2024:** {row_counts.get(2024, 'N/A'):,} responses (early AI adoption)
- **2025:** {row_counts.get(2025, 'N/A'):,} responses (mature AI adoption)

### **Column Naming Patterns**
- **`HaveWorkedWith`** = Current usage
- **`WantToWorkWith`** = Interest/intent
- **`Admired`** = Preference (2024+ only)
- **`AI*`** = AI-related questions (2024+ with expansion in 2025)

---

**Generated by:** Comprehensive Column Analysis Script
**Last Updated:** {Path(__file__).stat().st_mtime if Path(__file__).exists() else 'Unknown'}
**Source Files:** data_dictionary_2023.json, data_dictionary_2024.json, data_dictionary_2025.json
"""

    # Write the file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(md_content)

    return output_file

def generate_sql_ready_column_list(docs_dir: Path, intersections: Dict[str, Set[str]],
                                 columns_by_year: Dict[int, Dict[str, Dict]]) -> None:
    """Generate SQL-ready column lists for different analysis types."""

    output_file = docs_dir / 'sql_column_reference.sql'

    sql_content = f"""-- SQL Column Reference for StackOverflow Survey Analysis
-- Generated automatically from data inventory

-- =============================================================================
-- COLUMN AVAILABILITY BY INTERSECTION TYPE
-- =============================================================================

-- Columns available in ALL 3 years (2023, 2024, 2025) - {len(intersections['all_three'])} columns
-- Use these for longitudinal trend analysis
/*
ALL_YEARS_COLUMNS ({len(intersections['all_three'])} columns):
{', '.join(f"'{col}'" for col in sorted(intersections['all_three']))}
*/

-- Columns available in 2023 & 2024 only - {len(intersections['2023_2024'])} columns
-- Use these for baseline vs early AI adoption comparison
/*
BASELINE_COLUMNS_2023_2024 ({len(intersections['2023_2024'])} columns):
{', '.join(f"'{col}'" for col in sorted(intersections['2023_2024']))}
*/

-- Columns available in 2024 & 2025 only - {len(intersections['2024_2025'])} columns
-- Use these for AI adoption trend analysis
/*
AI_ERA_COLUMNS_2024_2025 ({len(intersections['2024_2025'])} columns):
{', '.join(f"'{col}'" for col in sorted(intersections['2024_2025']))}
*/

-- =============================================================================
-- READY-TO-USE COLUMN LISTS FOR SELECT STATEMENTS
-- =============================================================================

-- Core demographics (available all years)
SELECT
  {', '.join([f"'{col}'" for col in sorted(intersections['all_three']) if any(x in col.lower() for x in ['age', 'country', 'employment', 'remote', 'orgsize', 'devtype'])])},
  survey_year
FROM combined_survey;

-- AI usage columns (2024-2025)
SELECT
  {', '.join([f"'{col}'" for col in sorted(intersections['2024_2025']) if 'ai' in col.lower()][:10])},  -- First 10 AI columns
  survey_year
FROM combined_survey
WHERE survey_year IN (2024, 2025);

-- Productivity metrics (all years)
SELECT
  ResponseId,
  ConvertedCompYearly,
  YearsCodePro,
  DevType,
  survey_year
FROM combined_survey;

-- =============================================================================
-- YEAR-SPECIFIC FEATURE ANALYSIS
-- =============================================================================

-- 2025 new features ({len(intersections['only_2025'])} columns)
/*
NEW_IN_2025:
{', '.join(f"'{col}'" for col in sorted(list(intersections['only_2025'])[:20]))}
{"..." if len(intersections['only_2025']) > 20 else ""}
*/

-- 2024 new features ({len(intersections['only_2024'])} columns)
/*
NEW_IN_2024:
{', '.join(f"'{col}'" for col in sorted(intersections['only_2024']))}
*/

-- 2023 deprecated features ({len(intersections['only_2023'])} columns)
/*
DEPRECATED_AFTER_2023:
{', '.join(f"'{col}'" for col in sorted(intersections['only_2023']))}
*/
"""

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(sql_content)

    return output_file

def main():
    parser = argparse.ArgumentParser(description="Generate comprehensive column analysis across all years")
    parser.add_argument('--docsdir', type=str, default='docs',
                       help='Directory containing data dictionary files')
    args = parser.parse_args()

    docs_dir = Path(args.docsdir)

    print("🔍 Loading data dictionary files...")
    data_by_year = load_column_data(docs_dir)

    if not data_by_year:
        print("❌ No data dictionary files found. Run data inventory first.")
        return 1

    print(f"✅ Loaded data for years: {sorted(data_by_year.keys())}")

    print("📊 Extracting column information...")
    columns_by_year = extract_column_info(data_by_year)

    print("🔗 Calculating intersections...")
    intersections = calculate_intersections(columns_by_year)

    print("🏷️ Categorizing columns for analysis...")
    categories = categorize_columns_for_analysis(columns_by_year, intersections)

    print("📝 Generating comprehensive overview...")
    overview_file = generate_comprehensive_overview(
        docs_dir, data_by_year, columns_by_year, intersections, categories
    )
    print(f"✅ Created: {overview_file}")

    print("💾 Generating SQL reference...")
    sql_file = generate_sql_ready_column_list(docs_dir, intersections, columns_by_year)
    print(f"✅ Created: {sql_file}")

    # Print summary
    print(f"\n📋 Analysis Summary:")
    print(f"   Total unique columns: {len(intersections['union_all'])}")
    print(f"   Available in all 3 years: {len(intersections['all_three'])}")
    print(f"   2023 ∩ 2024 (baseline): {len(intersections['2023_2024'])}")
    print(f"   2024 ∩ 2025 (AI era): {len(intersections['2024_2025'])}")
    print(f"   2025 new features: {len(intersections['only_2025'])}")

    return 0

if __name__ == '__main__':
    exit(main())