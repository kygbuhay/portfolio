# 📊 Data Dictionary
**Project:** AI Productivity ROI Analysis
**Data Source:** Stack Overflow Developer Surveys 2023-2025
**Author:** Katherine Ygbuhay
**Last Updated:** October 2025

---

## 📈 Dataset Overview

| Attribute | Value |
|-----------|-------|
| **Years Covered** | 2023, 2024, 2025 |
| **Total Responses** | ~200,000 across all years |
| **Common Columns** | 27 columns available across all years |
| **Data Format** | CSV files, BigQuery optimized |
| **Primary Key** | ResponseId (unique per response) |

---

## 🔑 Core Analysis Variables

### Demographics & Experience
| Column | Type | Description | Values |
|--------|------|-------------|---------|
| `Age` | Categorical | Age range of respondent | 18-24, 25-34, 35-44, etc. |
| `Country` | String | Country of residence | ISO country codes |
| `EdLevel` | Categorical | Educational attainment | Bachelor's, Master's, PhD, etc. |
| `YearsCode` | Categorical | Years of coding experience | Less than 1 year, 1-2 years, etc. |
| `WorkExp` | Categorical | Years of professional work experience | Same structure as YearsCode |

### Employment & Compensation
| Column | Type | Description | Values |
|--------|------|-------------|---------|
| `Employment` | Categorical | Employment status | Full-time, Part-time, Freelance, etc. |
| `DevType` | Multi-select | Developer role types | Backend, Frontend, Full-stack, etc. |
| `CompTotal` | Numeric | Total annual compensation | USD equivalent |
| `Currency` | String | Original compensation currency | USD, EUR, GBP, etc. |
| `OrgSize` | Categorical | Organization size | 2-9, 10-19, 20-99, etc. employees |
| `RemoteWork` | Categorical | Remote work arrangement | Fully remote, Hybrid, In-person |

### Technology Usage
| Column | Type | Description | Values |
|--------|------|-------------|---------|
| `LanguageHaveWorkedWith` | Multi-select | Programming languages used professionally | JavaScript, Python, Java, etc. |
| `LanguageWantToWorkWith` | Multi-select | Programming languages desired to work with | Same as above |
| `DatabaseHaveWorkedWith` | Multi-select | Databases used professionally | MySQL, PostgreSQL, MongoDB, etc. |
| `DatabaseWantToWorkWith` | Multi-select | Databases desired to work with | Same as above |
| `PlatformHaveWorkedWith` | Multi-select | Platforms used professionally | AWS, Azure, Google Cloud, etc. |
| `PlatformWantToWorkWith` | Multi-select | Platforms desired to work with | Same as above |
| `WebframeHaveWorkedWith` | Multi-select | Web frameworks used professionally | React, Angular, Vue.js, etc. |
| `WebframeWantToWorkWith` | Multi-select | Web frameworks desired to work with | Same as above |

### Development Environment
| Column | Type | Description | Values |
|--------|------|-------------|---------|
| `OpSysPersonal_use` | Multi-select | Operating systems for personal use | Windows, macOS, Linux distributions |
| `OpSysProfessional_use` | Multi-select | Operating systems for professional use | Same as above |
| `OfficeStackAsyncHaveWorkedWith` | Multi-select | Collaboration tools used | Slack, Microsoft Teams, Discord, etc. |

### Career & Learning
| Column | Type | Description | Values |
|--------|------|-------------|---------|
| `MainBranch` | Categorical | Primary role classification | Developer, Manager, Student, etc. |
| `LearnCode` | Multi-select | How respondent learned to code | Online courses, University, Self-taught, etc. |
| `ICorPM` | Categorical | Individual contributor vs people manager | IC, Manager, Both |
| `PurchaseInfluence` | Categorical | Influence on technology purchasing decisions | High, Medium, Low, None |

---

## 🤖 AI-Related Variables (2024-2025)

*Note: AI-specific questions were introduced in 2024 and expanded in 2025*

### AI Adoption & Usage
| Column | Type | Description | Available Years |
|--------|------|-------------|-----------------|
| `AISelect` | Binary | Uses AI tools for development | 2023-2025 |
| `AIBenefit` | Categorical | Perceived benefits of AI tools | 2024-2025 |
| `AISent` | Categorical | Sentiment towards AI in software development | 2024-2025 |
| `AIComplex` | Categorical | AI usage for complex tasks | 2024-2025 |
| `AIThreat` | Categorical | Perceived threat of AI to job | 2024-2025 |

---

## 🔄 Data Processing Notes

### Data Cleaning Applied
1. **Column Name Standardization**: Spaces converted to underscores for BigQuery compatibility
2. **Currency Normalization**: All compensation converted to USD equivalents
3. **Multi-select Parsing**: Semicolon-separated values properly formatted
4. **Missing Value Handling**: Systematic approach to null values and "NA" responses

### Known Limitations
- **Self-reported Data**: Inherent bias in survey responses
- **Sample Bias**: Stack Overflow user base may not represent all developers
- **Schema Evolution**: Some questions changed between years
- **Currency Conversion**: Exchange rates may affect year-over-year comparisons

### Validation Checks
- ✅ No structural corruption detected in any dataset
- ✅ All files pass BigQuery schema validation
- ✅ Response counts match expected survey participation
- ✅ Data types properly enforced for analytics

---

## 📊 Usage Guidelines

### For Analysis
- **Cross-year Studies**: Use the 27 common columns for trend analysis
- **AI Impact Studies**: Focus on `AISelect` as primary adoption indicator
- **Compensation Analysis**: Use `CompTotal` with currency context
- **Technology Trends**: Leverage multi-select fields for ecosystem analysis

### For Visualization
- **Categorical Variables**: Ensure proper ordering for experience levels
- **Multi-select Fields**: Parse semicolon-separated values appropriately
- **Missing Data**: Handle null values consistently across visualizations
- **Currency Display**: Present compensation in standardized format

---

*This data dictionary provides the foundation for reproducible analysis of AI adoption trends in the developer community.*