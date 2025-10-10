#!/usr/bin/env bash
set -euo pipefail

echo "▶ Running lineage-aware data dictionary generator..."
python make_lineage_data_dictionary.py || { echo "Failed: make_lineage_data_dictionary.py"; exit 1; }

echo "▶ Filling insights summary template with auto metrics..."
python insights_generator.py || { echo "Failed: insights_generator.py"; exit 1; }

echo "✅ Done."
echo "Outputs:"
ls -1 *_data_dictionary.md 2>/dev/null || true
ls -1 *_INTEGRATED_README.md 2>/dev/null || true
ls -1 insights_summary_filled.md 2>/dev/null || true
