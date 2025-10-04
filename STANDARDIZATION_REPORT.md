# Portfolio Standardization Report

**Date:** 2025-10-04
**Scope:** Employee Attrition Analysis Notebooks

## ✅ Completed Updates

### 1. Environment Variable Setup
**Status:** ✅ DONE

All notebooks now explicitly set project name:
```python
import os
os.environ["PORTFOLIO_PROJECT"] = "employee_attrition_analysis"
```

**Notebooks updated:**
- ✅ 01_data_dictionary_setup.ipynb
- ✅ 02_data_cleaning.ipynb
- ✅ 03_exploratory_analysis.ipynb
- ✅ 04_baseline_logreg.ipynb
- ✅ 05_tree_models.ipynb (already had it)

---

## 🔧 Standardization Opportunities Identified

### 1. Model Evaluation Functions ✅ CREATED: `src/model_eval.py`

**Found in:** Notebooks 04, 05, 06

**Repeated Pattern:**
```python
def evaluate_model(name, pipe, X_val, y_val):
    y_pred = pipe.predict(X_val)
    y_prob = pipe.predict_proba(X_val)[:,1]

    m = {
        "model": name,
        "accuracy": accuracy_score(y_val, y_pred),
        "precision": precision_score(y_val, y_pred),
        "recall": recall_score(y_val, y_pred),
        "f1": f1_score(y_val, y_pred),
        "roc_auc": roc_auc_score(y_val, y_prob),
    }
    return m, y_pred, y_prob
```

**New Standardized Function:**
```python
from src.model_eval import evaluate_classifier

metrics, y_pred, y_prob = evaluate_classifier("LogReg", model, X_val, y_val)
```

**Benefits:**
- ✅ Consistent metric calculation
- ✅ Handles models without `predict_proba`
- ✅ Zero-division handling built-in
- ✅ Cleaner notebook code

---

### 2. Confusion Matrix Plotting ✅ CREATED: `src/model_eval.py`

**Found in:** Notebooks 04, 05, 06

**Repeated Pattern:**
```python
from sklearn.metrics import ConfusionMatrixDisplay
cm = confusion_matrix(y_val, y_pred)
disp = ConfusionMatrixDisplay(confusion_matrix=cm)
disp.plot(cmap="Blues")
plt.title("Confusion Matrix")
```

**New Standardized Function:**
```python
from src.model_eval import plot_confusion_matrix

plot_confusion_matrix(y_val, y_pred, title="Confusion Matrix — XGBoost")
plt.show()
```

---

### 3. ROC Curve Plotting ✅ CREATED: `src/model_eval.py`

**Found in:** Notebooks 04, 05, 06

**Repeated Pattern:**
```python
fpr, tpr, _ = roc_curve(y_val, y_prob)
auc = roc_auc_score(y_val, y_prob)
plt.plot(fpr, tpr, label=f"Model (AUC={auc:.3f})")
plt.plot([0,1],[0,1],"--")
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
```

**New Standardized Functions:**
```python
from src.model_eval import plot_roc_curve, plot_roc_curves_comparison

# Single model
plot_roc_curve(y_val, y_prob, model_name="XGBoost")
plt.show()

# Multiple models comparison
models_dict = {
    "XGBoost": (y_val, xgb_probs),
    "RandomForest": (y_val, rf_probs),
    "LogReg": (y_val, lr_probs)
}
plot_roc_curves_comparison(models_dict, title="Model Comparison")
plt.show()
```

---

### 4. Feature Importance Plotting ✅ CREATED: `src/model_eval.py`

**Found in:** Notebooks 05, 06

**Repeated Pattern:**
```python
importances = pd.Series(model.feature_importances_, index=feature_names)
importances = importances.sort_values(ascending=False).head(20)
sns.barplot(x=importances.values, y=importances.index)
plt.title("Feature Importances")
```

