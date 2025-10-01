# Business Requirements Document (BRD) : TikTok Claims Classification Model  
> **Docs:** [Proposal](project_proposal_tiktok_claims.md) · [Executive&nbsp;Summary](executive_summary_tiktok_claims.md) · [BRD](business_requirements_tiktok_claims.md) · [Tech&nbsp;Design](technical_requirements_solution_design_tiktok_claims.md) · [Evaluation](evaluation_recommendation_report_tiktok_claims.md) · [Stakeholder&nbsp;Map](stakeholder_map_tiktok_claims.md) · [Risk&nbsp;Log](risk_mitigation_log_tiktok_claims.md) · [Roadmap](next_phase_roadmap_tiktok_claims.md)

**Owner:** Katherine Ygbuhay  
**Date:** September 2025  

---

## 1. Background  
TikTok’s Trust & Safety teams face an increasing backlog of user-reported videos. Current moderation workflows require human reviewers to triage both factual **claims** (verifiable assertions) and **opinions** (subjective expressions), leading to delays in addressing high-risk content.  

Machine learning presents an opportunity to classify flagged content into **claims vs. opinions** automatically, enabling moderators to prioritize claim content that may spread misinformation or violate community guidelines.  

Key observations from data exploration:  
- The dataset contains flagged TikTok videos with associated metadata (views, likes, shares, comments, duration, text length, verification status).  
- **Engagement features** (views, likes, shares, duration) exhibited the strongest patterns differentiating claims from opinions.  
- Metadata features (e.g., verification, ban status) contributed minimally.  
- Current dataset is **English-only** and does not capture multilingual or fact-check reference data.  

---

## 2. Goals & KPIs  

**Goal 1: Prioritize claim content for faster review**  
- **KPI:** ≥90% classification accuracy across test data  

**Goal 2: Minimize missed claims**  
- **KPI:** Recall for “Claim” class ≥95%  

**Goal 3: Reduce backlog in moderation queues**  
- **KPI:** Demonstrated reduction in average flagged content review time (target: ≥20%)  

**Goal 4: Improve stakeholder confidence**  
- **KPI:** Model outputs are interpretable, with clear feature importance reports provided to Trust & Safety leads.  

---

## 3. Functional Requirements  
The solution must:  
- Accept flagged TikTok content with metadata and basic engagement statistics as input.  
- Output a binary classification: **Claim** or **Opinion**.  
- Provide interpretable model results, including feature importances and evaluation metrics.  
- Integrate into moderation workflows as a prioritization layer, not a replacement for human reviewers.  

---

## 4. Non-Functional Requirements  
- **Performance:** Maintain ≥90% accuracy and ≥95% recall for “Claim” class on held-out test data.  
- **Transparency:** Deliver outputs with interpretable metrics and visuals for stakeholder review.  
- **Maintainability:** Pipeline must lock preprocessing steps to avoid leakage and ensure reproducibility.  
- **Monitoring:** Monthly drift monitoring, with alerts triggered for >3 percentage point drop in claim-class recall.  
- **Scalability:** Model should support future extensions (e.g., multilingual data, new engagement features).  

---

## 5. Constraints & Assumptions  
- Dataset is English-only; multilingual support is out of scope for this phase.  
- Engagement features are the most reliable predictors; metadata features are less informative.  
- Fact-checking signals and report-based metrics are currently unavailable but may be added in future iterations.  
- Human moderation remains in the loop for quality control and edge-case review.  

---

## 6. Acceptance Criteria  
- ≥90% overall classification accuracy on test data.  
- ≥95% recall for “Claim” class.  
- Clear documentation of model methodology, evaluation, and feature importance.  
- Stakeholders sign off on interpretability, integration readiness, and operational value.  

---

## 7. Stakeholder Sign-Off (Illustrative)  

*Note: This table is included as a **template** to demonstrate stakeholder alignment structure. Placeholder roles are used — no real-world signatures implied.*  

| Role                | Name / Placeholder | Signature | Date |
|---------------------|--------------------|-----------|------|
| Trust & Safety Lead | [Placeholder]      | [   ]     | [   ] |
| Data Science Lead   | [Placeholder]      | [   ]     | [   ] |
| Analyst             | Katherine Ygbuhay  | [   ]     | [   ] |
