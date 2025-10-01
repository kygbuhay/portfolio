# Technical Requirements & Solution Design: TikTok Claims Classification Model  
> **Docs:** [Proposal](project_proposal_tiktok_claims.md) · [Executive&nbsp;Summary](executive_summary_tiktok_claims.md) · [BRD](business_requirements_tiktok_claims.md) · [Tech&nbsp;Design](technical_requirements_solution_design_tiktok_claims.md) · [Evaluation](evaluation_recommendation_report_tiktok_claims.md) · [Stakeholder&nbsp;Map](stakeholder_map_tiktok_claims.md) · [Risk&nbsp;Log](risk_mitigation_log_tiktok_claims.md) · [Roadmap](next_phase_roadmap_tiktok_claims.md)

**Owner:** Katherine Ygbuhay  
**Date:** September 2025  

---
 
## Data Sources  
- Flagged TikTok videos (metadata: duration, views, likes, shares, comments, text length).  
- Labels: Claim vs. Opinion (annotated for training).  

## Feature Engineering  
- Derived features: text length, engagement ratios (likes/views, shares/views).  
- Dropped metadata signals (verification, ban status) due to low predictive value.  

## Modeling  
- Baseline: Logistic Regression.  
- Advanced: Random Forest, XGBoost.  
- Champion: Random Forest (balanced accuracy, interpretability).  

## Tools & Environment  
- Python (pandas, scikit-learn, xgboost, matplotlib, seaborn).  
- Jupyter Notebooks for analysis & reporting.  
- GitHub for versioning and documentation.  

## Deliverables  
- Cleaned dataset & preprocessing pipeline.  
- Trained Random Forest model (packaged).  
- Reports & stakeholder docs.  
- Figures: feature importances, confusion matrices.  
