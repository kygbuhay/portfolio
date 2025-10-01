# Project Proposal: TikTok Claims Classification Model  
> **Docs:** [Proposal](project_proposal_tiktok_claims.md) · [Executive&nbsp;Summary](executive_summary_tiktok_claims.md) · [BRD](business_requirements_tiktok_claims.md) · [Tech&nbsp;Design](technical_requirements_solution_design_tiktok_claims.md) · [Evaluation](evaluation_recommendation_report_tiktok_claims.md) · [Stakeholder&nbsp;Map](stakeholder_map_tiktok_claims.md) · [Risk&nbsp;Log](risk_mitigation_log_tiktok_claims.md) · [Roadmap](next_phase_roadmap_tiktok_claims.md)


**Owner:** Katherine Ygbuhay  
**Date:** September 2025  

---

## Objective  
TikTok moderators face a growing backlog of user-reported content. This project develops a machine learning model to classify flagged posts as **claims** (verifiable assertions) or **opinions** (subjective statements).  

By automatically prioritizing claim content for review, the model will:  
- **Reduce manual workload** for moderators  
- **Accelerate response times** for high-risk content  
- **Strengthen trust & safety** outcomes for users and regulators  

**Goals:**  
- **Model Performance**: Achieve ≥90% accuracy with strong precision/recall for claims  
- **Operational Impact**: Reduce moderation backlog by prioritizing factual claims  
- **Trust & Safety**: Increase stakeholder confidence in fairness and speed of moderation  

---

## Scope  

**In Scope:**  
- Historical dataset of flagged TikTok content  
- Data preprocessing and feature engineering (linguistic and metadata features)  
- Model development, training, evaluation, and comparison  
- Deliverables: proposal, Jupyter notebooks, visuals, stakeholder-ready reports  

**Out of Scope:**  
- Moderation policy decisions (what constitutes “misinformation”)  
- Full integration into TikTok’s production infrastructure  

---

## Methodology  

The project will follow a structured, business-oriented data science workflow:  

**1. Plan**  
- Assess dataset schema and balance of claims vs. opinions  
- Establish assumptions and analysis environment (Python, Jupyter)  
- Define evaluation metrics aligned to business needs (accuracy, precision, recall)  

**2. Analyze**  
- Generate descriptive statistics (e.g., text length, engagement metrics)  
- Identify data anomalies and trends  
- Explore relationships between features and target classes  

**3. Construct**  
- Engineer features (linguistic markers, sentiment, metadata signals)  
- Train baseline classification models (logistic regression, random forest, XGBoost)  
- Refine models through hyperparameter tuning and feature selection  

**4. Evaluate**  
- Compare models across precision, recall, F1, and confusion matrices  
- Validate results against stakeholder requirements (recall prioritized for claims)  
- Document limitations and recommendations for dataset expansion (e.g., multilingual content)  

---

## Deliverables & Success Criteria  

| Milestone | Task | Deliverables | Stakeholder |
|-----------|------|--------------|-------------|
| 1 | Data exploration & cleaning | Clean dataset, summary stats | Data Team |
| 2 | Descriptive stats & hypothesis testing | Statistical report, visuals | Analysts |
| 3 | Feature engineering & baseline modeling | Initial models, feature report | Project Manager |
| 4 | Model evaluation & refinement | Evaluation report, error analysis | Moderation Team |
| 5 | Final delivery & presentation | Stakeholder deck, dashboards, recommendations | All Stakeholders |  

**Success Criteria:**  
- Achieve ≥90% accuracy and strong recall for claims  
- Deliver interpretable visuals and documentation  
- Provide actionable recommendations to reduce moderation backlog  

---

## Timeline  
Estimated duration: **6–8 weeks**  
- Weeks 1–2: Data prep and descriptive analysis  
- Weeks 3–4: Feature engineering and baseline modeling  
- Weeks 5–6: Model refinement and evaluation  
- Weeks 7–8: Final deliverables and stakeholder presentation  

---

## Stakeholders  

- **Internal**: TikTok Data Science Team (analysis & model build)  
- **External/Downstream**: Trust & Safety Moderation Team (uses outputs for prioritization)  
- **Regulators/Watchdogs**: Indirect stakeholders monitoring misinformation mitigation  
- **Platform Users**: Benefit from faster and fairer moderation outcomes  

---

## Business Impact  

This project supports TikTok’s mission to provide a safe, inclusive, and authentic platform by:  
- Reducing backlog in moderation queues  
- Improving prioritization of high-risk content  
- Enhancing trust among users, regulators, and the broader public  
