"""
Model evaluation utilities for portfolio case studies.

Standardized functions for evaluating classification models with consistent metrics,
confusion matrices, ROC curves, and feature importance plots.
"""

from __future__ import annotations
from typing import Dict, Tuple, Optional
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score,
    confusion_matrix, ConfusionMatrixDisplay, roc_curve
)


def evaluate_classifier(
    name: str,
    model,
    X_val: pd.DataFrame | np.ndarray,
    y_val: pd.Series | np.ndarray
) -> Tuple[Dict[str, float], np.ndarray, Optional[np.ndarray]]:
    """
    Evaluate a classifier with standard metrics.

    Args:
        name: Model name for labeling
        model: Fitted sklearn model or pipeline
        X_val: Validation features
        y_val: Validation labels

    Returns:
        Tuple of (metrics_dict, predictions, probabilities)
        - metrics_dict: accuracy, precision, recall, f1, roc_auc
        - predictions: Binary predictions
        - probabilities: Class 1 probabilities (None if not available)
    """
    y_pred = model.predict(X_val)

    # Get probabilities if available
    if hasattr(model, "predict_proba"):
        y_prob = model.predict_proba(X_val)[:, 1]
    else:
        y_prob = None

    metrics = {
        "model": name,
        "accuracy": accuracy_score(y_val, y_pred),
        "precision": precision_score(y_val, y_pred, zero_division=0),
        "recall": recall_score(y_val, y_pred, zero_division=0),
        "f1": f1_score(y_val, y_pred, zero_division=0),
    }

    # Add ROC-AUC only if probabilities available
    if y_prob is not None:
        metrics["roc_auc"] = roc_auc_score(y_val, y_prob)
    else:
        metrics["roc_auc"] = np.nan

    return metrics, y_pred, y_prob


def plot_confusion_matrix(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    title: str = "Confusion Matrix",
    labels: Optional[list] = None,
    figsize: tuple = (6, 5)
) -> plt.Axes:
    """
    Plot a confusion matrix with clean formatting.

    Args:
        y_true: True labels
        y_pred: Predicted labels
        title: Plot title
        labels: Class labels for display
        figsize: Figure size

    Returns:
        Matplotlib axes object
    """
    cm = confusion_matrix(y_true, y_pred)

    fig, ax = plt.subplots(figsize=figsize)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=labels)
    disp.plot(ax=ax, cmap="Blues", values_format='d')

    ax.set_title(title)
    plt.tight_layout()

    return ax


def plot_roc_curve(
    y_true: np.ndarray,
    y_prob: np.ndarray,
    model_name: str = "Model",
    figsize: tuple = (7, 6)
) -> plt.Axes:
    """
    Plot ROC curve with AUC score.

    Args:
        y_true: True labels
        y_prob: Predicted probabilities for positive class
        model_name: Name for legend
        figsize: Figure size

    Returns:
        Matplotlib axes object
    """
    fpr, tpr, _ = roc_curve(y_true, y_prob)
    auc = roc_auc_score(y_true, y_prob)

    plt.figure(figsize=figsize)
    plt.plot(fpr, tpr, linewidth=2, label=f'{model_name} (AUC={auc:.3f})')
    plt.plot([0, 1], [0, 1], '--', color='gray', linewidth=1, label='Random')

    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title(f"ROC Curve — {model_name}")
    plt.legend(loc='lower right')
    plt.grid(alpha=0.3)
    plt.tight_layout()

    return plt.gca()


def plot_roc_curves_comparison(
    models_dict: Dict[str, Tuple[np.ndarray, np.ndarray]],
    title: str = "ROC Curve Comparison",
    figsize: tuple = (8, 6)
) -> plt.Axes:
    """
    Plot multiple ROC curves on the same figure for comparison.

    Args:
        models_dict: Dictionary of {model_name: (y_true, y_prob)}
        title: Plot title
        figsize: Figure size

    Returns:
        Matplotlib axes object
    """
    plt.figure(figsize=figsize)

    for name, (y_true, y_prob) in models_dict.items():
        fpr, tpr, _ = roc_curve(y_true, y_prob)
        auc = roc_auc_score(y_true, y_prob)
        plt.plot(fpr, tpr, linewidth=2, label=f'{name} (AUC={auc:.3f})')

    plt.plot([0, 1], [0, 1], '--', color='gray', linewidth=1, label='Random')
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title(title)
    plt.legend(loc='lower right')
    plt.grid(alpha=0.3)
    plt.tight_layout()

    return plt.gca()


def plot_feature_importance(
    model,
    feature_names: list,
    top_k: int = 20,
    title: str = "Feature Importances",
    figsize: tuple = (8, 6)
) -> plt.Axes:
    """
    Plot feature importances from a tree-based model.

    Args:
        model: Fitted model with feature_importances_ attribute
        feature_names: List of feature names
        top_k: Number of top features to display
        title: Plot title
        figsize: Figure size

    Returns:
        Matplotlib axes object
    """
    if not hasattr(model, 'feature_importances_'):
        raise AttributeError(f"Model {type(model)} does not have feature_importances_")

    importances = pd.Series(model.feature_importances_, index=feature_names)
    importances = importances.sort_values(ascending=False).head(top_k)

    plt.figure(figsize=figsize)
    ax = sns.barplot(x=importances.values, y=importances.index, orient='h', edgecolor='black')
    ax.set_xlabel("Importance")
    ax.set_ylabel("Feature")
    ax.set_title(title)
    plt.tight_layout()

    return ax
