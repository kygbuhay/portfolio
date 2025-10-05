# Employee Attrition Analysis

***Comprehensive HR analytics to identify turnover drivers and develop predictive retention strategies***

**Business Context:** Salifort Motors
**Analysis Type:** Predictive Modeling, HR Analytics, Business Intelligence
**Timeline:** 7-Stage Analytical Workflow
**Key Achievement:** 85% ROC-AUC with actionable business insights

---

## 🎯 **Business Objective**

Salifort's leadership asked: *"Why are employees leaving, and what can we do to reduce attrition?"*

This analysis identifies key drivers of employee turnover and develops a predictive model to guide proactive retention strategies, potentially saving significant recruitment and training costs.

## 📊 **Executive Summary**

**Key Findings:**
- **Satisfaction level** is the strongest predictor of attrition
- **Short tenure + high project load** creates significant attrition risk
- **Department disparities** exist (Sales/Support vs. R&D/Management)
- **Workload imbalances** correlate with early departure

**Model Performance:**
- **Champion Model:** Random Forest (85% ROC-AUC)
- **Business Impact:** Identifies 72% of at-risk employees for proactive intervention
- **Interpretability:** Feature importance rankings guide HR policy decisions

➡️ [**View Full Executive Summary with Visualizations**](docs/stakeholders/executive_summary_with_appendix.md)

---

## 🔬 **Analytical Workflow**

This case study follows a 7-stage professional workflow demonstrating end-to-end data science capabilities:

| Stage | Notebook | Focus | Key Deliverables |
|-------|----------|-------|------------------|
| **01** | [Data Dictionary Setup](notebooks/01_data_dictionary_setup.ipynb) | Schema analysis, data quality assessment | Professional data dictionary, target distribution analysis |
| **02** | [Data Cleaning](notebooks/02_data_cleaning.ipynb) | Missing values, outliers, feature encoding | Clean dataset, reproducible preprocessing pipeline |
| **03** | [Exploratory Analysis](notebooks/03_exploratory_analysis.ipynb) | Patterns, correlations, target relationships | Statistical insights, visual documentation |
| **04** | [Baseline Modeling](notebooks/04_baseline_logreg.ipynb) | Logistic regression benchmark | Performance baseline, coefficient interpretation |
| **05** | [Tree Models](notebooks/05_tree_models.ipynb) | Random Forest, XGBoost comparison | Feature importance, model benchmarking |
| **06** | [Model Selection](notebooks/06_model_selection.ipynb) | Validation, champion selection | Final model recommendation, business metrics |
| **07** | [Ethics & Bias Review](notebooks/07_ethics_bias_review.ipynb) | Fairness assessment, responsible AI | Bias analysis, deployment safeguards |

## 📈 **Key Visualizations**

The analysis includes comprehensive visualizations demonstrating:

- **Exploratory Analysis**: Distribution patterns, correlation heatmaps, departmental breakdowns
- **Model Performance**: ROC curves, confusion matrices, precision-recall analysis
- **Feature Importance**: Tree-based rankings showing business drivers
- **Ethics Assessment**: Bias detection across protected characteristics

*All figures are version-controlled and reproducible via the automated export pipeline.*

---

## 🛠 **Technical Implementation**

**Core Technologies:**
- **Analysis**: Python (pandas, scikit-learn, matplotlib, seaborn)
- **Modeling**: Logistic Regression, Random Forest, XGBoost
- **Validation**: Cross-validation, ROC-AUC, precision-recall optimization
- **Reproducibility**: Jupyter notebooks, automated figure export, git version control

**Professional Features:**
- **Accessibility-first visualizations** (colorblind-friendly palettes)
- **Automated documentation** with stakeholder-ready deliverables
- **Reproducible pipeline** with virtual environment and requirements
- **Ethical AI practices** including bias assessment and responsible deployment guidelines

---

## 📋 **Reproducibility Guide**

### Prerequisites
- Python 3.8+
- Virtual environment capability
- Jupyter Lab/Notebook

### Quick Start
```bash
# Navigate to case study
cd employee_attrition_analysis

# Install dependencies
pip install -r requirements.txt

# Launch analysis pipeline
jupyter lab notebooks/01_data_dictionary_setup.ipynb
```

### Project Structure
```
employee_attrition_analysis/
├── notebooks/           # 7-stage analytical workflow
├── data/
│   ├── raw/            # Original HR dataset
│   └── processed/      # Cleaned, analysis-ready data
├── docs/
│   ├── stakeholders/   # Executive summaries, business deliverables
│   ├── modeling/       # Technical model documentation
│   ├── notes/          # Analysis insights and findings
│   └── reference/      # Data dictionary, methodological notes
└── reports/
    ├── figures/        # All visualizations (version-controlled)
    └── notebooks_md/   # Markdown exports for sharing
```

---

## 🎯 **Business Impact**

**Immediate Value:**
- **Risk Identification**: Model flags 72% of employees likely to leave
- **Cost Avoidance**: Early intervention prevents recruitment/training costs
- **Policy Guidance**: Feature importance informs HR strategy priorities

**Strategic Advantages:**
- **Data-Driven Retention**: Replace reactive hiring with proactive retention
- **Managerial Training**: Target support for high-risk departments (Sales/Support)
- **Workload Optimization**: Balance project assignments to reduce burnout

**Ethical Safeguards:**
- **Supportive Use Only**: Model recommendations guide assistance, not punishment
- **Bias Monitoring**: Regular auditing for fairness across demographics
- **Human Oversight**: Predictions supplement, never replace, managerial judgment

---

## 📄 **Key Deliverables**

- **[Executive Summary](docs/stakeholders/executive_summary_with_appendix.md)**: Business-focused findings with embedded visualizations
- **[Model Documentation](docs/modeling/)**: Technical specifications and validation results
- **[Data Dictionary](docs/reference/data_dictionary.md)**: Complete variable documentation
- **[Ethics Review](docs/notes/ethics_bias_review.md)**: Responsible AI assessment and deployment guidelines

---

**Author:** Katherine Ygbuhay
**Portfolio Component:** Google Advanced Data Analytics Certificate
**Completion:** October 2025