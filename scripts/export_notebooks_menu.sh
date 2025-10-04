#!/usr/bin/env bash
# Interactive menu: pick case study -> pick one or more notebooks -> export to markdown
# - Recursively finds case studies (folder with notebooks/ and docs/)
# - Accepts multiple notebook indices like: 4 5 6
# - Prompts for overwrite only when markdown already exists for that notebook

set -euo pipefail

# Resolve repo root and scripts dir (works no matter where you run it from)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"
PY="$SCRIPTS_DIR/export_notebooks.py"

# --- Find projects recursively (any dir that contains notebooks/)
find_projects() {
  local ROOT_DIR="${1:-$ROOT}"
  # Find every 'notebooks' dir and take its parent as a project
  find "$ROOT_DIR" -type d -name notebooks -exec dirname {} \; 2>/dev/null | sort -u
}

# --- List notebooks in a project (flat list)
list_notebooks() {
  local PROJ_DIR="$1"
  find "$PROJ_DIR/notebooks" -maxdepth 1 -type f -name "*.ipynb" | sort
}

# --- Has this notebook already been exported to markdown?
has_existing_md() {
  local PROJ_DIR="$1"
  local NB_PATH="$2"
  local NB_NAME
  NB_NAME="$(basename "$NB_PATH" .ipynb)"
  local MD_FILE="$PROJ_DIR/reports/notebooks_md/$NB_NAME.md"
  [[ -f "$MD_FILE" ]]
}

# --- Get timestamp of exported markdown
get_md_timestamp() {
  local PROJ_DIR="$1"
  local NB_PATH="$2"
  local NB_NAME
  NB_NAME="$(basename "$NB_PATH" .ipynb)"
  local MD_FILE="$PROJ_DIR/reports/notebooks_md/$NB_NAME.md"
  if [[ -f "$MD_FILE" ]]; then
    date -r "$MD_FILE" "+%Y-%m-%d %H:%M"
  fi
}

# --- Prompt Y/N with default "No"
confirm_overwrite() {
  local prompt="$1"
  read -rp "$prompt [y/N]: " ans || true
  [[ "$ans" =~ ^[Yy]$ ]]
}

# -------- MAIN --------
PORTFOLIO_ROOT="${1:-$ROOT}"
mapfile -t PROJECTS < <(find_projects "$PORTFOLIO_ROOT")

if [[ ${#PROJECTS[@]} -eq 0 ]]; then
  echo "❌ No projects with notebooks/ found under: $PORTFOLIO_ROOT"
  exit 1
fi

echo "📂 Available projects:"
select PROJ in "${PROJECTS[@]}"; do
  [[ -n "${PROJ:-}" ]] && break
done

PROJECT_NAME="$(basename "$PROJ")"
NOTEBOOKS_DIR="$PROJ/notebooks"

mapfile -t NBS < <(list_notebooks "$PROJ")
if [[ ${#NBS[@]} -eq 0 ]]; then
  echo "❌ No notebooks found in $NOTEBOOKS_DIR"
  exit 1
fi

echo "📒 Notebooks in $PROJECT_NAME:"
i=1
for NB in "${NBS[@]}"; do
  NB_BASENAME="$(basename "$NB")"
  if has_existing_md "$PROJ" "$NB"; then
    TIMESTAMP=$(get_md_timestamp "$PROJ" "$NB")
    printf "  %2d) %s [exported: %s]\n" "$i" "$NB_BASENAME" "$TIMESTAMP"
  else
    printf "  %2d) %s\n" "$i" "$NB_BASENAME"
  fi
  ((i++))
done

echo
echo "Select one or more notebooks by number (space-separated, e.g., 4 5 6), 'all' for all notebooks, or 'q' to quit."
read -rp "> " SELECTION || { echo "Cancelled."; exit 1; }
[[ "$SELECTION" =~ ^[Qq]$ ]] && { echo "Cancelled."; exit 0; }

# Build list of selected notebook paths (dedup + preserve order typed)
declare -a SELECTED=()
declare -A SEEN

# Handle 'all' selection
if [[ "$SELECTION" =~ ^[Aa][Ll][Ll]$ ]]; then
  SELECTED=("${NBS[@]}")
else
  for tok in $SELECTION; do
    if [[ "$tok" =~ ^[0-9]+$ ]]; then
      idx=$((tok-1))
      if (( idx >= 0 && idx < ${#NBS[@]} )); then
        NB_PATH="${NBS[$idx]}"
        if [[ -z "${SEEN[$NB_PATH]:-}" ]]; then
          SELECTED+=("$NB_PATH")
          SEEN[$NB_PATH]=1
        fi
      else
        echo "⚠️  Ignoring out-of-range index: $tok"
      fi
    else
      echo "⚠️  Ignoring non-numeric token: $tok"
    fi
  done
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  echo "No valid selections. Exiting."
  exit 0
fi

echo
echo "🚀 Export plan:"
for NB in "${SELECTED[@]}"; do
  NB_NAME="$(basename "$NB" .ipynb)"
  if has_existing_md "$PROJ" "$NB"; then
    echo "  - $NB_NAME (will prompt to overwrite — existing markdown found)"
  else
    echo "  - $NB_NAME (new export)"
  fi
done
echo

# Check if nbconvert is available
if ! python3 -c "import nbconvert" 2>/dev/null; then
  echo "❌ nbconvert is required but not available."
  echo "Install with: pip install nbconvert"
  exit 1
fi

# Process each selected notebook
for NB in "${SELECTED[@]}"; do
  NB_NAME="$(basename "$NB" .ipynb)"
  if has_existing_md "$PROJ" "$NB"; then
    if confirm_overwrite "⚠️  Markdown already exists for $NB_NAME. Overwrite?"; then
      echo "→ Overwriting: $NB_NAME"
      python3 "$PY" "$NB" --project "$PROJECT_NAME" --force
    else
      echo "↩️  Skipping: $NB_NAME"
    fi
  else
    echo "→ Exporting: $NB_NAME"
    python3 "$PY" "$NB" --project "$PROJECT_NAME"
  fi
done

echo "✅ Done."