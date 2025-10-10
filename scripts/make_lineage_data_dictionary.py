#!/usr/bin/env python3
import os, re, math
from pathlib import Path
import pandas as pd
import numpy as np

LOW_CARD_THRESHOLD = 50
TOPK = 10
SAMPLE_N = 5

SQL_KEYWORDS = {"SELECT","WITH","FROM","WHERE","GROUP","BY","HAVING","ORDER","JOIN","LEFT","RIGHT","FULL","INNER","OUTER","ON","UNION","ALL"}

def parse_sql_lineage(sql_text: str):
    """Return mapping target_col -> set(source_cols) using simple SELECT ... AS ... extraction."""
    mapping = {}
    if not sql_text:
        return mapping
    # strip comments
    text = re.sub(r'--.*', '', sql_text)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    # find expr AS alias
    for m in re.finditer(r'(?i)(?:^|,|\s)([\w.`]+)\s+AS\s+([A-Za-z_][\w]*)', text):
        src, tgt = m.group(1), m.group(2)
        src = src.replace('`','').strip()
        tgt = tgt.strip()
        if tgt.upper() in SQL_KEYWORDS:
            continue
        # last token after dot is the column-ish bit
        src_last = src.split('.')[-1]
        if '(' in src_last or ')' in src_last:
            continue
        mapping.setdefault(tgt, set()).add(src_last)
    return mapping

def summarize_series(s: pd.Series):
    n = len(s)
    nulls = int(s.isna().sum())
    non_null = n - nulls
    nunique = int(s.nunique(dropna=True))
    dtype = str(s.dtype)

    is_num = pd.api.types.is_numeric_dtype(s)
    is_datetime = pd.api.types.is_datetime64_any_dtype(s)

    min_val = max_val = mean = median = std = None
    if is_num and non_null:
        min_val = s.min()
        max_val = s.max()
        mean = s.mean()
        median = s.median()
        std = s.std(ddof=0)
    elif is_datetime and non_null:
        min_val = s.min()
        max_val = s.max()

    samples = s.dropna().astype(str).unique()[:SAMPLE_N].tolist()

    topk = None
    if (not is_num or nunique <= LOW_CARD_THRESHOLD) and nunique > 0 and non_null > 0:
        vc = s.astype("string").value_counts(dropna=True).head(TOPK)
        topk = [(idx, int(cnt), round(100*cnt/non_null, 2)) for idx, cnt in vc.items()]

    return {
        "dtype": dtype,
        "count": n,
        "nulls": nulls,
        "non_null": non_null,
        "nunique": nunique,
        "min": min_val,
        "max": max_val,
        "mean": mean,
        "median": median,
        "std": std,
        "samples": samples,
        "topk": topk
    }

def render_markdown(csv_path: Path, df: pd.DataFrame, lineage_map: dict):
    title = f"# Data Dictionary — {csv_path.name}\n\n"
    overview = f"- **Rows:** {len(df):,}\n- **Columns:** {df.shape[1]}\n\n"
    quick_hdr = "## Quick Summary\n\n| Column | Type | Nulls | Distinct | Derived From |\n|---|---|---:|---:|---|\n"

    quick_rows = []
    for col in df.columns:
        summ = summarize_series(df[col])
        derived = None
        if col in lineage_map and lineage_map[col]:
            derived = ", ".join(sorted(lineage_map[col]))
        else:
            derived = "—"
        quick_rows.append(f"| `{col}` | {summ['dtype']} | {summ['nulls']:,} | {summ['nunique']:,} | {derived} |")
    quick_tbl = quick_hdr + "\n".join(quick_rows) + "\n\n"

    details = ["## Column Details\n"]
    for col in df.columns:
        summ = summarize_series(df[col])
        details.append(f"### `{col}`")
        # lineage
        if col in lineage_map and lineage_map[col]:
            details.append(f"- **Derived From:** {', '.join(f'`{s}`' for s in sorted(lineage_map[col]))}")
        else:
            details.append(f"- **Derived From:** —")
        details.append(f"- **Type:** `{summ['dtype']}`")
        details.append(f"- **Nulls:** {summ['nulls']:,} ({round(100*summ['nulls']/summ['count'],2) if summ['count'] else 0}%)")
        details.append(f"- **Distinct:** {summ['nunique']:,}")
        if summ['min'] is not None or summ['max'] is not None:
            details.append(f"- **Range:** {summ['min']} — {summ['max']}")
        if summ['mean'] is not None:
            details.append(f"- **Mean/Median/Std:** {round(summ['mean'],4)} / {round(summ['median'],4)} / {round(summ['std'],4)}")
        if summ['samples']:
            details.append(f"- **Sample values:** {', '.join('`'+str(x)+'`' for x in summ['samples'])}")
        if summ['topk']:
            details.append(f"- **Top {min(TOPK, len(summ['topk']))} categories:**")
            details.append("| Value | Count | % |\n|---|---:|---:|")
            for v, c, p in summ['topk']:
                details.append(f"| `{v}` | {c:,} | {p:.2f}% |")
        details.append("")

    return title + overview + quick_tbl + "\n".join(details) + "\n"

def main():
    base = Path(".")
    # Gather any .sql files to build a lineage map
    lineage_map = {}
    for sql in base.glob("*.sql"):
        try:
            text = sql.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        m = parse_sql_lineage(text)
        # merge
        for tgt, srcs in m.items():
            lineage_map.setdefault(tgt, set()).update(srcs)

    # Also support a manual mapping file if provided
    manual_json = base / "lineage_manual.json"
    if manual_json.exists():
        try:
            import json
            manual = json.loads(manual_json.read_text(encoding="utf-8"))
            for tgt, srcs in manual.items():
                lineage_map.setdefault(tgt, set()).update(set(srcs))
        except Exception:
            pass

    csvs = sorted(base.glob("*.csv"))
    if not csvs:
        print("No CSVs found.")
        return

    for csv in csvs:
        try:
            df = pd.read_csv(csv, low_memory=False)
        except Exception as e:
            print(f"Skipping {csv.name}: {e}")
            continue

        # Heuristic: try parsing obvious datetime columns
        for col in df.columns:
            name = col.lower()
            if any(k in name for k in ("date","time","timestamp","dt")):
                try:
                    df[col] = pd.to_datetime(df[col], errors="ignore")
                except Exception:
                    pass

        md = render_markdown(csv, df, lineage_map)
        out = csv.with_name(csv.stem + "_data_dictionary.md")
        out.write_text(md, encoding="utf-8")
        print(f"Wrote {out.name}")

if __name__ == "__main__":
    main()
