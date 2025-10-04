#!/usr/bin/env python3
"""
Export figures from a Jupyter notebook into reports/figures/<notebook_stem>/,
naming each image using the nearest preceding Markdown heading.

Behavior:
- If a target filename already exists, we SKIP it by default (safe).
- Pass --force to overwrite existing files.

Requirements:
- nbformat (standard in Jupyter environments)
"""

from __future__ import annotations

import re
import base64
from pathlib import Path
from typing import Dict, List, Tuple, Optional

import nbformat

from src.paths import get_paths_from_notebook


# ---------- helpers ----------

HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$")

def slugify(text: str, max_len: int = 80) -> str:
    """Make a safe, human-readable filename slug."""
    text = text.strip().lower()
    text = re.sub(r"[^\w\s-]+", "", text)         # drop non-word chars
    text = re.sub(r"[\s-]+", "_", text).strip("_") # spaces/dashes -> underscore
    if not text:
        text = "figure"
    return text[:max_len]

def find_headings_in_markdown(md_source: str) -> List[str]:
    """Return headings found in a markdown cell, top-to-bottom."""
    headings = []
    for line in md_source.splitlines():
        m = HEADING_RE.match(line)
        if m:
            headings.append(m.group(1).strip())
    return headings

def extract_plot_titles(code_source: str) -> List[str]:
    """Extract plot titles from matplotlib/seaborn/plotly code."""
    titles = []
    lines = code_source.splitlines()

    # Track whether we've seen hist_grid or boxplot to handle multiline cases
    in_boxplot = False
    boxplot_buffer = []

    for i, line in enumerate(lines):
        line_stripped = line.strip()

        # Check for hist_grid first
        if re.search(r'^hist_grid\(', line_stripped):
            # Check if it has explicit suptitle
            if 'suptitle=' in line_stripped:
                match = re.search(r'suptitle\s*=\s*["\']([^"\']+)["\']', line_stripped)
                if match:
                    titles.append(match.group(1))
                    continue
            # Otherwise use default
            titles.append("Numeric Feature Distributions")
            continue

        # Check for boxplot_by_target (can be multiline)
        if 'boxplot_by_target' in line_stripped:
            in_boxplot = True
            boxplot_buffer = [line]
            continue

        if in_boxplot:
            boxplot_buffer.append(line)
            if ')' in line:  # End of function call
                full_call = '\n'.join(boxplot_buffer)
                match = re.search(r'feature_cols\s*=\s*\[([^\]]+)\]', full_call, re.DOTALL)
                if match:
                    features_str = match.group(1)
                    features = re.findall(r'["\']([^"\']+)["\']', features_str)
                    for feat in features:
                        title = f"{feat.replace('_', ' ').title()} vs Attrition"
                        titles.append(title)
                in_boxplot = False
                boxplot_buffer = []
                continue

        # Other title patterns
        title_patterns = [
            (r'\.title\s*\(\s*["\']([^"\']+)["\']', 1),
            (r'\.set_title\s*\(\s*["\']([^"\']+)["\']', 1),
            (r'\.suptitle\s*\(\s*["\']([^"\']+)["\']', 1),
            (r'title\s*=\s*["\']([^"\']+)["\']', 1),
            (r'\.title\s*\(\s*[fF]["\']([^{"\'"]+)', 1),
            (r'\.set_title\s*\(\s*[fF]["\']([^{"\'"]+)', 1),
            (r'\.suptitle\s*\(\s*[fF]["\']([^{"\'"]+)', 1),
            (r'barplot_counts\([^,]+,\s*["\']([^"\']+)["\']', 1),
        ]

        for pattern_info in title_patterns:
            if isinstance(pattern_info, tuple):
                pattern, group = pattern_info
                match = re.search(pattern, line_stripped)
                if match:
                    titles.append(match.group(group).strip())
                    break

    return titles

def clean_heading_for_filename(heading: str) -> str:
    """Clean heading text to extract meaningful parts for filenames."""
    # Remove leading numbers and dots (e.g., "5." or "5.1")
    heading = re.sub(r'^\s*\d+\.?\s*', '', heading)

    # Remove common section prefixes
    prefixes_to_remove = [
        r'^\s*step\s+\d+:?\s*',
        r'^\s*part\s+\d+:?\s*',
        r'^\s*section\s+\d+:?\s*',
    ]

    for prefix in prefixes_to_remove:
        heading = re.sub(prefix, '', heading, flags=re.IGNORECASE)

    return heading.strip()

