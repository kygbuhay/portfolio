#!/usr/bin/env bash
# Interactive menu: pick case study -> pick one or more notebooks -> export figures
# - Recursively finds case studies (folder with notebooks/ and docs/)
# - Accepts multiple notebook indices like: 4 5 6
# - Prompts for overwrite only when figures already exist for that notebook

set -euo pipefail

# Resolve repo root and scripts dir (works no matter where you run it from)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"
PY="$SCRIPTS_DIR/export_figures.py"

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

# --- Has this notebook already exported figures?
has_existing_figs() {
  local PROJ_DIR="$1"
  local NB_PATH="$2"
  local NB_NAME
  NB_NAME="$(basename "$NB_PATH" .ipynb)"
  local FIG_DIR="$PROJ_DIR/reports/figures/$NB_NAME"
  [[ -d "$FIG_DIR" ]] && [[ -n "$(ls -A "$FIG_DIR" 2>/dev/null || true)" ]]
}

# --- Get timestamp of most recent exported figure
get_figs_timestamp() {
  local PROJ_DIR="$1"
  local NB_PATH="$2"
  local NB_NAME
  NB_NAME="$(basename "$NB_PATH" .ipynb)"
  local FIG_DIR="$PROJ_DIR/reports/figures/$NB_NAME"
  if [[ -d "$FIG_DIR" ]]; then
    # Get the newest file in the directory
    local NEWEST
    NEWEST=$(ls -t "$FIG_DIR" 2>/dev/null | head -n1)
    if [[ -n "$NEWEST" ]]; then
      date -r "$FIG_DIR/$NEWEST" "+%Y-%m-%d %H:%M"
    fi
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
  if has_existing_figs "$PROJ" "$NB"; then
    TIMESTAMP=$(get_figs_timestamp "$PROJ" "$NB")
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
  if has_existing_figs "$PROJ" "$NB"; then
    echo "  - $NB_NAME (will prompt to overwrite — existing figures found)"
  else
    echo "  - $NB_NAME (new export)"
  fi
done
echo

# Process each selected notebook
for NB in "${SELECTED[@]}"; do
  NB_NAME="$(basename "$NB" .ipynb)"
  if has_existing_figs "$PROJ" "$NB"; then
    if confirm_overwrite "⚠️  Figures already exist for $NB_NAME. Overwrite?"; then
      echo "→ Overwriting: $NB_NAME"
      python3 "$PY" "$NB" --project "$PROJECT_NAME"
    else
      echo "↩️  Skipping: $NB_NAME"
    fi
  else
    echo "→ Exporting: $NB_NAME"
    python3 "$PY" "$NB" --project "$PROJECT_NAME"
  fi
done

echo "✅ Done."

