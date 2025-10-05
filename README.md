# Data Analytics & Business Intelligence Portfolio

***Professional case studies demonstrating end-to-end data science capabilities with business impact focus***

**Author:** Katherine Ygbuhay
**Portfolio Status:** Active & Production-Ready
**Technical Stack:** Python, Jupyter, Git, Professional Automation
**Business Focus:** HR Analytics, Content Moderation, Customer Intelligence

---

## 🎯 **Portfolio Overview**

This repository showcases **enterprise-grade data science workflows** through comprehensive case studies that demonstrate technical excellence, business acumen, and responsible AI practices. Each project follows professional standards with reproducible pipelines, stakeholder deliverables, and ethical considerations.

**What Sets This Portfolio Apart:**
- ✅ **Professional notebook templates** with business-focused documentation
- ✅ **Automated workflow tools** for global accessibility and reproducibility
- ✅ **Stakeholder-ready deliverables** including executive summaries with embedded visualizations
- ✅ **Responsible AI practices** with ethics reviews and bias assessments
- ✅ **Production infrastructure** with reusable utilities and version control

---

## 📊 **Featured Case Studies**

*🔍 [**View Complete Methodology Framework →**](METHODOLOGY_SHOWCASE.md)*

### 🏆 **Employee Attrition Analysis**
*Comprehensive HR analytics to identify turnover drivers and develop predictive retention strategies*

**Business Impact:** 85% ROC-AUC model identifying 72% of at-risk employees
**Technical Achievement:** 7-stage analytical workflow with ethics review
**Key Insight:** Satisfaction level is the strongest predictor; department disparities revealed

[**Explore Case Study →**](coursework/google-advanced-data-analytics/employee_attrition_analysis/)

---

### 📱 **TikTok Claims Classification**
*Machine learning model to classify content as factual claims vs. subjective opinions for content moderation*

**Business Impact:** Automated content classification improving moderation efficiency
**Technical Achievement:** Advanced feature engineering with n-gram text analysis
**Key Insight:** Engagement metrics prove more predictive than content length

[**Explore Case Study →**](coursework/google-advanced-data-analytics/content_moderation_claims_classification/)

---

### 📞 **Call Center Customer Satisfaction**
*BI dashboard analysis identifying factors driving customer satisfaction and first-call resolution*

**Business Impact:** Actionable insights for reducing churn and improving service quality
**Technical Achievement:** Interactive dashboards with drill-down capabilities
**Key Focus:** Operational analytics and customer experience optimization

[**Explore Case Study →**](coursework/google-business-intelligence/call_center_customer_satisfaction/)

---

### 🤖 **AI Workplace Productivity Analysis**
*Comprehensive analysis measuring the impact of AI tools on workplace productivity and ROI*

**Business Impact:** Data-driven insights for AI adoption and productivity measurement
**Technical Achievement:** Multi-dimensional productivity metrics and trend analysis
**Key Focus:** Technology impact assessment and business intelligence

[**Explore Case Study →**](coursework/google-data-analytics/ai_workplace_productivity_analysis/)

---

## 🛠 **Professional Infrastructure**

This portfolio features **production-grade automation** and **enterprise development practices**:

### **Global Command System**
Access portfolio tools from anywhere on your system:

```bash
# Notebook creation with professional templates
newnb          # Create new professional notebook
nb             # Short alias for newnb

# Jupyter workflows
jn             # Launch Jupyter with case study selection
jup            # Alternative to jn

# Export & sharing
exportnb       # Export notebooks to markdown
exportfigs     # Export figures from notebooks

# Navigation
portfolio      # Jump to portfolio directory
pf             # Short alias for portfolio
pfs            # Show portfolio status and commands
```

### **Automated Notebook Templates**
- **Professional headers** with business value statements
- **Structured workflows** (Objective → Approach → Outputs → Prerequisites)
- **Case study integration** with bootstrap utilities and accessibility defaults
- **Current date auto-population** eliminating manual updates

