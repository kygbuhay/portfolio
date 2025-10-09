# Column Analysis: Raw vs Cleaned Data Discrepancies

## 🔍 **Root Cause Analysis**

### **Issue Identified**: Column name transformation during cleaning process

The original column analysis scripts were run on **raw data**, but the SQL queries were written based on that analysis, while the actual **cleaned data** has transformed column names due to BigQuery compatibility requirements.

## 📊 **Comparison: Original vs Cleaned Column Names**

| Original Raw Data | Cleaned BigQuery Data | Transformation Applied |
|------------------|----------------------|----------------------|
| `OpSysPersonal use` | `OpSysPersonal_use` | Space → Underscore |
| `OpSysProfessional use` | `OpSysProfessional_use` | Space → Underscore |
| `AIToolCurrently Using` | `AIToolCurrently_Using` | Space → Underscore |
| `AIToolInterested in Using` | `AIToolInterested_in_Using` | Space → Underscore |
| `AIToolNot interested in Using` | `AIToolNot_interested_in_Using` | Space → Underscore |

## 🔧 **Cleaning Script Transformations**

Our cleaning script (`generate_cleaned_datasets.py`) applies these BigQuery compatibility rules:

```python
# BigQuery column name cleaning rules:
clean_col = re.sub(r'[^a-zA-Z0-9_]', '_', col)  # Replace spaces/special chars with _
clean_col = re.sub(r'^([0-9])', r'col_\1', clean_col)  # Prefix numbers
clean_col = re.sub(r'_+', '_', clean_col)  # Collapse multiple underscores
clean_col = clean_col.strip('_')  # Remove leading/trailing underscores
```

## ⚠️ **Documentation Gap**

### **Problem**:
- Original docs analyzed **raw data** columns
- SQL queries written from those docs
- Actual **cleaned data** has transformed column names
- No updated documentation showing the mapping

### **Impact**:
- SQL queries fail with "column not found" errors
- Analytics queries need manual correction
- Disconnect between documentation and reality

## ✅ **Solution: Generate Post-Cleaning Column Analysis**

### **Need New Scripts For**:
1. **Column mapping**: Raw → Cleaned name transformations
2. **Updated intersection analysis**: Common columns in cleaned data
3. **Type validation**: Verify FLOAT fields are properly handled
4. **Data quality report**: Post-cleaning statistics

## 📋 **Recommended Action Plan**

### 1. **Create Column Mapping Script**
```python
# Generate mapping of raw_column_name → cleaned_column_name
# For each year: 2023, 2024, 2025
# Output: column_mapping_YYYY.json
```

### 2. **Updated Intersection Analysis**
```python
# Re-run intersection analysis on CLEANED BigQuery data
# Output: cleaned_column_intersection.md
```

### 3. **BigQuery Schema Documentation**
```python
# Extract actual BigQuery schema with types
# Cross-reference with original raw data
# Output: bigquery_schema_documentation.md
```

### 4. **SQL Query Template Updates**
```sql
-- Update baseline_views.sql with correct cleaned column names
-- Create reusable column reference for future queries
```

## 🎯 **Immediate Fix Status**

### ✅ **Already Fixed**:
- `baseline_views_CORRECTED.sql` - Manual corrections applied
- Core query now works with cleaned data

### ⚠️ **Still Needed**:
- Systematic column mapping documentation
- Updated intersection analysis for cleaned data
- Automated script to generate correct SQL from cleaned schemas

## 🔄 **Script Assessment**

### **Original Scripts (for raw data)**: ✅ Worked correctly
- Properly analyzed raw StackOverflow CSV files
- Generated accurate intersection of available columns
- Issue: Didn't account for cleaning transformations

### **Cleaning Scripts**: ✅ Worked correctly
- Applied proper BigQuery compatibility transformations
- Successfully uploaded all data with correct types
- Issue: Didn't update documentation post-cleaning

### **Gap**: No post-cleaning analysis scripts
- **Missing**: Raw → Cleaned column mapping
- **Missing**: Updated intersection on cleaned data
- **Missing**: BigQuery schema extraction and documentation

## 💡 **Recommendation**

**Create a "Phase 2" analysis suite**:
1. **Column mapping generator** - Document all transformations
2. **Cleaned data profiler** - Rerun analysis on BigQuery tables
3. **SQL template generator** - Auto-generate queries with correct column names
4. **Documentation updater** - Refresh all docs with cleaned data reality

This will prevent future SQL/documentation mismatches and provide accurate column references for analytics work.

---

**Analysis Date**: October 8, 2025
**Status**: Issue identified and root cause determined
**Next Steps**: Implement Phase 2 post-cleaning analysis scripts