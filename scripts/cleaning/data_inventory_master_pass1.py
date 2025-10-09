#!/usr/bin/env python3
"""
Data Inventory Pipeline — Pass 1 (Baseline)

Outputs (under --outdir, default: docs/):
  - data_dictionary.json  : full per-dataset report (integrity + columns)
  - column_mapping.md     : presence matrix ✅/❌ (per-year)
  - relevant_columns.md   : minimal, curated business buckets scaffold

Design goals:
  - Robust to structural corruption (per-row field count scan)
  - Never hard-exit on a single bad file; return structured errors
  - Guard runtime on large CSVs with sampling caps for uniques/examples
"""

from __future__ import annotations
import argparse, csv, json, re, sys, time
from pathlib import Path
from collections import Counter
from typing import Dict, Any, List
import pandas as pd

# ----------------------------- helpers ------------------------------------------------

def structural_scan(file_path: str, expected_ncols: int | None = None, sample_offenders: int = 5) -> Dict[str, Any]:
    """
    Count fields per line to detect mismatched column counts (true structural corruption).
    Returns dict with field-count histogram and sample offending lines.
    Never raises; returns an 'error' key if scanning fails.
    """
    counts = Counter()
    offenders = []
    header = None
    total_lines = 0

    # bump field size limit to tolerate very long cells (e.g., 2025 corruption)
    try:
        import sys as _sys
        csv.field_size_limit(min(2**31 - 1, getattr(_sys, "maxsize", 2**31 - 1)))
    except Exception:
        pass

    try:
        # Try different encodings to handle BOM and other encoding issues
        encodings_to_try = ['utf-8-sig', 'utf-8', 'latin-1', 'cp1252']
        successful_encoding = None

        for encoding in encodings_to_try:
            try:
                with open(file_path, 'r', encoding=encoding, errors='replace', newline='') as f:
                    # Test by reading just the first line
                    first_line = f.readline()
                    if first_line.strip():  # If we can read something meaningful
                        successful_encoding = encoding
                        break
            except Exception:
                continue

        if not successful_encoding:
            successful_encoding = 'utf-8'  # fallback

        with open(file_path, 'r', encoding=successful_encoding, errors='replace', newline='') as f:
            reader = csv.reader(f)
            for i, row in enumerate(reader):
                total_lines += 1
                if i == 0:
                    header = row
                    # Clean up potential BOM from header fields
                    if header and header[0].startswith('\ufeff'):
                        header[0] = header[0].lstrip('\ufeff')
                    if expected_ncols is None and header is not None:
                        expected_ncols = len(header)
                    continue
                n = len(row)
                counts[n] += 1
                if expected_ncols and n != expected_ncols and len(offenders) < sample_offenders:
                    offenders.append({'line_number': i+1, 'field_count': n, 'preview': row[:5]})
        anomalies = {k: v for k, v in counts.items() if k != expected_ncols}
        return {
            'expected_ncols': expected_ncols,
            'field_count_histogram': dict(counts),
            'anomalous_field_counts': anomalies,
            'offending_examples': offenders,
            'total_lines_including_header': total_lines,
            'encoding_used': successful_encoding
        }
    except Exception as e:
        # return a soft error so the pipeline can continue
        return {
            'error': str(e),
            'expected_ncols': expected_ncols,
            'field_count_histogram': {},
            'anomalous_field_counts': {},
            'offending_examples': [],
            'total_lines_including_header': total_lines,
            'encoding_used': 'unknown'
        }

def looks_like_date(series: pd.Series, sample: int = 5000) -> bool:
    sample_vals = series.dropna().astype(str).head(sample)
    if sample_vals.empty:
        return False
    pat = re.compile(r'^(\d{4}-\d{2}-\d{2})|(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})$')
    m = sample_vals.sample(min(len(sample_vals), 200), random_state=0).str.match(pat).mean()
    return bool(m > 0.7)

def is_multiselect(series: pd.Series, sep: str = ';') -> bool:
    sample_vals = series.dropna().astype(str).head(5000)
    if sample_vals.empty:
        return False
    return bool(sample_vals.str.contains(rf'\s*{re.escape(sep)}\s*').mean() > 0.2)

