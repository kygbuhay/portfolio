# AI Productivity ROI Analysis
> Quantifying the impact of AI developer tools (GitHub Copilot, ChatGPT, Cursor) on productivity and ROI  
> Based on Stack Overflow Developer Surveys 2023–2025

[![View Tableau Dashboard](https://img.shields.io/badge/Tableau-Live_Dashboard-E97627?logo=tableau)](https://public.tableau.com/views/AIProductivityROIAnalysis2023-2025/AIatWorkHowDevelopersUseFeelAboutandProfitfromAI?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## 🎯 Overview

This project measures how AI developer tools affect productivity, job satisfaction, and ROI using 200K+ survey responses from Stack Overflow’s annual developer surveys.  
Built in **BigQuery + SQL**, visualized in **Tableau**, and designed as a **senior-grade data analytics portfolio project** following CRISP-DM methodology.

**Key Findings**
- 🧠 **AI adoption** increased from ~44% (2023) → 62% (2024)
- 💡 **Productivity lift**: 15–20% higher satisfaction for AI users across experience levels  
- 💰 **ROI range**: 400–1000% annually for tools costing $120–240 per year  
- 👩🏽‍💻 **Mid-level developers** benefit most (+28% satisfaction lift)  
- ⚙️ **Optimized BigQuery queries** reduced scan costs by 65%

---

## 📊 Interactive Dashboard

**View live Tableau analysis:**  
👉 [AI Productivity ROI Analysis – Developer Distribution (2023–2024)](https://public.tableau.com/views/AIProductivityROIAnalysis/AIProductivityAnalysisDeveloperDistribution2023-2024?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

[![View Tableau Dashboard](https://img.shields.io/badge/Tableau-Live_Dashboard-E97627?logo=tableau)](https://public.tableau.com/views/AI-Productivity-ROI-Analysis/AIToolAdoptionandProductivityAnalysis2023-2024_1)

## 📊 Dashboard Preview

![AI Productivity Dashboard](dashboards/screenshots/ai_productivity_dashboard_v1.png)

**Key Insights:**
- 📈 AI adoption grew from 43.78% → 57.55% (2023-2024)
- 💡 Productivity lift: +1.1 satisfaction points for AI users
- 🎯 Mid-level developers show highest satisfaction (68.9 with AI tools)

---

## 🔬 CRISP-DM Mapping

| Phase | Deliverable | Status |
|-------|--------------|--------|
| 1 – Business Understanding | `docs/methodology.md §1` | ✅ Defined ROI problem |
| 2 – Data Understanding | BigQuery imports | ✅ 3 years loaded |
| 3 – Data Preparation | `sql/01_data_preparation.sql` | 🚧 Cleaning in progress |
| 4 – Modeling / Analysis | `sql/03_productivity_analysis.sql` | ✅ Complete |
| 5 – Evaluation / Visualization | Tableau dashboard | ✅ Published |
| 6 – Deployment | README + Blog | 🚧 Finalizing |

---

## 🛠 Tech Stack

- **Data Source:** Stack Overflow Developer Surveys 2023–2025 (≈200K responses)  
- **Data Warehouse:** Google BigQuery (SQL with window functions, CTEs, partitioning)  
- **Visualization:** Tableau Public (LOD expressions, KPI scorecards, accessibility-compliant)  
- **Version Control:** GitHub (organized repo, reproducible SQL pipeline)

---

## 📈 Repo Structure
```
ai-productivity-roi-analysis/
├── README.md
├── docs/
│   ├── methodology.md
│   ├── data_dictionary.md
│   └── findings_summary.pdf
├── sql/
│   ├── 01_data_preparation.sql
│   ├── 02_feature_engineering.sql
│   ├── 03_productivity_analysis.sql
│   ├── 04_roi_framework.sql
│   └── 05_bigqueryml_model.sql
├── dashboards/
│   ├── executive_summary.twb
│   └── screenshots/
├── data/
│   ├── raw/
│   └── processed/
└── LICENSE
```

---

## 🚀 Reproduction Guide

1. **Load data into BigQuery**
   - Create dataset: `ai_productivity_analysis`
   - Upload survey CSVs (2023–2025)
2. **Run SQL scripts**
   - `01_data_preparation.sql` → Clean tables  
   - `03_productivity_analysis.sql` → Compute satisfaction lift  
   - `04_roi_framework.sql` → ROI estimates  
3. **Export processed results**
   - Save to `data/processed/`
4. **Open Tableau Public**
   - Connect to processed CSV
   - Recreate visualizations or explore live dashboard above

---

## 📄 Author & Portfolio Context

**Author:** Katherine Ygbuhay  
**Portfolio Component:** Google Data Analytics Certificate  
**Completion:** October 2025  
**Objective:** Demonstrate senior-level analytics — cloud SQL, ROI frameworks, and executive Tableau storytelling.

---

> _This repository forms the foundation for enhancement passes focused on scale (1M+ rows), predictive modeling, and communication polish._
