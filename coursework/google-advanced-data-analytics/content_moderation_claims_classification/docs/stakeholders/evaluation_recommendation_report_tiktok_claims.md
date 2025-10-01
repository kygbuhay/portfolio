# Evaluation & Recommendation Report: TikTok Claims Classification Model  
> **Docs:** [Proposal](project_proposal_tiktok_claims.md) · [Executive&nbsp;Summary](executive_summary_tiktok_claims.md) · [BRD](business_requirements_tiktok_claims.md) · [Tech&nbsp;Design](technical_requirements_solution_design_tiktok_claims.md) · [Evaluation](evaluation_recommendation_report_tiktok_claims.md) · [Stakeholder&nbsp;Map](stakeholder_map_tiktok_claims.md) · [Risk&nbsp;Log](risk_mitigation_log_tiktok_claims.md) · [Roadmap](next_phase_roadmap_tiktok_claims.md)

**Owner:** Katherine Ygbuhay  
**Date:** September 2025  

--- 

## Model Comparison  
- Logistic Regression: accuracy ~X%, struggled with recall.  
- XGBoost: high accuracy, risk of overfitting.  
- Random Forest: balanced precision/recall, interpretability.  

## Final Recommendation  
- Deploy Random Forest as champion model.  
- Use XGBoost as benchmark for future iterations.  
- Preserve baseline Logistic Regression for auditability.  

## Business Value  
- Prioritizes factual claims, reducing moderation backlog.  
- Interpretable feature drivers (duration, engagement metrics) support stakeholder trust.  
