from pathlib import Path
from dataclasses import dataclass
import os
import sys

@dataclass(frozen=True)
class ProjectPaths:
    ROOT: Path
    DATA: Path
    RAW: Path
    PROC: Path
    DOCS: Path
    NOTES: Path
    REPORTS: Path
    FIGURES: Path
    NOTEBOOKS: Path

def _ensure_on_sys_path(p: Path) -> None:
    sp = str(p.resolve())
    if sp not in sys.path:
        sys.path.append(sp)

def _resolve_project_root(project_name: str, root_hint: Path) -> Path:
    """
    Resolve the case-study root. Tries (in order):
      1) ENV var PORTFOLIO_PROJECT_ABS (absolute path)
      2) <repo_root>/coursework/google-advanced-data-analytics/<project_name>
      3) Any folder under repo root matching project_name that contains 'notebooks'
      4) Current working dir ancestors containing 'notebooks' and 'docs'
    """
    # 1) Explicit absolute override
    abs_env = os.environ.get("PORTFOLIO_PROJECT_ABS")
    if abs_env:
        p = Path(abs_env).expanduser().resolve()
        if (p / "notebooks").exists() and (p / "docs").exists():
            return p

    # 2) Canonical coursework path
    candidate = root_hint / "coursework" / "google-advanced-data-analytics" / project_name
    if (candidate / "notebooks").exists() and (candidate / "docs").exists():
        return candidate

    # 3) Search subtree for project_name with notebooks
    for p in root_hint.rglob(project_name):
        if p.is_dir() and (p / "notebooks").exists() and (p / "docs").exists():
            return p

    # 4) Walk upwards from CWD to find a case-study root
    cur = Path.cwd().resolve()
    while True:
        if (cur / "notebooks").exists() and (cur / "docs").exists():
            return cur
        if cur == cur.parent:
            break
        cur = cur.parent

    # If all else fails, fall back to coursework path (may 404 later)
    return candidate

def get_paths_from_notebook(
    project_name: str = None,
    raw_filename: str = None,
    proc_filename: str = None,
    root: Path = Path(__file__).resolve().parents[1],
) -> ProjectPaths:
    """
    Resolve standard project subpaths for a given case study.
    Optionally bind specific raw/processed filenames.

    If project_name is None, attempts to resolve from environment or CWD.
    """
    # If no project name, try environment or walk up from CWD
    if project_name is None:
        project_name = os.environ.get("PORTFOLIO_PROJECT", None)

    # If still None, try to detect from current working directory
    if project_name is None:
        cwd = Path.cwd()
        # Walk up to find a project root (has notebooks/ and docs/)
        cur = cwd
        while cur != cur.parent:
            if (cur / "notebooks").exists() and (cur / "docs").exists():
                project_name = cur.name
                break
            cur = cur.parent

    proj_root = _resolve_project_root(project_name, root)

    # Auto-create core dirs
    (proj_root / "data" / "raw").mkdir(parents=True, exist_ok=True)
    (proj_root / "data" / "processed").mkdir(parents=True, exist_ok=True)
    (proj_root / "docs" / "notes").mkdir(parents=True, exist_ok=True)
    (proj_root / "docs" / "reference").mkdir(parents=True, exist_ok=True)
    (proj_root / "docs" / "stakeholders").mkdir(parents=True, exist_ok=True)
    (proj_root / "reports" / "figures").mkdir(parents=True, exist_ok=True)

    # Ensure the repo root is importable for src/
    _ensure_on_sys_path(proj_root)

    raw_path  = proj_root / "data" / "raw"
    proc_path = proj_root / "data" / "processed"
    if raw_filename:
        raw_path = raw_path / raw_filename
    if proc_filename:
        proc_path = proc_path / proc_filename

    return ProjectPaths(
        ROOT      = proj_root,
        DATA      = proj_root / "data",
        RAW       = raw_path,
        PROC      = proc_path,
        DOCS      = proj_root / "docs",
        NOTES     = proj_root / "docs" / "notes",
        REPORTS   = proj_root / "reports",
        FIGURES   = proj_root / "reports" / "figures",
        NOTEBOOKS = proj_root / "notebooks",
    )

