#!/bin/bash
# Run Pass-1 inventory, verify outputs, then generate the 2023 ∩ 2024 column intersection.
# Paths are relative to THIS script's directory.

set -u  # fail on unset vars
set -o pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RAW_DIR="$HERE/../../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/raw"
DOCS_DIR="$HERE/../../coursework/google-data-analytics/ai_workplace_productivity_analysis/docs"
DOCS_DIR="$(realpath "$DOCS_DIR")"

echo "==> Running Pass-1 Data Inventory..."
python "$HERE/data_inventory_master_pass1.py" \
  --csv2023 "$RAW_DIR/stackoverflow_2023.csv" \
  --csv2024 "$RAW_DIR/stackoverflow_2024.csv" \
  --csv2025 "$RAW_DIR/stackoverflow_2025.csv" \
  --outdir "$DOCS_DIR"

echo
echo "==> Verifying Pass-1 outputs exist..."
COMBINED="$DOCS_DIR/data_dictionary.json"
Y23="$DOCS_DIR/data_dictionary_2023.json"
Y24="$DOCS_DIR/data_dictionary_2024.json"

missing=0
for f in "$COMBINED" "$Y23" "$Y24"; do
  if [[ ! -f "$f" ]]; then
    echo "  ❌ Missing: $f"
    missing=1
  else
    echo "  ✅ Found:   $f"
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "ERROR: Required JSONs not found. Pass-1 likely failed earlier. Check console errors above."
  exit 1
fi

echo
echo "==> Generating Baseline Column Intersection (2023 ∩ 2024) ..."
python "$HERE/generate_column_intersection.py" --docsdir "$DOCS_DIR"

echo
echo "==> Generating Comprehensive Analysis (All 3 Years) ..."
python "$HERE/generate_comprehensive_analysis.py" --docsdir "$DOCS_DIR"

echo
echo "==> Generating Cleaned Datasets & BigQuery Schemas ..."
python "$HERE/generate_cleaned_datasets.py" --raw-dir "$RAW_DIR" --output-dir "$RAW_DIR/../processed"

echo
echo "==> Complete Data Pipeline Finished! 🎉"
echo "📊 Analysis outputs in: $DOCS_DIR"
echo "   📄 column_mapping.md - Full availability matrix"
echo "   📄 column_intersection.md - 2023 ∩ 2024 baseline"
echo "   📄 comprehensive_column_analysis.md - EDA strategy & SQL templates"
echo "   📄 sql_column_reference.sql - Ready-to-use SQL column lists"
echo "   📄 data_dictionary.json - Complete technical metadata"
echo
echo "💾 Processed datasets in: $RAW_DIR/../processed"
echo "   📄 2023_stackoverflow_cleaned.csv - Fixed encoding & BigQuery ready"
echo "   📄 2024_stackoverflow_cleaned.csv - Fixed encoding & BigQuery ready"
echo "   📄 2025_stackoverflow_cleaned.csv - Fixed encoding & BigQuery ready"
echo "   📄 *_stackoverflow_schema.json - BigQuery upload schemas"
echo "   📄 BIGQUERY_UPLOAD_INSTRUCTIONS.md - Step-by-step upload guide"
echo
echo "🚀 Ready for EDA & BigQuery Upload! Check the instructions file for next steps."
