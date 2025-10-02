# src/viz_access.py
"""
Accessible visualization helpers (colorblind-friendly + high-contrast)

Quick start:
    from src.viz_access import quick_accessibility_setup
    quick_accessibility_setup()  # once per notebook

Extras:
    from src.viz_access import (
        apply_accessibility_theme, hatch_bars, add_value_labels,
        style_lines, CMAP_CONTINUOUS, assert_contrast_ok
    )
"""

from __future__ import annotations
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
from cycler import cycler

# Public constant: a good continuous colormap for heatmaps
CMAP_CONTINUOUS = "cividis"  # or "viridis"

def apply_accessibility_theme(context: str = "notebook") -> None:
    """
    Apply global, colorblind-safe styles and high-contrast settings.
    Call once per notebook/session.
    """
    cb_palette = sns.color_palette("colorblind")
    sns.set_theme(style="whitegrid", context=context)
    sns.set_palette(cb_palette)

    mpl.rcParams.update({
        "axes.facecolor": "white",
        "axes.edgecolor": "#333333",
        "axes.labelcolor": "#111111",
        "axes.linewidth": 0.8,
        "grid.color": "#DDDDDD",
        "grid.linestyle": "-",
        "grid.linewidth": 0.6,
        "xtick.color": "#111111",
        "ytick.color": "#111111",
        "figure.facecolor": "white",
        "legend.frameon": True,
        "legend.framealpha": 0.9,
        "legend.edgecolor": "#333333",
        "text.color": "#111111",
        # Combine color + linestyle so series are distinguishable without color alone
        "axes.prop_cycle": cycler(color=cb_palette) + cycler(
            linestyle=["-", "--", "-.", ":", "-", "--", "-.", ":", "-", "--"]
        ),
    })

def hatch_bars(ax: plt.Axes) -> plt.Axes:
    """Add alternating hatch patterns to bars for non-color cues."""
    hatches = ['/', '\\', 'x', '-', '+', 'o', 'O', '.', '*']
    for i, p in enumerate(getattr(ax, "patches", [])):
        try:
            p.set_hatch(hatches[i % len(hatches)])
        except Exception:
            pass
    return ax

def add_value_labels(ax: plt.Axes, fmt: str = '{:.0f}', fontsize: int = 10, color: str = "#111111") -> plt.Axes:
    """Put numeric labels on top of bars (bar/barh)."""
    for p in getattr(ax, "patches", []):
        if hasattr(p, "get_height"):
            val = p.get_height()
            ax.annotate(
                fmt.format(val),
                (p.get_x() + p.get_width()/2., val),
                ha='center', va='bottom',
                fontsize=fontsize, color=color,
                xytext=(0, 3), textcoords='offset points'
            )
    return ax

def style_lines(ax: plt.Axes) -> plt.Axes:
    """Add distinct markers to line plots to aid non-color differentiation."""
    markers = ['o', 's', '^', 'D', 'P', 'X', 'v', '<', '>', '*']
    for i, line in enumerate(ax.get_lines()):
        line.set_marker(markers[i % len(markers)])
        line.set_markersize(5)
    return ax

# --- WCAG contrast helpers ---

def _luminance(hex_color: str) -> float:
    hex_color = hex_color.lstrip("#")
    r, g, b = [int(hex_color[i:i+2], 16)/255.0 for i in (0, 2, 4)]
    def lin(c): return c/12.92 if c <= 0.03928 else ((c+0.055)/1.055)**2.4
    r, g, b = lin(r), lin(g), lin(b)
    return 0.2126*r + 0.7152*g + 0.0722*b

def contrast_ratio(fg: str = "#111111", bg: str = "#FFFFFF") -> float:
    L1, L2 = _luminance(fg), _luminance(bg)
    L1, L2 = max(L1, L2), min(L1, L2)
    return (L1 + 0.05) / (L2 + 0.05)

def assert_contrast_ok(fg: str = "#111111", bg: str = "#FFFFFF", level: str = "AA", large_text: bool = False) -> None:
    """
    WCAG 2.1 thresholds:
      - AA normal text: ≥ 4.5
      - AA large text (>=14pt bold or >=18pt): ≥ 3.0
      - AAA: 7.0 (normal), 4.5 (large)
    Prints a message with the calculated ratio.
    """
    threshold = 4.5
    if level == "AA" and large_text: threshold = 3.0
    if level == "AAA" and not large_text: threshold = 7.0
    if level == "AAA" and large_text: threshold = 4.5
    cr = contrast_ratio(fg, bg)
    if cr < threshold:
        print(f"⚠️  Contrast {cr:.2f} below {level}{' (large)' if large_text else ''} threshold {threshold}.")
    else:
        print(f"✅ Contrast {cr:.2f} meets {level}{' (large)' if large_text else ''}.")

# --- One-shot wrapper for easy use ---

def quick_accessibility_setup() -> None:
    """
    Apply accessibility defaults once per notebook:
    - Colorblind-safe palette
    - High-contrast axes/text
    - Sensible linestyle cycling
    """
    apply_accessibility_theme()
    print("🎨 Accessibility defaults applied (colorblind palette, high-contrast, safe colormap).")

__all__ = [
    "CMAP_CONTINUOUS",
    "apply_accessibility_theme",
    "quick_accessibility_setup",
    "hatch_bars",
    "add_value_labels",
    "style_lines",
    "contrast_ratio",
    "assert_contrast_ok",
]

