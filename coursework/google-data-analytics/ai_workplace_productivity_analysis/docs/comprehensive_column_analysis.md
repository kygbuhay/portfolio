# Comprehensive Column Analysis: 2023-2025 StackOverflow Survey

**Generated:** Auto-generated analysis for EDA and SQL query planning

## 📊 **Dataset Overview**

| Year | Rows | Columns | Status | File Size |
|------|------|---------|--------|-----------|
| 2023 | 89,184 | 84 | ✅ Clean | 151.28 MB |
| 2024 | 65,437 | 114 | ✅ Clean | 152.14 MB |
| 2025 | 49,123 | 170 | ✅ Clean | 133.98 MB |

**Total unique columns across all years:** 243

## 🎯 **Column Intersection Analysis**

### **Core Intersections for Analysis**

| Intersection Type | Count | Use Case |
|------------------|-------|----------|
| **All 3 years** (2023 ∩ 2024 ∩ 2025) | **37** | **Longitudinal trends, core metrics** |
| 2023 ∩ 2024 (baseline) | 71 | Pre-AI adoption comparison |
| 2024 ∩ 2025 (recent) | 54 | Recent AI adoption trends |
| 2023 ∩ 2025 (evolution) | 37 | Long-term changes |

### **Year-Specific Columns (New Features)**

| Year | Unique Columns | Key Focus Areas |
|------|----------------|-----------------|
| 2023 only | 13 | Pre-AI baseline features |
| 2024 only | 26 | Early AI adoption questions |
| 2025 only | 116 | Advanced AI agent features |

## 🔍 **EDA Strategy by Analysis Type**

### **1. Longitudinal Analysis (All 3 Years)**
**Use these 37 core columns for trend analysis:**

```sql
-- Core demographic and experience trends
SELECT year, Age, DevType, YearsCodePro, Employment, RemoteWork
FROM combined_data
WHERE year IN (2023, 2024, 2025);
```

**Key columns available in all years:**

- `AIAcc`, `AISelect`, `AISent`, `Age`, 
- `CompTotal`, `ConvertedCompYearly`, `Country`, `Currency`, 
- `DatabaseHaveWorkedWith`, `DatabaseWantToWorkWith`, `DevType`, `EdLevel`, 
- `Employment`, `ICorPM`, `Industry`, `LanguageHaveWorkedWith`, 
- `LanguageWantToWorkWith`, `LearnCode`, `MainBranch`, `OfficeStackAsyncHaveWorkedWith`, 
- `OfficeStackAsyncWantToWorkWith`, `OpSysPersonal use`, `OpSysProfessional use`, `OrgSize`, 
- `PlatformHaveWorkedWith`, `PlatformWantToWorkWith`, `PurchaseInfluence`, `RemoteWork`, 
- `ResponseId`, `SOAccount`, `SOComm`, `SOPartFreq`, 
- `SOVisitFreq`, `WebframeHaveWorkedWith`, `WebframeWantToWorkWith`, `WorkExp`, 
- `YearsCode`

### **2. AI Adoption Analysis (2024-2025 Focus)**
**Use these 54 columns for AI trend analysis:**

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
**Use these 71 columns for pre/early AI adoption:**

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


### **🎯 Core Identifiers & Demographics**
- `MainBranch` (2023, 2024, 2025)
- `ResponseId` (2023, 2024, 2025)


### **👥 Demographics & Background**
- `Age` (2023, 2024, 2025)
- `Country` (2023, 2024, 2025)
- `EdLevel` (2023, 2024, 2025)
- `Employment` (2023, 2024, 2025)
- `Industry` (2023, 2024, 2025)
- `OrgSize` (2023, 2024, 2025)
- `RemoteWork` (2023, 2024, 2025)


### **🤖 AI Usage & Adoption**
- `AIAcc` (2023, 2024, 2025)
- `AIAgentChallengesNeutral` (2025)
- `AIAgentChallengesSomewhat agree` (2025)
- `AIAgentChallengesSomewhat disagree` (2025)
- `AIAgentChallengesStrongly agree` (2025)
- `AIAgentChallengesStrongly disagree` (2025)
- `AIAgentChange` (2025)
- `AIAgentExtWrite` (2025)
- `AIAgentExternal` (2025)
- `AIAgentImpactNeutral` (2025)
- *...and 67 more columns*


### **📈 Productivity & Compensation**
- `CompTotal` (2023, 2024, 2025)
- `ConvertedCompYearly` (2023, 2024, 2025)
- `JobSat` (2024, 2025)
- `WorkExp` (2023, 2024, 2025)


### **🎓 Experience & Learning**
- `DevType` (2023, 2024, 2025)
- `LearnCode` (2023, 2024, 2025)
- `YearsCode` (2023, 2024, 2025)
- `YearsCodePro` (2023, 2024)


### **💻 Technology Stack**
- `CommPlatformAdmired` (2025)
- `CommPlatformHaveEntr` (2025)
- `CommPlatformHaveWorkedWith` (2025)
- `CommPlatformWantEntr` (2025)
- `CommPlatformWantToWorkWith` (2025)
- `DatabaseAdmired` (2024, 2025)
- `DatabaseChoice` (2025)
- `DatabaseHaveEntry` (2025)
- `DatabaseHaveWorkedWith` (2023, 2024, 2025)
- `DatabaseWantEntry` (2025)
- *...and 46 more columns*


### **📝 Survey Metadata**
- `SOAccount` (2023, 2024, 2025)
- `SOVisitFreq` (2023, 2024, 2025)
- `SurveyEase` (2023, 2024)
- `SurveyLength` (2023, 2024)
- `TimeAnswering` (2023, 2024)
- `TimeSearching` (2023, 2024)


### **🔄 Year-Specific Features**
- `AgentUsesGeneral` (2025)
- `BuildvsBuy` (2024)
- `Check` (2024)
- `CodingActivities` (2023, 2024)
- `Currency` (2023, 2024, 2025)
- `DevEnvHaveEntry` (2025)
- `DevEnvWantEntry` (2025)
- `DevEnvsAdmired` (2025)
- `DevEnvsChoice` (2025)
- `DevEnvsHaveWorkedWith` (2025)
- *...and 81 more columns*


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
- **2025 has the most comprehensive AI features** (116 new columns)
- **Core demographic questions consistent** across all years
- **Some 2023 columns deprecated** in later years

### **Sample Considerations**
- **2023:** 89,184 responses (pre-AI baseline)
- **2024:** 65,437 responses (early AI adoption)
- **2025:** 49,123 responses (mature AI adoption)

### **Column Naming Patterns**
- **`HaveWorkedWith`** = Current usage
- **`WantToWorkWith`** = Interest/intent
- **`Admired`** = Preference (2024+ only)
- **`AI*`** = AI-related questions (2024+ with expansion in 2025)

---

**Generated by:** Comprehensive Column Analysis Script
**Last Updated:** 1759871972.4178827
**Source Files:** data_dictionary_2023.json, data_dictionary_2024.json, data_dictionary_2025.json