def file_size_mb(path: str) -> float:
    p = Path(path)
    if not p.exists():
        return 0.0
    return round(p.stat().st_size / (1024*1024), 2)

# ----------------------------- core analysis ------------------------------------------

def analyze_dataset(file_path: str, year: int, sample_uniques_cap: int = 10000, topk_cats: int = 10) -> Dict[str, Any]:
    t0 = time.time()
    struct = structural_scan(file_path)
    expected_ncols = struct.get('expected_ncols')
    corrupted = bool(struct.get('anomalous_field_counts'))
    encoding_used = struct.get('encoding_used', 'utf-8')

    try:
        # Try to load with the encoding that worked in structural scan
        df = pd.read_csv(
            file_path,
            low_memory=False,
            dtype=str,
            on_bad_lines='skip',
            encoding=encoding_used
        )

        # Clean up BOM from column names if present
        if len(df.columns) > 0 and df.columns[0].startswith('\ufeff'):
            df.columns = [df.columns[0].lstrip('\ufeff')] + list(df.columns[1:])

        loaded_ok = True
    except Exception as e:
        # Try fallback encodings if the structural scan encoding fails
        fallback_encodings = ['utf-8-sig', 'utf-8', 'latin-1', 'cp1252']
        loaded_ok = False
        last_error = str(e)

        for enc in fallback_encodings:
            if enc == encoding_used:  # Skip the one we already tried
                continue
            try:
                df = pd.read_csv(
                    file_path,
                    low_memory=False,
                    dtype=str,
                    on_bad_lines='skip',
                    encoding=enc
                )

                # Clean up BOM from column names if present
                if len(df.columns) > 0 and df.columns[0].startswith('\ufeff'):
                    df.columns = [df.columns[0].lstrip('\ufeff')] + list(df.columns[1:])

                loaded_ok = True
                encoding_used = enc
                break
            except Exception as new_e:
                last_error = str(new_e)
                continue

        if not loaded_ok:
            return {
                'year': year,
                'file': file_path,
                'file_size_mb': file_size_mb(file_path),
                'loaded_ok': False,
                'error': last_error,
                'structural_scan': struct,
                'encoding_tried': encoding_used
            }

    total_lines = struct['total_lines_including_header'] - 1  # minus header
    skipped_rows_est = max(0, total_lines - len(df))

    cols_profile = []
    for i, col in enumerate(df.columns):
        s = df[col]
        n = len(s)
        nulls = int(s.isna().sum())
        null_pct = round((nulls / n) * 100, 2) if n else 0.0

        # semantic flags
        as_num = pd.to_numeric(s, errors='coerce')
        is_numeric = bool(as_num.notna().sum() > 0)
        looks_date = False if is_numeric else looks_like_date(s)
        multi = is_multiselect(s)

        # uniques & examples (guarded)
        if is_numeric:
            examples = [v for v in as_num.dropna().head(5).tolist()]
            unique_approx = int(min(as_num.nunique(dropna=True), sample_uniques_cap))
        else:
            vc = s.value_counts(dropna=False)
            unique_approx = int(min(vc.size, sample_uniques_cap))
            examples = [str(x) for x in vc.head(topk_cats).index.tolist()]

        cols_profile.append({
            'index': i,
            'name': col,
            'null_count': nulls,
            'null_pct': null_pct,
            'is_numeric': is_numeric,
            'looks_like_date': looks_date,
            'is_multiselect': multi,
            'unique_approx': unique_approx,
            'examples': examples
        })

    report = {
        'year': year,
        'file': file_path,
        'file_size_mb': file_size_mb(file_path),
        'loaded_ok': loaded_ok,
        'rows_loaded': int(len(df)),
        'estimated_rows_in_file_ex_header': int(total_lines),
        'estimated_rows_skipped': int(skipped_rows_est),
        'structural_corruption': bool(corrupted),
        'structural_scan': struct,
        'n_columns_detected': int(len(df.columns)),
        'columns': cols_profile,
        'encoding_used': encoding_used,
        'run_duration_seconds': round(time.time() - t0, 2)
    }
    return report