def next_unique_path(base: Path) -> Path:
    """If base exists, append _1, _2, ... until free."""
    if not base.exists():
        return base
    stem, suffix = base.stem, base.suffix
    i = 1
    while True:
        candidate = base.with_name(f"{stem}_{i}{suffix}")
        if not candidate.exists():
            return candidate
        i += 1


# ---------- core exporter ----------

def export_figures(nb_path: Path, project_name: Optional[str] = None, force: bool = False) -> None:
    """
    Extract image/png outputs from a notebook. Name each by the closest
    preceding markdown heading; if none, fall back to 'figure_N'.
    """
    if not nb_path.exists():
        raise FileNotFoundError(f"Notebook not found: {nb_path}")

    # Resolve project paths; only need P.FIGURES
    P = get_paths_from_notebook(project_name=project_name)
    out_dir = P.FIGURES / nb_path.stem

    nb = nbformat.read(nb_path, as_version=4)

    last_heading: Optional[str] = None
    counts_by_slug: Dict[str, int] = {}
    exported = 0

    print(f"📂 Checking {nb_path.name} for figures...")

    for cell in nb.cells:
        ctype = cell.get("cell_type", "")

        if ctype == "markdown":
            # Update 'last_heading' to the last heading in this markdown cell (if any)
            headings = find_headings_in_markdown(cell.get("source", ""))
            if headings:
                # Clean the heading to remove section numbers and get meaningful parts
                raw_heading = headings[-1]  # the closest for following cells
                last_heading = clean_heading_for_filename(raw_heading)

        elif ctype == "code":
            outputs = cell.get("outputs", []) or []
            # collect all image/png payloads from display_data/execute_result outputs
            png_payloads: List[bytes] = []
            for out in outputs:
                data = out.get("data") or {}
                if "image/png" in data:
                    b64 = data["image/png"]
                    # Sometimes it's already bytes; usually it's base64 str
                    if isinstance(b64, str):
                        img_bytes = base64.b64decode(b64)
                    else:
                        img_bytes = b64
                    png_payloads.append(img_bytes)

            # If this code cell has figures, try to extract plot titles from the code
            plot_titles = []
            if png_payloads:
                code_source = cell.get("source", "") if isinstance(cell.get("source", ""), str) else ''.join(cell.get("source", []))
                plot_titles = extract_plot_titles(code_source)

            # write each payload with a nice name
            for idx, img_bytes in enumerate(png_payloads):
                # Create output directory only when we have figures to export
                if not out_dir.exists():
                    out_dir.mkdir(parents=True, exist_ok=True)
                    print(f"📂 Exporting to {out_dir.relative_to(P.ROOT)}")

                # Determine base name with priority: plot title > cleaned heading > fallback
                title_to_use = None

                # 1. Try to use specific plot title if available (idx is 0-based now)
                if plot_titles and idx < len(plot_titles):
                    title_to_use = plot_titles[idx]

                # 2. Fall back to cleaned section heading
                if not title_to_use and last_heading:
                    title_to_use = last_heading

                # 3. Final fallback
                if not title_to_use:
                    title_to_use = "figure"

                slug = slugify(title_to_use)

                # If multiple images under same base name, add numbering
                if counts_by_slug.get(slug) is None:
                    counts_by_slug[slug] = 0
                counts_by_slug[slug] += 1

                # For readability, only suffix when > 1 for that slug overall or when duplicates exist
                suffix = f"_{counts_by_slug[slug]}" if counts_by_slug[slug] > 1 else ""
                target = out_dir / f"{slug}{suffix}.png"

                if target.exists() and not force:
                    # Try auto-unique without clobbering (e.g., when re-exporting after changes)
                    target = next_unique_path(target)

                target.write_bytes(img_bytes)
                exported += 1
                print(f"  ✅ Wrote {target.relative_to(P.ROOT)}")

    if exported == 0:
        print("  ℹ️  No figures found - skipping")
    else:
        print(f"✨ Done. Exported {exported} figure(s).")


# ---------- CLI ----------

if __name__ == "__main__":
    import argparse

    ap = argparse.ArgumentParser(description="Export figures from a Jupyter notebook with heading-based file names.")
    ap.add_argument("notebook", type=str, help="Path to .ipynb")
    ap.add_argument("--project", type=str, default=None, help="Project/case-study folder name (enclosing the notebook).")
    ap.add_argument("--force", action="store_true", help="Overwrite existing files with the same name.")
    args = ap.parse_args()

    export_figures(Path(args.notebook), project_name=args.project, force=args.force)