### **Reusable Utilities (`src/`)**
- **`bootstrap.py`**: Project setup, path management, accessibility defaults
- **`viz_helpers.py`**: Colorblind-friendly visualizations, professional styling
- **`model_eval.py`**: Standardized model evaluation and comparison utilities
- **`paths.py`**: Dynamic project path resolution for portability

---

## 📂 **Repository Architecture**

```
portfolio/
├── coursework/                  # Professional case studies
│   ├── google-advanced-data-analytics/
│   │   ├── employee_attrition_analysis/     # 🏆 Featured: HR Analytics
│   │   └── content_moderation_claims_classification/  # 📱 Featured: ML Classification
│   ├── google-business-intelligence/
│   │   └── call_center_customer_satisfaction/         # 📞 Featured: BI Dashboard
│   └── google-data-analytics/
│       └── ai_workplace_productivity_analysis/        # 🤖 Featured: Productivity Analysis
│
├── src/                        # Reusable utilities & professional infrastructure
│   ├── bootstrap.py           # Project setup, accessibility, path management
│   ├── viz_helpers.py         # Professional visualizations, colorblind-friendly
│   ├── model_eval.py          # Standardized model evaluation utilities
│   └── paths.py               # Dynamic project path resolution
│
├── scripts/                   # Automation & global command system
│   ├── new_notebook.sh        # Professional notebook templates
│   ├── jn                     # Jupyter launcher with case study selection
│   ├── export_notebooks_menu.sh    # Automated markdown export
│   ├── export_figures_menu.sh      # Figure extraction pipeline
│   └── setup_global_access.sh     # Global command installation
│
└── showcase/                  # Independent projects (future expansion)
```

---

## 🚀 **Quick Start**

### **Option 1: Global Commands (Recommended)**
```bash
# One-time setup for global access
./scripts/setup_global_access.sh

# Then use from anywhere:
newnb          # Create professional notebook
jn             # Launch Jupyter with case study selection
exportnb       # Export notebooks to markdown
```

### **Option 2: Local Development**
```bash
# Clone and setup
git clone https://github.com/kygbuhay/portfolio.git
cd portfolio

# Install portfolio utilities
python -m venv .venv
source .venv/bin/activate
pip install -e .

# Launch case study
jn  # Interactive case study selection
```

---

## 📈 **Technical Excellence Demonstrated**

### **Data Science Capabilities**
- **End-to-End Workflows**: Data cleaning → EDA → Modeling → Ethics → Deployment
- **Advanced Modeling**: Random Forest, XGBoost, Logistic Regression with hyperparameter tuning
- **Statistical Rigor**: Cross-validation, ROC-AUC optimization, precision-recall analysis
- **Feature Engineering**: Text analysis, categorical encoding, correlation analysis

### **Business Intelligence Skills**
- **Stakeholder Communication**: Executive summaries with embedded visualizations
- **Actionable Insights**: Business recommendations with measurable impact
- **Risk Assessment**: Model interpretability and ethical deployment considerations
- **Cost-Benefit Analysis**: ROI calculations and business case development

### **Professional Development Practices**
- **Version Control**: Git workflows with proper commit attribution
- **Reproducibility**: Virtual environments, requirements management, automated pipelines
- **Documentation**: Professional README files, data dictionaries, methodology notes
- **Accessibility**: Colorblind-friendly visualizations, inclusive design principles

---

## 🎯 **Portfolio Highlights**

| Metric | Achievement |
|--------|-------------|
| **Model Performance** | 85%+ ROC-AUC across classification tasks |
| **Business Impact** | 72% at-risk employee identification accuracy |
| **Technical Depth** | 7-stage analytical workflows with ethics reviews |
| **Documentation** | Professional templates with stakeholder deliverables |
| **Automation** | Global command system with one-click workflows |
| **Reproducibility** | 100% version-controlled with automated exports |

---

## 📞 **Contact & Collaboration**

**Katherine Ygbuhay**
📧 Professional inquiries welcome
💼 Open to data science and business intelligence opportunities
🔗 [GitHub Portfolio](https://github.com/kygbuhay/portfolio) • [Case Study Examples](coursework/)

---

**Portfolio Infrastructure:** Production-ready automation with global command access
**Last Updated:** October 2025
**Status:** Active development with continuous improvement