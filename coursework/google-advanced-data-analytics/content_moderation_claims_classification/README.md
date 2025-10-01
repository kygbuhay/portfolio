# TikTok Claims Classification

This case study develops and evaluates machine learning models to classify TikTok videos as **factual claims** or **subjective opinions**.  
The goal is to help moderation teams prioritize high-risk claim content, reduce backlog, and strengthen trust & safety outcomes.

**Key Metric:** Because claim videos are more likely to violate community guidelines, **recall** is prioritized to avoid missing true claims.

---

## 📑 Project Overview

- **Business Question:** Can machine learning reliably distinguish claims from opinions to accelerate moderation workflows?  
- **Dataset:** 19,383 rows × 12 columns (educational/simulated dataset).  
- **Approach:** Exploratory data analysis → feature engineering → baseline models → advanced models (Random Forest, XGBoost).  
- **Champion Model (Test Set):** Recall = **0.997**, Precision = **1.000**, F1 = **0.998**.

---

## 📂 Repository Layout

- **Notebooks:** [`notebooks/`](./notebooks/)
- **Notebook Exports (Markdown):** [`reports/notebooks_md/`](./reports/notebooks_md/)
- **Figures:** [`reports/figures/`](./reports/figures/)
- **Stakeholder Docs:** [`docs/stakeholders/`](./docs/stakeholders/)
- **Reference Docs:** [`docs/reference/`](./docs/reference/)
- **Data:** [`data/raw/`](./data/raw/)
- **Source Code:** [`src/`](./src/)

---

## 📊 Data Access

Expected dataset location:

    data/raw/tiktok_dataset.csv

Load in Python:

    import pandas as pd
    df = pd.read_csv("data/raw/tiktok_dataset.csv")

If you launch from other folders (e.g., directly from `notebooks/`), use the robust loader snippet included in this repo.

---

## 🔗 Key Documents

- **Summary Notebook (Start Here):** [`notebooks/00_case_study_overview.ipynb`](./notebooks/00_case_study_overview.ipynb)  
- **Final Recommendation Notebook:** [`notebooks/06_tree_models_recommendation.ipynb`](./notebooks/06_tree_models_recommendation.ipynb)  
- **Data Dictionary:** [`docs/reference/data_dictionary.md`](./docs/reference/data_dictionary.md)  
- **Stakeholder Docs (packet):** [`docs/stakeholders/`](./docs/stakeholders/)

---

## 🛠 Tools & Libraries

- **Python:** pandas, scikit-learn, matplotlib, seaborn  
- **Documentation:** Jupyter, Markdown  
- **Version Control:** Git/GitHub

---

## 👩‍💻 Author

**Katherine Ygbuhay**  
September 2025
