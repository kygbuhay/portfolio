#!/usr/bin/env python3
import re, datetime
from pathlib import Path
import pandas as pd
import numpy as np

BASE = Path(".")

template_path = BASE / "insights_summary.md"
output_path = BASE / "insights_summary_filled.md"

def load_csv_any(base: Path, name_stem: str):
    for p in base.glob(f"{name_stem}.csv*"):
        try:
            if p.suffix == ".gz":
                return pd.read_csv(p, compression="gzip", low_memory=False), p.name
            return pd.read_csv(p, low_memory=False), p.name
        except Exception:
            continue
    return None, None

def infer_from_kpi_wide(df):
    contact_cols = [c for c in df.columns if c.lower().startswith("contacts_n")]
    if not contact_cols:
        return None
    first = df.get("contacts_n", pd.Series(0, index=df.index)).fillna(0).sum()
    repeat = df[[c for c in contact_cols if c.lower() != "contacts_n"]].fillna(0).sum().sum()
    total = float(first + repeat)
    rcr = float(repeat/total) if total else None
    fcr = float(1 - rcr) if rcr is not None else None

    # dates
    min_date = max_date = None
    for dc in ["date_created","call_date","date","dt"]:
        if dc in df.columns:
            try:
                d = pd.to_datetime(df[dc], errors="coerce")
                if d.notna().any():
                    min_date = pd.to_datetime(d.min()).date()
                    max_date = pd.to_datetime(d.max()).date()
                    break
            except Exception:
                pass

    # by market
    by_market = None
    if "market" in df.columns:
        agg = df.groupby("market")[contact_cols].sum(numeric_only=True).fillna(0)
        first_by = agg.get("contacts_n", 0.0)
        repeat_by = agg[[c for c in contact_cols if c.lower() != "contacts_n"]].sum(axis=1)
        total_by = first_by + repeat_by
        rcr_by = (repeat_by / total_by).replace([np.inf, -np.inf], np.nan)
        by_market = rcr_by.sort_values(ascending=False).to_dict()

    return {
        "first": float(first),
        "repeat": float(repeat),
        "total": float(total),
        "rcr": rcr,
        "fcr": fcr,
        "min_date": min_date,
        "max_date": max_date,
        "rcr_by_market": by_market
    }

def infer_from_long(df):
    cols = {c.lower(): c for c in df.columns}
    day_col = next((cols[c] for c in ["day_offset","days_after_first","day","offset"] if c in cols), None)
    value_col = next((cols[c] for c in ["call_count","contacts","count","n"] if c in cols), None)
    if not day_col or not value_col:
        return None
    first = df.loc[df[day_col]==0, value_col].fillna(0).sum()
    repeat = df.loc[df[day_col]!=0, value_col].fillna(0).sum()
    total = float(first + repeat)
    rcr = float(repeat/total) if total else None
    fcr = float(1 - rcr) if rcr is not None else None

    by_market = None
    if "market" in df.columns:
        tmp = df.copy()
        tmp["_is_repeat"] = (tmp[day_col] != 0).astype(int)
        pvt = tmp.pivot_table(index="market", values=value_col, columns="_is_repeat", aggfunc="sum", fill_value=0)
        first_by = pvt.get(0, pd.Series(0, index=pvt.index))
        repeat_by = pvt.get(1, pd.Series(0, index=pvt.index))
        total_by = first_by + repeat_by
        rcr_by = (repeat_by / total_by).replace([np.inf, -np.inf], np.nan)
        by_market = rcr_by.sort_values(ascending=False).to_dict()

    return {
        "first": float(first),
        "repeat": float(repeat),
        "total": float(total),
        "rcr": rcr,
        "fcr": fcr,
        "min_date": None,
        "max_date": None,
        "rcr_by_market": by_market
    }

def pct(x):
    return f"{x*100:.1f}%" if isinstance(x, (int,float)) and np.isfinite(x) else "—"

def num(x):
    return f"{x:,.0f}" if isinstance(x, (int,float)) and np.isfinite(x) else "—"

# Load metrics from available CSVs
metrics = None
sources_used = []

df, name = load_csv_any(BASE, "kpi_daily")
if df is not None:
    m = infer_from_kpi_wide(df)
    if m:
        metrics = m
        sources_used.append(name)

if metrics is None:
    df, name = load_csv_any(BASE, "kpi_market_summary")
    if df is not None:
        m = infer_from_kpi_wide(df)
        if m:
            metrics = m
            sources_used.append(name)

if metrics is None:
    df, name = load_csv_any(BASE, "repeat_calls_long")
    if df is not None:
        m = infer_from_long(df)
        if m:
            metrics = m
            sources_used.append(name)

# Load template
tpl = template_path.read_text(encoding="utf-8") if template_path.exists() else ""

# Build exec summary text
if metrics:
    exec_text = (f"Overall repeat call rate (RCR) is **{pct(metrics['rcr'])}** "
                 f"({num(metrics['repeat'])} repeats out of {num(metrics['total'])} total), "
                 f"implying an FCR of **{pct(metrics['fcr'])}**.")
    if metrics.get("rcr_by_market"):
        top_market = max(metrics["rcr_by_market"], key=lambda k: metrics["rcr_by_market"][k])
        top_val = metrics["rcr_by_market"][top_market]
        exec_text += f" Highest RCR observed in **{top_market}** at **{pct(top_val)}**."
    if metrics.get("min_date") and metrics.get("max_date"):
        exec_text += f" _Data window: {metrics['min_date']} → {metrics['max_date']}_."
else:
    exec_text = "[Describe the overall situation with numbers]"

# Insert into the template after '## 📊 Executive Summary'
out = tpl
if "## 📊 Executive Summary" in tpl:
    pattern = r"(## 📊 Executive Summary[^\n]*\n)(?:.*?\n){0,3}"
    out = re.sub(pattern, r"\\1\n" + exec_text + "\n\n", tpl, flags=re.S)
else:
    out = "## 📊 Executive Summary\n\n" + exec_text + "\n\n" + tpl

# Append RCR-by-market table after exec summary if available
if metrics and metrics.get("rcr_by_market"):
    rcr_table = "\n#### RCR by Market (auto)\n\n| Market | RCR |\n|---|---:|\n"
    for mkt, val in sorted(metrics["rcr_by_market"].items(), key=lambda x: x[1], reverse=True):
        rcr_table += f"| {mkt} | {pct(val)} |\n"
    out = out.replace(exec_text + "\n\n", exec_text + "\n\n" + rcr_table + "\n", 1)

# Add a footer note with generation time and sources
ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
src_note = f"\n\n---\n_Auto-filled on {ts}. Sources: {', '.join(sources_used) if sources_used else 'None detected'}._\n"
out = out + src_note

# Write output
output_path.write_text(out, encoding="utf-8")
print(f"Wrote {output_path.name}")
