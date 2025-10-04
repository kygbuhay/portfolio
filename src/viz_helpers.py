# src/viz_helpers.py
from __future__ import annotations
from typing import Iterable, Optional, Sequence

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib as mpl

# --- public helpers ----------------------------------------------------------

def pretty_label(name: str) -> str:
    """Convert snake_case to Title Case for plot titles/labels."""
    return name.replace("_", " ").title()

def adjust_xtick_labels(ax: plt.Axes, rotation_long: int = 45, length_threshold: int = 3) -> None:
    """
    Rotate x tick labels only if at least one label is 'long' (e.g., 'product_mng').
    - Short labels (≤ length_threshold) remain horizontal.
    """
    labels = [t.get_text() for t in ax.get_xticklabels()]
    if any(len(lbl) > length_threshold for lbl in labels):
        ax.tick_params(axis="x", rotation=rotation_long)
    else:
        ax.tick_params(axis="x", rotation=0)

def barplot_counts(series: pd.Series,
                   title: str,
                   ylabel: str = "Proportion",
                   normalize: bool = True,
                   edgecolor: str = "black") -> plt.Axes:
    """
    Clean bar chart for categorical distributions with accessibility-friendly defaults.
    Automatically handles long x-tick labels.
    """
    counts = series.value_counts(normalize=normalize)
    ax = counts.plot(kind="bar", edgecolor=edgecolor)
    ax.set_title(title)
    ax.set_ylabel(ylabel)
    ax.grid(axis="y", linestyle="--", alpha=0.5)
    adjust_xtick_labels(ax)
    plt.tight_layout()
    return ax

def hist_grid(df: pd.DataFrame,
              numeric_cols: Optional[Sequence[str]] = None,
              cols: int = 2,
              bins: int = 20,
              suptitle: str = "Numeric Feature Distributions",
              figsize_per_row: float = 5.0) -> None:
    """
    Grid of histograms (2 per row by default) with big suptitle and tidy spacing.
    """
    if numeric_cols is None:
        numeric_cols = df.select_dtypes(include="number").columns.tolist()

    n = len(numeric_cols)
    rows = (n + cols - 1) // cols
    fig, axes = plt.subplots(rows, cols, figsize=(14, figsize_per_row * rows))
    axes = axes.ravel() if n > 1 else [axes]

    for i, col in enumerate(numeric_cols):
        ax = axes[i]
        ax.hist(df[col].dropna(), bins=bins, edgecolor="black")
        ax.set_title(pretty_label(col))
        ax.grid(axis="y", linestyle="--", alpha=0.5)

    # Hide unused subplots if n is odd
    for j in range(i + 1, rows * cols):
        fig.delaxes(axes[j])

    fig.suptitle(suptitle, y=0.99, fontsize=24, fontweight="bold")
    fig.tight_layout(rect=[0, 0, 1, 0.975])
    plt.show()

def boxplot_by_target(df: pd.DataFrame,
                      feature_cols: Iterable[str],
                      target: str = "left",
                      xlabel: str = "Attrition (0 = stay, 1 = left)") -> None:
    """
    One boxplot per figure for clarity; Title Case titles; gridlines on Y.
    Silently skips features not present.
    """
    for col in feature_cols:
        if col not in df.columns:
            continue
        plt.figure(figsize=(7, 5))
        sns.boxplot(x=target, y=col, data=df)
        plt.title(f"{pretty_label(col)} vs Attrition")
        plt.xlabel(xlabel)
        plt.grid(axis="y", linestyle="--", alpha=0.5)
        plt.tight_layout()
        plt.show()

# --- optional: bump default font sizes once (kept light; bootstrap handles theme) ----
def apply_plot_rc_defaults() -> None:
    mpl.rcParams.update({
        "axes.titlesize": 16,
        "axes.labelsize": 13,
        "xtick.labelsize": 11,
        "ytick.labelsize": 11,
        "figure.titlesize": 22,
    })

def adjust_heatmap_labels(ax: plt.Axes, rotation_x: int = 45, rotation_y: int = 0) -> None:
    """
    Rotate heatmap tick labels for readability.
    - X labels (columns): typically long -> rotate by default (45°)
    - Y labels (rows): keep horizontal
    """
    ax.set_xticklabels(ax.get_xticklabels(), rotation=rotation_x, ha="right")
    ax.set_yticklabels(ax.get_yticklabels(), rotation=rotation_y)

def hist_individual(df: pd.DataFrame,
                    numeric_cols: Optional[Sequence[str]] = None,
                    bins: int = 20) -> None:
    """
    Create individual histogram figures (one per feature).
    Useful for stakeholder docs where you need to cherry-pick specific charts.

    Usage:
        # Generate individual histograms for stakeholder presentations
        hist_individual(df, numeric_cols=["satisfaction_level", "time_spend_company"])
    """
    if numeric_cols is None:
        numeric_cols = df.select_dtypes(include="number").columns.tolist()

    for col in numeric_cols:
        plt.figure(figsize=(7, 5))
        plt.hist(df[col].dropna(), bins=bins, edgecolor="black")
        plt.title(pretty_label(col))
        plt.xlabel(pretty_label(col))
        plt.ylabel("Frequency")
        plt.grid(axis="y", linestyle="--", alpha=0.5)
        plt.tight_layout()
        plt.show()
