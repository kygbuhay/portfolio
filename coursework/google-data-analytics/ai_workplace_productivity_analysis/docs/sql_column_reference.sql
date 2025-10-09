-- SQL Column Reference for StackOverflow Survey Analysis
-- Generated automatically from data inventory

-- =============================================================================
-- COLUMN AVAILABILITY BY INTERSECTION TYPE
-- =============================================================================

-- Columns available in ALL 3 years (2023, 2024, 2025) - 37 columns
-- Use these for longitudinal trend analysis
/*
ALL_YEARS_COLUMNS (37 columns):
'AIAcc', 'AISelect', 'AISent', 'Age', 'CompTotal', 'ConvertedCompYearly', 'Country', 'Currency', 'DatabaseHaveWorkedWith', 'DatabaseWantToWorkWith', 'DevType', 'EdLevel', 'Employment', 'ICorPM', 'Industry', 'LanguageHaveWorkedWith', 'LanguageWantToWorkWith', 'LearnCode', 'MainBranch', 'OfficeStackAsyncHaveWorkedWith', 'OfficeStackAsyncWantToWorkWith', 'OpSysPersonal use', 'OpSysProfessional use', 'OrgSize', 'PlatformHaveWorkedWith', 'PlatformWantToWorkWith', 'PurchaseInfluence', 'RemoteWork', 'ResponseId', 'SOAccount', 'SOComm', 'SOPartFreq', 'SOVisitFreq', 'WebframeHaveWorkedWith', 'WebframeWantToWorkWith', 'WorkExp', 'YearsCode'
*/

-- Columns available in 2023 & 2024 only - 71 columns
-- Use these for baseline vs early AI adoption comparison
/*
BASELINE_COLUMNS_2023_2024 (71 columns):
'AIAcc', 'AIBen', 'AISelect', 'AISent', 'AIToolCurrently Using', 'AIToolInterested in Using', 'AIToolNot interested in Using', 'Age', 'BuyNewTool', 'CodingActivities', 'CompTotal', 'ConvertedCompYearly', 'Country', 'Currency', 'DatabaseHaveWorkedWith', 'DatabaseWantToWorkWith', 'DevType', 'EdLevel', 'Employment', 'Frequency_1', 'Frequency_2', 'Frequency_3', 'ICorPM', 'Industry', 'Knowledge_1', 'Knowledge_2', 'Knowledge_3', 'Knowledge_4', 'Knowledge_5', 'Knowledge_6', 'Knowledge_7', 'Knowledge_8', 'LanguageHaveWorkedWith', 'LanguageWantToWorkWith', 'LearnCode', 'LearnCodeOnline', 'MainBranch', 'MiscTechHaveWorkedWith', 'MiscTechWantToWorkWith', 'NEWCollabToolsHaveWorkedWith', 'NEWCollabToolsWantToWorkWith', 'NEWSOSites', 'OfficeStackAsyncHaveWorkedWith', 'OfficeStackAsyncWantToWorkWith', 'OfficeStackSyncHaveWorkedWith', 'OfficeStackSyncWantToWorkWith', 'OpSysPersonal use', 'OpSysProfessional use', 'OrgSize', 'PlatformHaveWorkedWith', 'PlatformWantToWorkWith', 'ProfessionalTech', 'PurchaseInfluence', 'RemoteWork', 'ResponseId', 'SOAccount', 'SOComm', 'SOPartFreq', 'SOVisitFreq', 'SurveyEase', 'SurveyLength', 'TBranch', 'TimeAnswering', 'TimeSearching', 'ToolsTechHaveWorkedWith', 'ToolsTechWantToWorkWith', 'WebframeHaveWorkedWith', 'WebframeWantToWorkWith', 'WorkExp', 'YearsCode', 'YearsCodePro'
*/

