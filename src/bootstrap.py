# src/bootstrap.py
"""
Notebook bootstrap: style defaults, reproducibility, accessibility helper,
and easy access to per-project paths.
"""
from __future__ import annotations

import os
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from .paths import get_paths_from_notebook, ProjectPaths  # keep this import


def setup_notebook(
    raw_filename: str | None = None,
    proc_filename: str | None = None,
    load: str | None = None,   # "raw", "proc", or None
    project: str | None = None,
    verbose: bool = True,
) -> tuple[ProjectPaths, pd.DataFrame | None]:
    """
    Theme/seed/accessibility + resolve per-project paths.
    Optionally load the raw/processed dataframe.

    Args:
        raw_filename: name of the raw CSV under data/raw/ (required if load="raw")
        proc_filename: name of the processed CSV under data/processed/ (required if load="proc")
        load: "raw", "proc", or None (do not auto-load)
        project: optional project folder name to disambiguate when multiple
                 sibling projects exist (e.g., "employee_attrition_analysis").
                 If not provided, will use env var PORTFOLIO_PROJECT if set.
        verbose: print status lines

    Returns:
        (ProjectPaths, DataFrame|None)
    """
    # Display & plotting defaults
    pd.set_option("display.max_columns", 100)
    pd.set_option("display.width", 120)
    plt.rcParams.update({"figure.autolayout": True})
    sns.set_theme(style="whitegrid", palette="colorblind")
    np.random.seed(42)

    # Accessibility helper (optional)
    try:
        from src.viz_access import quick_accessibility_setup  # type: ignore
        quick_accessibility_setup()
        if verbose:
            print("✅ Accessibility defaults applied")
    except Exception as e:
        if verbose:
            print(f"ℹ️ Accessibility helper not loaded ({e}). Continuing.")

    # Allow environment override for project selection
    if project is None:
        project = os.getenv("PORTFOLIO_PROJECT", None)

    # Resolve per-project paths (supports project=...)
    P = get_paths_from_notebook(
        raw_filename=raw_filename,
        proc_filename=proc_filename,
        project_name=project,
    )

    if verbose:
        print(f"📁 Project root → {P.ROOT}")

    # Optional load
    df = None
    if load == "raw":
        if not P.RAW.exists():
            raise FileNotFoundError(
                f"RAW file not found at {P.RAW}.\n"
                "Hint: set project=\"your_project_name\" in setup_notebook(...) or "
                "export PORTFOLIO_PROJECT=your_project_name before running."
            )
        df = pd.read_csv(P.RAW)
        if verbose:
            print(f"✅ Loaded RAW:  {P.RAW.relative_to(P.ROOT)} | shape={df.shape}")
    elif load == "proc":
        if not P.PROC.exists():
            raise FileNotFoundError(
                f"Processed file not found at {P.PROC}.\n"
                "Hint: set project=\"your_project_name\" in setup_notebook(...) or "
                "export PORTFOLIO_PROJECT=your_project_name before running."
            )
        df = pd.read_csv(P.PROC)
        if verbose:
            print(f"✅ Loaded PROC: {P.PROC.relative_to(P.ROOT)} | shape={df.shape}")

    return P, df


def write_notes(P: ProjectPaths, name: str, text: str) -> Path:
    """Write a markdown note into docs/notes for the current project."""
    path = P.NOTES / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    print(f"📝 Wrote notes → {path.relative_to(P.ROOT)}")
    return path
