#!/usr/bin/env bash
# === Config: set your portfolio root where .venv lives ===
PORTFOLIO_ROOT="$HOME/Documents/career/capstone-control-center/portfolio"

# Sanity checks
if [ ! -d "$PORTFOLIO_ROOT" ]; then
  echo "❌ Portfolio root not found: $PORTFOLIO_ROOT"; exit 1
fi
if [ ! -f "$PORTFOLIO_ROOT/.venv/bin/activate" ]; then
  echo "❌ .venv not found at $PORTFOLIO_ROOT/.venv"; exit 1
fi

# === Ask user for inputs ===
echo "📂 Enter destination directory (relative to portfolio root):"
read -r DEST_DIR
DEST_DIR="${DEST_DIR:-reports}"   # default = reports/

echo "📄 Enter notebook base name (leave blank for timestamp):"
read -r NB_BASENAME
if [ -z "$NB_BASENAME" ]; then
  NB_BASENAME="notebook_$(date +%Y-%m-%d_%H-%M-%S)"
fi
NB_NAME="$NB_BASENAME.ipynb"

# Resolve destination to absolute path
case "$DEST_DIR" in
  /*) TARGET_DIR="$DEST_DIR" ;;
  *)  TARGET_DIR="$PORTFOLIO_ROOT/$DEST_DIR" ;;
esac

# Activate venv
# shellcheck source=/dev/null
source "$PORTFOLIO_ROOT/.venv/bin/activate" || { echo "❌ Failed to activate venv"; exit 1; }

# Ensure destination exists
mkdir -p "$TARGET_DIR" || { echo "❌ Cannot create $TARGET_DIR"; exit 1; }

NB_PATH="$TARGET_DIR/$NB_NAME"

# Create a minimal valid notebook
python - "$NB_PATH" <<'PY'
import json, os, sys
path = sys.argv[1]
nb = {
  "cells": [
    {"cell_type": "markdown", "metadata": {}, "source": ["# New Notebook\n\n"]},
    {"cell_type": "code", "metadata": {}, "source": ["# %%\n# Your code here\n"], "outputs": [], "execution_count": None},
  ],
  "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}},
  "nbformat": 4, "nbformat_minor": 5
}
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f: json.dump(nb, f)
print(f"✨ Created: {path}")
PY

# Launch Jupyter Lab at the new notebook
exec jupyter lab "$NB_PATH"