# ----------------------------- docs generation ----------------------------------------

def write_json(obj: Dict[str, Any], out_path: str):
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, indent=2)

def generate_column_mapping(reports: List[Dict[str, Any]], out_md: str):
    # Determine year status
    status_by_year = {}
    per_year_cols = {}
    for r in reports:
        y = r.get('year')
        if not y:
            continue
        if not r.get('loaded_ok'):
            status = f"⛔ Not loaded ({r.get('error','unknown error')})"
            per_year_cols[y] = set()  # no cols, but we still show ⛔ in table
        elif r.get('structural_corruption'):
            status = "❌ Structural corruption detected"
            per_year_cols[y] = {c['name'] for c in r.get('columns', [])}
        elif r.get('estimated_rows_skipped', 0) > 0:
            status = "⚠️ Some rows skipped by parser"
            per_year_cols[y] = {c['name'] for c in r.get('columns', [])}
        else:
            status = "✅ Clean"
            per_year_cols[y] = {c['name'] for c in r.get('columns', [])}
        status_by_year[y] = status

    # Collect all column names from years that actually loaded
    loaded_sets = [s for s in per_year_cols.values() if s]
    all_cols = sorted(set().union(*loaded_sets) if loaded_sets else [])

    legend = (
        "# Column Availability Matrix\n\n"
        "> Legend: ✅ present · ❌ absent · ⛔ year not loaded\n\n"
        f"**Year statuses:** 2023: {status_by_year.get(2023,'—')}, "
        f"2024: {status_by_year.get(2024,'—')}, "
        f"2025: {status_by_year.get(2025,'—')}\n\n"
    )

    header = (
        "| Column Name | 2023 | 2024 | 2025 |\n"
        "|-------------|------|------|------|\n"
    )
    rows = []
    for col in all_cols:
        marks = []
        for yr in (2023, 2024, 2025):
            if 'Not loaded' in status_by_year.get(yr, ''):
                marks.append("⛔")
            else:
                present = "✅" if col in per_year_cols.get(yr, set()) else "❌"
                marks.append(present)
        rows.append(f"| {col} | {' | '.join(marks)} |")

    Path(out_md).parent.mkdir(parents=True, exist_ok=True)
    Path(out_md).write_text(legend + header + "\n".join(rows), encoding='utf-8')

def generate_relevant_columns_minimal(out_md: str):
    md = """# Relevant Columns for AI ROI Analysis (Baseline Scaffold)

## AI Tool Usage
- `AISelect` (2023/2024)
- `AIToolUse` (2025) – if present

## Productivity Proxies
- `JobSat` (2024/2025)
- `ConvertedCompYearly` (all years if present)

## Demographics
- `YearsCodePro`
- `DevType`
- `OrgSize`

## Adoption Barriers
- Columns like `AIWhyNotUse`, `AIFrustrations` (if present)

> Note: This is a minimal scaffold for Pass 1. In Pass 2 we will auto-scan actual column names and annotate year availability.
"""
    Path(out_md).parent.mkdir(parents=True, exist_ok=True)
    Path(out_md).write_text(md, encoding='utf-8')

# ----------------------------- CLI orchestration --------------------------------------

