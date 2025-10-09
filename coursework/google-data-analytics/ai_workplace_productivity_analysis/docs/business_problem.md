# 📊 Business Problem Definition  
**Project:** AI Productivity ROI Analysis (Stack Overflow Developer Survey 2023–2025)  
**Author:** Katherine Ygbuhay  
**Date:** October 7, 2025  

---

## 1. Business Objective
Tech executives are investing heavily in AI-assisted developer tools but lack quantifiable evidence of productivity gains or financial ROI.  
**Goal:** Measure the “AI Productivity Paradox” by analyzing how AI tool adoption, sentiment, and compensation evolve across 2023–2025 survey data.

---

## 2. Stakeholders

| Stakeholder Group | Role / Interest | Example Questions |
|-------------------|-----------------|-------------------|
| **Engineering Leadership** | Want to justify AI-tool investments | Are teams with higher AI adoption more productive or better compensated? |
| **Product Managers** | Translate developer sentiment into feature decisions | Which AI features or tools correlate with positive sentiment? |
| **Finance & Operations** | Evaluate ROI from AI-driven workflows | Are salary trends or retention linked to AI usage? |
| **Individual Contributors (Developers)** | Represent end-user experience | Do developers perceive AI tools as helpful or threatening to their roles? |

---

## 3. Success Metrics

| Category | Metric | Description |
|-----------|---------|-------------|
| **Adoption** | AI usage rate (%) | Share of respondents reporting “Yes” to AISelect |
| **Productivity Sentiment** | Favorability index | % of respondents expressing favorable/very favorable sentiment toward AI |
| **Financial ROI** | Median annual compensation by AI use | Compare median `ConvertedCompYearly` for AI vs non-AI users |
| **Experience Alignment** | Experience bucket parity | Distribution of AI use across `YearsCode` experience groups |

---

## 4. Scope

- **Included (Baseline Pass):**  
  - Stack Overflow 2023–2025 developer survey (cleaned structural version)  
  - 37 intersection columns shared across all years  
  - KPIs: adoption, sentiment, median compensation, experience buckets, top languages  

- **Deferred (Next Pass):**  
  - AI-specific questions introduced in 2024–2025 (e.g., AIComplex, AIThreat)  
  - Robust schema harmonization + categorical remapping  
  - Predictive modeling or ROI regression analysis  

---

## 5. Deliverables
| Deliverable | Purpose |
|--------------|----------|
| `/sql/baseline_views.sql` | Creates harmonized tables + KPI views in BigQuery |
| Tableau Dashboard v1 | 1-page visualization for adoption, sentiment, comp, experience, top languages |
| `/docs/data_dictionary.json` | Describes all available columns and metadata |
| `/docs/methodology.md` | Captures assumptions, scope, and next-phase plan |
| `/reports/baseline_findings.md` | TLDR summary of baseline insights |

---

## 6. Acceptance Criteria
- Dashboard shows 5 KPIs with filters for Year and AISelect  
- All charts use only validated “All Years” columns (no null drift)  
- BigQuery views build successfully from `baseline_views.sql`  
- No “nan” or placeholder values in visual legends  
- All deliverables documented in `/docs`, `/sql`, `/reports`  

---

**Summary:**  
This baseline establishes a defensible, repeatable foundation to measure AI-driven productivity trends without overfitting to unstable schema fields. Future passes will extend analysis to sentiment polarity, job satisfaction, and ROI modeling using 2024–2025 enriched AI-specific fields.

