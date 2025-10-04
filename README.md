# Data Analytics & Business Intelligence Portfolio  

This repository contains a collection of case studies that demonstrate my skills in data analytics, business intelligence, and stakeholder communication.  
Projects are organized into two sections:  

1. **Coursework Case Studies** — Projects completed through Google/Coursera programs, polished and reframed for business impact.  
2. **Showcase Case Studies** — Independent projects (in progress) that explore real-world business problems.  

---

## 📂 Repository Structure

```
portfolio/
├── src/                         # shared reusable modules (data_cleaning, viz_access, etc.)
│
├── coursework/                  # certificate & training case studies
│   ├── google-advanced-data-analytics/
│   │   ├── employee_attrition_analysis/
│   │   └── content_moderation_claims_classification/
│   ├── google-business-intelligence/
│   │   └── call_center_customer_satisfaction/
│   └── google-data-analytics/
│       └── ai_workplace_productivity_analysis/
│
└── showcase/                    # custom portfolio projects
    ├── [future_case_study_1]/
    └── [future_case_study_2]/
```
---

## 📊 Coursework Case Studies  

### **Employee Attrition Analysis** (`/coursework/google-advanced-data-analytics/employee_attrition_analysis/`)  
Analyzes HR data to identify key drivers of employee turnover. Provides actionable insights to improve retention strategies and reduce attrition costs.  

### **Content Moderation — Claims Classification** (`/coursework/google-advanced-data-analytics/content_moderation_claims_classification/`)  
Builds a machine learning model to classify TikTok content as factual claims or subjective opinions, improving moderation efficiency and trust & safety outcomes.  

### **Call Center Customer Satisfaction** (`/coursework/google-business-intelligence/call_center_customer_satisfaction/`)  
Explores customer service call resolution (CRS) metrics to identify factors driving customer satisfaction. Offers recommendations to improve first-call resolution and reduce churn.  

### **AI Workplace Productivity Analysis** (`/coursework/google-data-analytics/ai_workplace_productivity_analysis/`)  
Develops a BI dashboard to measure and visualize the impact of AI tools on workplace productivity, helping decision-makers understand adoption and ROI.  

---

## 🌟 Showcase Case Studies (Coming Soon)  

This section will feature independent projects that extend beyond coursework, focused on real-world datasets and business impact. Planned areas include:  
- Trust & Safety dashboards  
- Customer lifetime value (CLV) modeling  
- Operational analytics for SaaS growth metrics  

---

## 🛠 Tools & Technologies

- **Languages:** Python (pandas, scikit-learn, matplotlib, seaborn)
- **Visualization & BI:** Tableau, Looker Studio, Plotly
- **Collaboration:** Jupyter Notebooks, Markdown
- **Version Control:** Git/GitHub

---

## 🚀 Setup for Local Development

### Prerequisites
- Python 3.8+
- Jupyter Lab/Notebook
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/portfolio.git
   cd portfolio
   ```

2. **Create and activate virtual environment:**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install the portfolio utilities:**
   ```bash
   pip install -e .
   ```

4. **Launch Jupyter:**
   ```bash
   jupyter lab
   ```

### Using Portfolio Utilities

The `src/` directory contains reusable Python modules for all case studies:

```python
from src.bootstrap import setup_notebook, write_notes
from src.viz_access import quick_accessibility_setup
from src.viz_helpers import pretty_label, barplot_counts

# Setup notebook with accessibility and project paths
P, df = setup_notebook(
    raw_filename="your_data_raw.csv",
    proc_filename="your_data_cleaned.csv",
    load="proc",
    project="your_case_study_name"
)
```

### Optional: Shell Convenience Scripts

For easier workflow, you can add these aliases to your shell config (`.bashrc`, `.zshrc`, etc.):

```bash
# Navigate to portfolio root first, then add:
alias exportnb='./scripts/export_notebooks_menu.sh'
alias exportfigs='./scripts/export_figures_menu.sh'
alias newnb='./scripts/new_notebook.sh'
```

Or use the Makefile commands (see below).

### Makefile Commands

For cross-platform compatibility, use these `make` commands:

```bash
make install              # Install portfolio utilities
make export-notebooks     # Export notebooks to markdown
make export-figures       # Export figures from notebooks
make new-notebook         # Create a new notebook interactively
```

---

## 📁 Case Study Structure

Each case study follows a consistent structure:

```
case_study_name/
├── notebooks/           # Jupyter notebooks (numbered workflow)
├── data/
│   ├── raw/            # Original datasets
│   └── processed/      # Cleaned datasets
├── docs/
│   ├── notes/          # Analysis notes & findings
│   ├── modeling/       # Model results & summaries
│   └── stakeholders/   # Business-facing deliverables
└── reports/
    ├── figures/        # Exported visualizations
    └── notebooks_md/   # Markdown versions of notebooks
```

---

## 👩‍💻 Author

**Katherine Ygbuhay**
Data Analytics & BI Portfolio — 2025