def run(csv_2023: str, csv_2024: str, csv_2025: str, outdir: str, sample_uniques_cap: int = 10000, topk_cats: int = 10):
    outdir_path = Path(outdir)
    outdir_path.mkdir(parents=True, exist_ok=True)

    results = []
    inputs = [(csv_2023, 2023), (csv_2024, 2024), (csv_2025, 2025)]

    print("=== Data Inventory Pass 1: Analyzing CSV files ===")

    for fp, yr in inputs:
        print(f"\nProcessing {yr}...")
        if not fp:
            print(f"  ⚠️ No file path provided for {yr}")
            results.append({'year': yr, 'loaded_ok': False, 'error': 'No file path provided'})
            continue

        # Check if file exists
        if not Path(fp).exists():
            print(f"  ❌ File does not exist: {fp}")
            results.append({'year': yr, 'file': fp, 'loaded_ok': False, 'error': f'File does not exist: {fp}'})
            continue

        try:
            print(f"  📊 Analyzing {Path(fp).name}...")
            rep = analyze_dataset(fp, yr, sample_uniques_cap=sample_uniques_cap, topk_cats=topk_cats)

            # Report what we found
            if rep.get('loaded_ok'):
                print(f"  ✅ Loaded successfully using {rep.get('encoding_used', 'unknown')} encoding")
                print(f"     Rows: {rep.get('rows_loaded', 0)}, Columns: {rep.get('n_columns_detected', 0)}")
                if rep.get('structural_corruption'):
                    print(f"     ⚠️ Structural corruption detected")
                if rep.get('estimated_rows_skipped', 0) > 0:
                    print(f"     ⚠️ Estimated {rep.get('estimated_rows_skipped')} rows skipped")
            else:
                print(f"  ❌ Failed to load: {rep.get('error', 'Unknown error')}")
        except Exception as e:
            print(f"  ❌ Unexpected error: {str(e)}")
            rep = {'year': yr, 'file': fp, 'loaded_ok': False, 'error': str(e)}
        results.append(rep)

    print(f"\n=== Generating output files in {outdir_path} ===")

    # write JSON (combined + per-year)
    data_json = outdir_path / 'data_dictionary.json'
    write_json(results, str(data_json))
    print(f"✅ Written: {data_json}")

    for r in results:
        yr = r.get('year')
        if yr:
            per_year_json = outdir_path / f'data_dictionary_{yr}.json'
            write_json(r, str(per_year_json))
            print(f"✅ Written: {per_year_json}")

    # docs
    mapping_md = outdir_path / 'column_mapping.md'
    generate_column_mapping(results, str(mapping_md))
    print(f"✅ Written: {mapping_md}")

    relevant_md = outdir_path / 'relevant_columns.md'
    generate_relevant_columns_minimal(str(relevant_md))
    print(f"✅ Written: {relevant_md}")

    # console verdict
    print(f"\n=== Final Analysis Summary ===")
    verdicts = []
    for r in results:
        if not r.get('loaded_ok'):
            verdict = '❌ Failed to load'
        elif r.get('structural_corruption'):
            verdict = '❌ Structural Corruption'
        elif r.get('estimated_rows_skipped', 0) > 0:
            verdict = '⚠️ Issues Detected'
        else:
            verdict = '✅ Clean'
        verdicts.append((r.get('year'), verdict))

    print("Year verdicts:", ", ".join([f"{y}: {v}" for y, v in verdicts]))
    clean_years = [y for y, v in verdicts if v == '✅ Clean']
    print("Clean baseline years:", clean_years)

    # Provide actionable feedback
    failed_years = [y for y, v in verdicts if 'Failed' in v]
    if failed_years:
        print(f"\n📝 Note: Years {failed_years} failed to load but artifacts were still generated")
        print("   You can fix the corrupted files and re-run to get complete data")

    return results

def parse_args(argv=None):
    p = argparse.ArgumentParser(description="Data Inventory Pipeline — Pass 1")
    p.add_argument('--csv2023', type=str, default='stackoverflow_2023.csv', help='Path to 2023 CSV')
    p.add_argument('--csv2024', type=str, default='stackoverflow_2024.csv', help='Path to 2024 CSV')
    p.add_argument('--csv2025', type=str, default='stackoverflow_2025.csv', help='Path to 2025 CSV')
    p.add_argument('--outdir', type=str, default='docs', help='Output directory')
    p.add_argument('--sample-uniques-cap', type=int, default=10000, help='Cap for unique counts')
    p.add_argument('--topk-cats', type=int, default=10, help='Top-K for categorical examples')
    return p.parse_args(argv)

if __name__ == '__main__':
    args = parse_args()
    run(args.csv2023, args.csv2024, args.csv2025, args.outdir, args.sample_uniques_cap, args.topk_cats)
