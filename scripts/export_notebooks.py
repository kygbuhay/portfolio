#!/usr/bin/env python3
"""
Export Jupyter notebooks to Markdown format into reports/notebooks_md/<notebook_stem>/,
preserving code, outputs, and properly handling images.

Behavior:
- If a target file already exists, we SKIP it by default (safe).
- Pass --force to overwrite existing files.
- Images are embedded as base64 or linked to external figure files if available.

Requirements:
- nbformat (standard in Jupyter environments)
- nbconvert (for markdown export)
"""

from __future__ import annotations

import re
import base64
from pathlib import Path
from typing import Optional
import subprocess
import sys

import nbformat
from nbconvert import MarkdownExporter

from src.paths import get_paths_from_notebook


def export_notebook_to_markdown(nb_path: Path, project_name: Optional[str] = None, force: bool = False) -> None:
    """
    Convert a Jupyter notebook to Markdown format and save to reports/notebooks_md/.

    Args:
        nb_path: Path to the .ipynb file
        project_name: Optional project name for path resolution
        force: Whether to overwrite existing files
    """
    if not nb_path.exists():
        raise FileNotFoundError(f"Notebook not found: {nb_path}")

    # Resolve project paths
    P = get_paths_from_notebook(project_name=project_name)

    # Create output directory: reports/notebooks_md/
    nb_stem = nb_path.stem
    out_dir = P.ROOT / "reports" / "notebooks_md"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Output file path
    md_file = out_dir / f"{nb_stem}.md"

    # Check if file exists and handle overwrite policy
    if md_file.exists() and not force:
        print(f"⏭️  Skipping {nb_stem} (already exists, use --force to overwrite)")
        return

    print(f"📝 Converting {nb_path.name} → {md_file.relative_to(P.ROOT)}")

    # Read the notebook
    nb = nbformat.read(nb_path, as_version=4)

    # Configure the markdown exporter
    md_exporter = MarkdownExporter()

    # Custom configuration for better output
    md_exporter.exclude_input_prompt = True
    md_exporter.exclude_output_prompt = True

    try:
        # Convert notebook to markdown
        (body, resources) = md_exporter.from_notebook_node(nb)

        # Post-process the markdown content
        body = post_process_markdown(body, nb_stem, out_dir, P)

        # Write the markdown file
        md_file.write_text(body, encoding='utf-8')

        print(f"  ✅ Exported to {md_file.relative_to(P.ROOT)}")

    except Exception as e:
        print(f"  ❌ Error converting {nb_stem}: {e}")
        raise


def post_process_markdown(content: str, nb_stem: str, out_dir: Path, P) -> str:
    """
    Post-process the markdown content to improve formatting and links.

    Args:
        content: Raw markdown content from nbconvert
        nb_stem: Notebook stem name
        out_dir: Output directory for this notebook
        P: Project paths object

    Returns:
        Processed markdown content
    """
    # Add a header with metadata
    header = f"""# {nb_stem.replace('_', ' ').title()}

**Exported from:** `{nb_stem}.ipynb`
**Generated:** {get_current_timestamp()}
**Project:** {P.ROOT.name}

---

"""

    # Clean up code block formatting
    content = re.sub(r'```python\n\n', '```python\n', content)
    content = re.sub(r'\n\n```', '\n```', content)

    # Fix image references to use relative paths if figures exist
    fig_dir = P.ROOT / "reports" / "figures" / nb_stem
    if fig_dir.exists():
        # Replace base64 images with links to figure files if they exist
        content = link_to_exported_figures(content, fig_dir, out_dir)

    return header + content


def link_to_exported_figures(content: str, fig_dir: Path, out_dir: Path) -> str:
    """
    Replace base64 image embeddings with links to exported figure files when available.
    """
    # Find all base64 image patterns
    img_pattern = r'!\[png\]\(data:image/png;base64,[A-Za-z0-9+/=]+\)'

    # Get list of available figure files
    if fig_dir.exists():
        figure_files = list(fig_dir.glob("*.png"))
        if figure_files:
            # For now, keep base64 but add a note about available figures
            figures_note = f"\n\n> **Note:** Exported figures for this notebook are available in `{fig_dir.relative_to(out_dir.parent.parent)}/`\n\n"
            content = figures_note + content

    return content


def save_extracted_images(outputs_dict: dict, out_dir: Path) -> None:
    """Save any images extracted by nbconvert to the output directory."""
    images_dir = out_dir / "images"

    for filename, data in outputs_dict.items():
        if filename.endswith(('.png', '.jpg', '.jpeg', '.svg')):
            images_dir.mkdir(exist_ok=True)

            # Save the image file
            img_path = images_dir / filename
            if isinstance(data, str):
                # Base64 encoded
                img_data = base64.b64decode(data)
                img_path.write_bytes(img_data)
            else:
                # Binary data
                img_path.write_bytes(data)

            print(f"  📷 Saved image: {img_path.relative_to(out_dir)}")


def get_current_timestamp() -> str:
    """Get current timestamp in a readable format."""
    from datetime import datetime
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# ---------- CLI ----------

if __name__ == "__main__":
    import argparse

    ap = argparse.ArgumentParser(description="Export Jupyter notebooks to Markdown with proper formatting.")
    ap.add_argument("notebook", type=str, help="Path to .ipynb file")
    ap.add_argument("--project", type=str, default=None, help="Project/case-study folder name (enclosing the notebook).")
    ap.add_argument("--force", action="store_true", help="Overwrite existing files with the same name.")
    args = ap.parse_args()

    # Check if nbconvert is available
    try:
        import nbconvert
    except ImportError:
        print("❌ nbconvert is required but not installed. Install with: pip install nbconvert")
        sys.exit(1)

    export_notebook_to_markdown(Path(args.notebook), project_name=args.project, force=args.force)