-- Columns available in 2024 & 2025 only - 54 columns
-- Use these for AI adoption trend analysis
/*
AI_ERA_COLUMNS_2024_2025 (54 columns):
'AIAcc', 'AIComplex', 'AISelect', 'AISent', 'AIThreat', 'Age', 'CompTotal', 'ConvertedCompYearly', 'Country', 'Currency', 'DatabaseAdmired', 'DatabaseHaveWorkedWith', 'DatabaseWantToWorkWith', 'DevType', 'EdLevel', 'Employment', 'ICorPM', 'Industry', 'JobSat', 'JobSatPoints_1', 'JobSatPoints_10', 'JobSatPoints_11', 'JobSatPoints_4', 'JobSatPoints_5', 'JobSatPoints_6', 'JobSatPoints_7', 'JobSatPoints_8', 'JobSatPoints_9', 'LanguageAdmired', 'LanguageHaveWorkedWith', 'LanguageWantToWorkWith', 'LearnCode', 'MainBranch', 'OfficeStackAsyncAdmired', 'OfficeStackAsyncHaveWorkedWith', 'OfficeStackAsyncWantToWorkWith', 'OpSysPersonal use', 'OpSysProfessional use', 'OrgSize', 'PlatformAdmired', 'PlatformHaveWorkedWith', 'PlatformWantToWorkWith', 'PurchaseInfluence', 'RemoteWork', 'ResponseId', 'SOAccount', 'SOComm', 'SOPartFreq', 'SOVisitFreq', 'WebframeAdmired', 'WebframeHaveWorkedWith', 'WebframeWantToWorkWith', 'WorkExp', 'YearsCode'
*/

-- =============================================================================
-- READY-TO-USE COLUMN LISTS FOR SELECT STATEMENTS
-- =============================================================================

-- Core demographics (available all years)
SELECT
  'Age', 'Country', 'DevType', 'Employment', 'LanguageHaveWorkedWith', 'LanguageWantToWorkWith', 'OrgSize', 'RemoteWork',
  survey_year
FROM combined_survey;

-- AI usage columns (2024-2025)
SELECT
  'AIAcc', 'AIComplex', 'AISelect', 'AISent', 'AIThreat', 'MainBranch',  -- First 10 AI columns
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

-- 2025 new features (116 columns)
/*
NEW_IN_2025:
'AIAgentImpactStrongly agree', 'AIAgentKnowledge', 'AIModelsWantToWorkWith', 'AIOpen', 'AIToolCurrently partially AI', 'AIToolPlan to mostly use AI', 'CommPlatformWantToWorkWith', 'JobSatPoints_14', 'JobSatPoints_15_TEXT', 'LearnCodeAI', 'NewRole', 'OfficeStackWantEntry', 'PlatformHaveEntry', 'SO_Actions_15_TEXT', 'SO_Actions_5', 'SO_Actions_6', 'TechEndorse_13', 'TechEndorse_3', 'TechEndorse_8', 'WebframeWantEntry'
...
*/

-- 2024 new features (26 columns)
/*
NEW_IN_2024:
'AIChallenges', 'AIEthics', 'AINextLess integrated', 'AINextMore integrated', 'AINextMuch less integrated', 'AINextMuch more integrated', 'AINextNo change', 'AISearchDevAdmired', 'AISearchDevHaveWorkedWith', 'AISearchDevWantToWorkWith', 'BuildvsBuy', 'Check', 'EmbeddedAdmired', 'EmbeddedHaveWorkedWith', 'EmbeddedWantToWorkWith', 'Frustration', 'Knowledge_9', 'MiscTechAdmired', 'NEWCollabToolsAdmired', 'OfficeStackSyncAdmired', 'ProfessionalCloud', 'ProfessionalQuestion', 'SOHow', 'TechDoc', 'TechEndorse', 'ToolsTechAdmired'
*/

-- 2023 deprecated features (13 columns)
/*
DEPRECATED_AFTER_2023:
'AIDevHaveWorkedWith', 'AIDevWantToWorkWith', 'AINextNeither different nor similar', 'AINextSomewhat different', 'AINextSomewhat similar', 'AINextVery different', 'AINextVery similar', 'AISearchHaveWorkedWith', 'AISearchWantToWorkWith', 'LearnCodeCoursesCert', 'Q120', 'SOAI', 'TechList'
*/
