# Data Inventory Pipeline — Iteration Plan

## 🎯 Baseline (Pass 1): Ship the essentials fast

**Goal:** get reliable column inventory + corruption flag + two MD docs.
**Scope guardrail:** no fuzzy rename logic, no JSON Schema, no heavy stats.

**Checklist**

* [ ] CLI accepts paths for 2023/2024/2025 CSVs; configurable `--outdir` (default `docs/`)
* [ ] Structural scan: count fields/row; infer expected ncols from header
* [ ] Histogram of field counts + sample offending lines (line#, first 5 cells)
* [ ] Safe load with `dtype=str, low_memory=False, on_bad_lines='skip'`
* [ ] Record: `rows_loaded`, `n_columns_detected`, **estimated rows skipped**
* [ ] Per-column inventory: `index`, `name`, `null_count`, `null_pct`
* [ ] Semantic flags: `is_numeric`, `is_multiselect` (semicolon), `looks_like_date`
* [ ] Unique count & examples **with caps** (e.g., sample ≤ 10k rows; `topk=10`)
* [ ] Outputs:

  * [ ] `docs/data_dictionary.json` (full per-dataset report)
  * [ ] `docs/column_mapping.md` (presence matrix ✅/❌ only)
  * [ ] `docs/relevant_columns.md` (business buckets — minimal curated list)
* [ ] Console verdict per year: `✅ Clean` / `⚠️ Issues` / `❌ Structural Corruption`
* [ ] Function `run()` orchestrates all steps; never hard-exit on single-file failure

**Done means**

* [ ] You can run once and immediately paste both MD files into the repo/Notion
* [ ] 2025 can be included but safely marked corrupted without blocking 2023–2024 baseline work

---

## ✨ Pass 2: Add insight & polish (lightweight)

**Goal:** make outputs more analytic without heavy libraries.

**Checklist**

* [ ] Add file metrics: `file_size_mb`, `run_duration_seconds`
* [ ] Numeric profiling (guarded): `count, mean, std, min, p25, p50, p75, max`
* [ ] Outlier counts: **IQR method** (always), **z-score** (when `std>0`)
* [ ] Categorical quality:

  * [ ] `case_inconsistent` flag (lowercased uniques vs raw uniques)
  * [ ] `single_value_dominance` flag if top value > 95%
* [ ] Column-mapping improvements:

  * [ ] Show **types by year** in a compact field (e.g., `str / str / int`)
  * [ ] Highlight **type changes** between years
* [ ] Relevant-columns MD becomes **data-assisted**:

  * [ ] Auto-scan names (regex/patterns like `AI|Tool|JobSat|Comp|Years|DevType|OrgSize|Barrier|Frustrat`)
  * [ ] List which years each appears in (small matrix per bullet)

**Done means**

* [ ] You can glance at `column_mapping.md` and see where types drifted
* [ ] `relevant_columns.md` suggests candidates from real data, not just hardcoded

---

## 🧠 Pass 3: Smart schema evolution (rename hints)

**Goal:** identify likely renames and schema diffs like a human would.

**Checklist**

* [ ] Fuzzy rename suggestions:

  * [ ] Use `difflib.SequenceMatcher` for **disappeared vs newly appeared** columns in consecutive years
  * [ ] Only suggest when similarity ≥ 0.85 and length difference ≤ 4 (tuneable)
  * [ ] Add note in mapping: “Possibly renamed: `AISelect → AIToolUse`”
* [ ] Optional schema CSVs:

  * [ ] Accept per-year schema CSVs (declared types)
  * [ ] Report **missing/extra** vs declared & **declared vs inferred** type mismatches
* [ ] Column-mapping MD upgrades:

  * [ ] Add **Notes** column to capture: Added/Removed, Type change, Rename hint
  * [ ] Add a small badge at top if year is `⚠️ Issues` or `❌ Corruption`

**Done means**

* [ ] You can justify column continuity across years (added/removed/renamed) with evidence
* [ ] If stakeholder asks “what changed in 2025?”, the table answers it

---

## 🧪 Pass 4: Production-grade validation & DX candy

**Goal:** make it tool-quality (for portfolio brownie points).

**Checklist**

* [ ] JSON Schema: `docs/data_dictionary_schema.json` to validate your own JSON
* [ ] CLI flags for caps: `--sample-rows`, `--topk-cats`, `--outlier-method`
* [ ] Output a **flattened CSV** summary for quick scanning:

  * [ ] `docs/column_inventory_flat.csv` (year, column, dtype, null_pct, unique_approx, flags…)
* [ ] Optional HTML report (basic): embed key tables for stakeholder viewing
* [ ] Log file with run metadata (versions, timestamps, config used)

**Done means**

* [ ] A reviewer can run one command, see clean logs & validated outputs, and understand the data story without you present

---

## 🔧 Naming & file layout (stays constant across passes)

```
scripts/
  data_inventory_master.py        # entrypoint (run())
  data_quality_defensive.py       # structural scan + inventory helpers
docs/
  data_dictionary.json            # machine-readable report
  column_mapping.md               # presence + types (+ notes as you iterate)
  relevant_columns.md             # business buckets (auto-assisted by pass 2)
  data_dictionary_schema.json     # (pass 4)
  column_inventory_flat.csv       # (pass 4)
```

---

## 🧭 Execution guidance

* Start with **Baseline** today (it’s genuinely small).
* When you feel itchy for “nicer insights,” do **Pass 2** (it’s still lightweight).
* As soon as 2025 confusion pops up, prioritize **Pass 3** (rename hints + schema CSVs).
* If you want “wow-factor” polish for portfolio review, sprinkle **Pass 4** features.

If you want, I can adapt your current master/orchestrator to emit **Pass-1** outputs exactly in this structure now, and we’ll keep the hooks ready for Pass-2/3/4.