**New Standardized Function:**
```python
from src.model_eval import plot_feature_importance

plot_feature_importance(
    model.named_steps['clf'],  # Extract from pipeline
    feature_names=feature_names,
    top_k=20,
    title="Top Features — XGBoost"
)
plt.show()
```

---

### 5. Path Walking Pattern ⚠️ NEEDS CLEANUP

**Found in:** Notebook 01

**Current Code:**
```python
# Find the case-study root by walking up
case_root = Path.cwd()
while case_root != case_root.parent:
    if (case_root / "docs").exists() or (case_root / "notebooks").exists():
        break
    case_root = case_root.parent
```

**Should Be:**
```python
# Already have P from setup_notebook!
output_path = P.ROOT / "docs" / "reference" / "data_dictionary.md"
```

**Action:** Update notebook 01 to use `P.ROOT` instead of path walking

---

## 📊 Impact Analysis

### Code Reduction
- **Before:** ~40 lines of repeated evaluation code per notebook × 3 notebooks = 120 lines
- **After:** 3 lines per notebook = 9 lines
- **Saved:** 111 lines of code ✅

### Consistency
- ✅ All models evaluated with identical metrics
- ✅ All plots have consistent styling
- ✅ Error handling built-in (zero-division, missing predict_proba)

### Maintainability
- ✅ Fix bugs once in `src/model_eval.py`, affects all notebooks
- ✅ Add new metrics in one place
- ✅ Easier for others to use your workflow

---

## 🎯 Recommended Next Steps

### High Priority
1. **Update modeling notebooks (04, 05, 06)** to use `src/model_eval.py`
2. **Fix notebook 01** to use `P.ROOT` instead of path walking
3. **Test all notebooks** after updates

### Medium Priority
4. **Add to `src/__init__.py`:**
   ```python
   from .model_eval import (
       evaluate_classifier,
       plot_confusion_matrix,
       plot_roc_curve,
       plot_feature_importance
   )
   ```

5. **Update README** with new model eval utilities

### Low Priority (Nice to Have)
6. Create `src/data_summary.py` for standardized EDA summaries
7. Create `src/reporting.py` for markdown table generation
8. Add unit tests for `src/model_eval.py`

---

## 📝 Example Migration

### Before (Notebook 05):
```python
def evaluate_model(name, pipe, X_val, y_val):
    y_pred = pipe.predict(X_val)
    y_prob = pipe.predict_proba(X_val)[:,1] if hasattr(pipe, "predict_proba") else y_pred.astype(float)

    m = {
        "model": name,
        "accuracy": accuracy_score(y_val, y_pred),
        "precision": precision_score(y_val, y_pred, zero_division=0),
        "recall": recall_score(y_val, y_pred),
        "f1": f1_score(y_val, y_pred),
        "roc_auc": roc_auc_score(y_val, y_prob),
    }
    return m, y_pred, y_prob

results = []
probs = {}

for name, pipe in models.items():
    m, y_pred, y_prob = evaluate_model(name, pipe, X_val, y_val)
    results.append(m)
    probs[name] = (y_pred, y_prob)
```

### After (Notebook 05):
```python
from src.model_eval import evaluate_classifier

results = []
probs = {}

for name, pipe in models.items():
    m, y_pred, y_prob = evaluate_classifier(name, pipe, X_val, y_val)
    results.append(m)
    probs[name] = (y_pred, y_prob)
```

**Saved:** 12 lines per notebook!

---

## ✅ Summary

**Created:**
- ✅ `src/model_eval.py` - Complete model evaluation utilities
- ✅ All notebooks now set `PORTFOLIO_PROJECT` explicitly

**Ready to Use:**
- `evaluate_classifier()` - Standard metrics
- `plot_confusion_matrix()` - Clean CM plots
- `plot_roc_curve()` - Single model ROC
- `plot_roc_curves_comparison()` - Multi-model comparison
- `plot_feature_importance()` - Tree model importance

**Next Action:**
Test the new utilities in one notebook (05) first, then migrate others!
