# Column Mapping: Raw → Cleaned Data

**Generated**: 2025-10-08T09:25:33.590371

## 📊 Summary

- **Years Analyzed**: 2023, 2024, 2025
- **Common Columns (All Years)**: 27
- **Transformations Detected**: 0

## 🔄 Column Transformations Detected

| Cleaned Column Name | Likely Original | Data Type | Year Found |
|-------------------|-----------------|-----------|------------|

## 📋 Cleaned Data Intersection (All Years)

These 27 columns are available in ALL cleaned datasets:

- `Age`
- `CompTotal`
- `Country`
- `Currency`
- `DatabaseHaveWorkedWith`
- `DatabaseWantToWorkWith`
- `DevType`
- `EdLevel`
- `Employment`
- `ICorPM`
- `LanguageHaveWorkedWith`
- `LanguageWantToWorkWith`
- `LearnCode`
- `MainBranch`
- `OfficeStackAsyncHaveWorkedWith`
- `OpSysPersonal_use`
- `OpSysProfessional_use`
- `OrgSize`
- `PlatformHaveWorkedWith`
- `PlatformWantToWorkWith`
- `PurchaseInfluence`
- `RemoteWork`
- `ResponseId`
- `WebframeHaveWorkedWith`
- `WebframeWantToWorkWith`
- `WorkExp`
- `YearsCode`

## 📊 Per-Year Column Details


### 2023 Dataset
- **Table**: `2023_stackoverflow_cleaned`
- **Columns**: 87


### 2024 Dataset
- **Table**: `2024_stackoverflow_cleaned`
- **Columns**: 100


### 2025 Dataset
- **Table**: `2025_stackoverflow_cleaned`
- **Columns**: 100


## 🎯 Key Findings

1. **Spaces → Underscores**: Most transformations convert spaces to underscores for BigQuery compatibility
2. **Special Characters**: Non-alphanumeric characters replaced with underscores
3. **AI Tool Fields**: Consistently transformed across all years
4. **OpSys Fields**: Space-containing column names properly converted

## 💡 Recommendations

1. **Use Intersection List**: Focus on the 27 common columns for cross-year analysis
2. **Update SQL Queries**: Use cleaned column names from this documentation
3. **Reference Mapping**: When writing new queries, check transformations table above

---

*This report bridges the gap between original raw data analysis and cleaned BigQuery reality.*
