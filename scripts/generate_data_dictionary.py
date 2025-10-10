#!/usr/bin/env python3
"""
Data dictionary generator (robust CSV reader + CWD-first paths)
"""

import os
import sys
import argparse
from pathlib import Path
import pandas as pd

def find_csvs(base: Path, recursive: bool) -> list[Path]:
    if base.is_file() and base.suffix.lower() == ".csv":
        return [base]
    if base.is_dir():
        return [p for p in (base.rglob("*.csv") if recursive else base.glob("*.csv"))]
    return []

def read_csv_robust(path: Path, sample: int) -> pd.DataFrame:
    """
    Try multiple pandas read_csv strategies from fastest to most forgiving.
    Returns a DataFrame or raises the last Exception.
    """
    # 1) Fast path: C engine, default parsing
    try:
        return pd.read_csv(path, nrows=sample)  # C engine default
    except Exception as e1:
        last_err = e1

    # 2) C engine with fallback options
    try:
        return pd.read_csv(
            path,
            nrows=sample,
            dtype_backend="numpy_nullable" if "dtype_backend" in pd.read_csv.__code__.co_varnames else None,
        )
    except Exception as e2:
        last_err = e2

    # 3) Python engine (more tolerant), no low_memory
    try:
        return pd.read_csv(
            path,
            nrows=sample,
            engine="python",
        )
    except Exception as e3:
        last_err = e3

    # 4) Python engine with forgiving options (skip bad lines, ignore encoding errors)
    try:
        kwargs = dict(nrows=sample, engine="python")
        # on_bad_lines may not exist in older pandas; guard it
        if "on_bad_lines" in pd.read_csv.__code__.co_varnames:
            kwargs["on_bad_lines"] = "skip"
        df = pd.read_csv(path, **kwargs)
        return df
    except Exception as e4:
        last_err = e4

    # 5) Try common separators if misdetected
    for sep in [",", ";", "\t", "|"]:
        try:
            return pd.read_csv(path, nrows=sample, engine="python", sep=sep)
        except Exception as e5:
            last_err = e5

    raise last_err

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", "-i", type=str, help="Folder or file (default: ./data/raw or CWD recursive fallback)")
    parser.add_argument("--output", "-o", type=str, help="Output markdown (default: ./docs/data_dictionary_autogen.md)")
    parser.add_argument("--recursive", "-r", action="store_true", help="Recurse if input is a directory")
    parser.add_argument("--sample", type=int, default=1000, help="Rows to sample per CSV (default: 1000)")
    args = parser.parse_args()

    cwd = Path.cwd()

    # Resolve input target
    if args.input:
        input_path = (cwd / args.input).resolve()
        csvs = find_csvs(input_path, args.recursive)
    else:
        preferred = cwd / "data" / "raw"
        csvs = find_csvs(preferred, recursive=False)
        if not csvs:
            csvs = find_csvs(cwd, recursive=True)

    # Resolve output target
    output_path = (cwd / (args.output or "docs/data_dictionary_autogen.md")).resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if not csvs:
        output_path.write_text("# 📘 Auto-Generated Data Dictionary\n\n_No CSV files found._\n")
        print("⚠️  No CSVs found. Wrote stub to", output_path)
        sys.exit(0)

    print(f"🔎 Found {len(csvs)} CSV file(s):")
    for p in sorted(csvs):
        try:
            rel = p.relative_to(cwd)
        except ValueError:
            rel = p
        print("  •", rel)

    md = ["# 📘 Auto-Generated Data Dictionary\n"]

    for file in sorted(csvs):
        section = [f"\n## {file.name}\n"]
        try:
            df = read_csv_robust(file, args.sample)
            section.append("| Column | Pandas Dtype | Non-Null % | Example Value |\n")
            section.append("|---|---|---:|---|\n")
            for col in df.columns:
                s = df[col]
                dtype = str(s.dtype)
                nn = (s.notna().mean() * 100) if len(s) else 0.0
                example = "—"
                if s.notna().any():
                    example = str(s.dropna().iloc[0])[:120]
                section.append(f"| `{col}` | {dtype} | {nn:.1f}% | {example} |\n")
        except Exception as e:
            section.append(f"_Error reading file: {e}_\n")
        md.extend(section)

    output_path.write_text("".join(md))
    print("✅ Data dictionary saved to", output_path)

if __name__ == "__main__":
    main()
