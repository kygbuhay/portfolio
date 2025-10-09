#!/usr/bin/env python3
"""
Generate a simple Column Intersection for Baseline (2023 ∩ 2024)

Reads the per-year JSONs created by the Pass-1 inventory script:
  docs/data_dictionary_2023.json
  docs/data_dictionary_2024.json

Writes:
  docs/column_intersection.md  — columns present in BOTH years
"""

import json
from pathlib import Path
import argparse

def load_cols(json_path: Path):
    data = json.loads(json_path.read_text(encoding='utf-8'))
    if not data.get('loaded_ok'):
        return set(), f"Year {data.get('year')} not loaded: {data.get('error','unknown')}"
    cols = {c['name'] for c in data.get('columns', [])}
    return cols, None

def write_md(cols, out_md: Path, note_2023=None, note_2024=None):
    header = "# Baseline Column Intersection (2023 ∩ 2024)\n\n"
    notes = ""
    if note_2023:
        notes += f"> 2023 note: {note_2023}\n\n"
    if note_2024:
        notes += f"> 2024 note: {note_2024}\n\n"
    table_header = "| Column Name |\n|-------------|\n"
    rows = "\n".join(f"| `{c}` |" for c in sorted(cols))
    out_md.parent.mkdir(parents=True, exist_ok=True)
    out_md.write_text(header + notes + table_header + rows + "\n", encoding='utf-8')

def main():
    ap = argparse.ArgumentParser(description="Generate column_intersection.md for 2023 & 2024")
    ap.add_argument("--docsdir", type=str, default="docs", help="Directory where data_dictionary_*.json live")
    args = ap.parse_args()
    docs = Path(args.docsdir)

    j2023 = docs / "data_dictionary_2023.json"
    j2024 = docs / "data_dictionary_2024.json"
    outmd = docs / "column_intersection.md"

    # If per-year files missing, attempt to synthesize them from the combined JSON
    if not j2023.exists() or not j2024.exists():
        combined = docs / "data_dictionary.json"
        if not combined.exists():
            raise SystemExit("Missing per-year and combined JSON. Run Pass-1 inventory first.")
        data_all = json.loads(combined.read_text(encoding='utf-8'))
        by_year = {d.get('year'): d for d in data_all if isinstance(d, dict) and d.get('year') in (2023, 2024)}
        if 2023 in by_year:
            (docs / "data_dictionary_2023.json").write_text(json.dumps(by_year[2023], indent=2), encoding='utf-8')
        if 2024 in by_year:
            (docs / "data_dictionary_2024.json").write_text(json.dumps(by_year[2024], indent=2), encoding='utf-8')
    # Reload paths (in case we just wrote them)
    cols23, note23 = load_cols(docs / "data_dictionary_2023.json")
    cols24, note24 = load_cols(docs / "data_dictionary_2024.json")
    intersection = cols23 & cols24
    write_md(intersection, outmd, note_2023=note23, note_2024=note24)
    print(f"Wrote {outmd} with {len(intersection)} columns in the intersection.")

if __name__ == "__main__":
    main()
