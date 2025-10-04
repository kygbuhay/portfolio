"""
Portfolio source utilities for reproducible, accessible data analysis workflows.
"""

from .bootstrap import setup_notebook, write_notes
from .paths import get_paths_from_notebook, ProjectPaths
from .viz_access import quick_accessibility_setup
from .viz_helpers import pretty_label, apply_plot_rc_defaults, hist_individual
from .model_eval import (
    evaluate_classifier,
    plot_confusion_matrix,
    plot_roc_curve,
    plot_roc_curves_comparison,
    plot_feature_importance
)

__all__ = [
    # Setup & paths
    "setup_notebook",
    "write_notes",
    "get_paths_from_notebook",
    "ProjectPaths",
    # Visualization
    "quick_accessibility_setup",
    "pretty_label",
    "apply_plot_rc_defaults",
    "hist_individual",
    # Model evaluation
    "evaluate_classifier",
    "plot_confusion_matrix",
    "plot_roc_curve",
    "plot_roc_curves_comparison",
    "plot_feature_importance",
]
