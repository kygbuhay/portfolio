# Executive Summary: TikTok Claims Classification Model  
> **Docs:** [Proposal](project_proposal_tiktok_claims.md) · [Executive&nbsp;Summary](executive_summary_tiktok_claims.md) · [BRD](business_requirements_tiktok_claims.md) · [Tech&nbsp;Design](technical_requirements_solution_design_tiktok_claims.md) · [Evaluation](evaluation_recommendation_report_tiktok_claims.md) · [Stakeholder&nbsp;Map](stakeholder_map_tiktok_claims.md) · [Risk&nbsp;Log](risk_mitigation_log_tiktok_claims.md) · [Roadmap](next_phase_roadmap_tiktok_claims.md)


**Owner:** Katherine Ygbuhay  
**Date:** September 2025  

---
## Business Question  
TikTok moderators face a growing backlog of user-reported videos. The core question:  
**Can we use machine learning to distinguish factual claims from subjective opinions, and prioritize claim content for faster review?**  

---

## Key Findings  
- The **Random Forest classifier** consistently achieved strong performance across training, validation, and test sets.  
- **Recall for the “Claim” class** — the top priority for moderation — was high, with balanced precision and F1 scores ensuring the model does not simply over-predict claims.  
- **Engagement signals drive predictions**: video duration and metrics such as views, likes, and shares were the strongest predictors of claim-like content.  
- Account metadata (e.g., verification status, ban status) contributed minimally to classification accuracy.  

![Random Forest Confusion Matrix](../reports/figures/figures_06_final_recommendation/rf_test_confusion_matrix_counts.png)

---

## Recommendations  
- **Deploy** the Random Forest pipeline as the champion model for claim detection.  
- **Lock preprocessing** inside the pipeline to avoid data leakage.  
- **Monitor model drift**: track precision/recall monthly for the “Claim” class and flag swings >2–3 percentage points.  
- **Human-in-the-loop**: maintain reviewer overrides and audit false negatives weekly.  

![Random Forest Feature Importances](../reports/figures/figures_06_final_recommendation/rf_feature_importances.png)

---

## Risks & Next Steps  
- **Data coverage**: Current dataset is English-only; expansion to multilingual content would improve global applicability.  
- **Feature extensions**: Adding report-based metrics (e.g., number of times flagged) and credibility signals (e.g., fact-check references) could strengthen performance.  
- **Operational rollout**: Collaboration with moderation leads is required to define workflows for model-assisted prioritization.  

---

**Bottom Line:**  
The Random Forest model is accurate, interpretable, and ready for integration into moderation workflows. It will help TikTok reduce backlog, accelerate review of high-risk content, and strengthen trust with users and regulators.  
