# Data Cleaning & Inventory Scripts

**Purpose:** Automated data processing and inventory tools for large dataset analysis

## 🎯 **Quick Start**

```bash
# Run complete Pass 1 data inventory pipeline
./run_data_inventory.sh

# Check specific dataset for corruption
python corruption_check.py path/to/dataset.csv

# Generate column intersection analysis
python generate_column_intersection.py --docsdir docs/
```

## 📄 **Scripts Overview**

### **`run_data_inventory.sh`** - **Main Pipeline Runner**
Orchestrates the complete Pass 1 data inventory workflow:
- Runs `data_inventory_master_pass1.py` on 2023, 2024, 2025 datasets
- Generates all required artifacts (JSON, Markdown reports)
- Creates column intersection analysis for baseline years
- Provides verification and error reporting

**Usage:**
```bash
./run_data_inventory.sh
```

**Outputs:** All files generated in `../coursework/google-data-analytics/ai_workplace_productivity_analysis/docs/`

---

### **`data_inventory_master_pass1.py`** - **Core Analysis Engine**
Comprehensive dataset analysis tool with robust error handling:

**Features:**
- ✅ **Multi-encoding support** (handles BOM, UTF-8, Latin-1, CP1252)
- ✅ **Structural corruption detection** via field count analysis
- ✅ **Graceful error handling** - continues processing on individual file failures
- ✅ **Smart column profiling** with semantic flags (numeric, date, multiselect)
- ✅ **Capped unique counts** for performance on large datasets
- ✅ **Detailed reporting** with encoding info and processing statistics

**CLI Usage:**
```bash
python data_inventory_master_pass1.py \
  --csv2023 path/to/2023.csv \
  --csv2024 path/to/2024.csv \
  --csv2025 path/to/2025.csv \
  --outdir docs/
```

**Generated Artifacts:**
- `data_dictionary.json` - Combined analysis for all years
- `data_dictionary_{year}.json` - Individual year reports
- `column_mapping.md` - Presence matrix (✅/❌) across years
- `relevant_columns.md` - Business-focused column scaffold

---

### **`generate_column_intersection.py`** - **Baseline Column Analysis**
Creates intersection analysis for baseline years (2023 ∩ 2024):

**Features:**
- ✅ **Automatic fallback** to combined JSON if per-year files missing
- ✅ **Error-aware processing** with notes for failed years
- ✅ **Clean output format** with sorted column list

**Usage:**
```bash
python generate_column_intersection.py --docsdir docs/
```

**Output:** `column_intersection.md` with columns present in both baseline years

---

### **`generate_comprehensive_analysis.py`** - **🎯 Complete Multi-Year Analysis**
**NEW!** Comprehensive analysis tool for EDA planning across all 3 datasets:

**Features:**
- ✅ **All intersection types** (3-way, 2-way, year-specific)
- ✅ **EDA strategy templates** for different analysis approaches
- ✅ **SQL query templates** with ready-to-use column lists
- ✅ **Business-focused categorization** (demographics, AI usage, etc.)
- ✅ **Analysis-ready documentation** for immediate use

**Usage:**
```bash
python generate_comprehensive_analysis.py --docsdir docs/
```

**Outputs:**
- `comprehensive_column_analysis.md` - Complete EDA strategy guide
- `sql_column_reference.sql` - Copy-paste SQL column lists

---

### **`generate_cleaned_datasets.py`** - **💾 BigQuery-Ready Data Processing**
**NEW!** Creates cleaned CSV files and BigQuery schemas for immediate upload:

**Features:**
- ✅ **Encoding fixes** - Handles BOM, UTF-8, and encoding issues automatically
- ✅ **BigQuery column compatibility** - Cleans column names per BigQuery requirements
- ✅ **Auto-generated schemas** - Smart type inference with proper BigQuery JSON format
- ✅ **Data validation** - Removes empty rows and problematic characters
- ✅ **Upload instructions** - Step-by-step BigQuery upload guide

**Usage:**
```bash
python generate_cleaned_datasets.py --raw-dir data/raw --output-dir data/processed
```

**Outputs:**
- `{year}_stackoverflow_cleaned.csv` - Fixed, BigQuery-ready CSV files
- `{year}_stackoverflow_schema.json` - BigQuery table schemas
- `BIGQUERY_UPLOAD_INSTRUCTIONS.md` - Complete upload guide

---

### **`corruption_check.py`** - **Dataset Validation Utility**
Standalone tool for checking individual CSV files for structural issues:

**Features:**
- ✅ **Field count histogram** showing row structure distribution
- ✅ **Sample offending rows** with line numbers and previews
- ✅ **Encoding detection** and BOM handling
- ✅ **Non-blocking errors** for continued analysis

---

### **`data_summarizer_gemini.py`** - **AI-Powered Analysis**
*Advanced utility for generating insights using AI models*

---

## 📋 **Pipeline Requirements Document**

**See:** [`data_inventory_pipeline.md`](data_inventory_pipeline.md) for complete specifications

**Pass 1 Checklist (✅ Implemented):**
- [x] CLI accepts paths for 2023/2024/2025 CSVs with configurable output
- [x] Structural scan with field count histograms and error samples
- [x] Safe CSV loading with dtype=str and skip bad lines
- [x] Per-column inventory with nulls, semantics, and examples
- [x] JSON outputs (combined + per-year) with full metadata
- [x] Markdown outputs (mapping + relevant columns)
- [x] Console verdicts per year (✅ Clean / ⚠️ Issues / ❌ Corruption)
- [x] Non-blocking error handling for corrupted files

## 🛠️ **Technical Implementation**

### **Encoding Handling Strategy**
The scripts use a multi-tier encoding detection approach:

1. **Primary:** `utf-8-sig` (handles BOM automatically)
2. **Fallback:** `utf-8`, `latin-1`, `cp1252`
3. **BOM Cleanup:** Manual removal from column headers when detected
4. **Error Recovery:** `errors='replace'` prevents encoding crashes

### **Performance Optimizations**
- **Sampling caps:** Unique counts limited to 10K for large datasets
- **Categorical examples:** Top-K approach (default: 10) for memory efficiency
- **Field size limits:** Increased to handle very long text fields
- **Structural pre-scan:** Fast field counting before expensive pandas operations

### **Error Handling Philosophy**
- **Fail-safe design:** Individual file failures don't stop the pipeline
- **Detailed error reporting:** Full error messages preserved in output JSON
- **Graceful degradation:** Partial results still generate useful artifacts
- **Verification steps:** Built-in checks ensure required outputs exist

## 📊 **Example Output Structure**

**After running `./run_data_inventory.sh`:**

```
docs/
├── data_dictionary.json              # Combined report
├── data_dictionary_2023.json         # Individual year analyses
├── data_dictionary_2024.json
├── data_dictionary_2025.json
├── column_mapping.md                  # ✅/❌ presence matrix
├── relevant_columns.md               # Business-focused scaffold
└── column_intersection.md            # 2023 ∩ 2024 baseline
```

## 🚨 **Recent Fixes (October 2025)**

### **BOM & Encoding Issues - RESOLVED ✅**
- **Problem:** 2025 CSV had BOM character corruption
- **Solution:** Multi-encoding detection with automatic BOM cleanup
- **Result:** All three datasets now process cleanly

### **Pipeline Robustness - ENHANCED ✅**
- **Added:** Graceful error handling for individual file failures
- **Added:** Detailed console progress reporting
- **Added:** Verification steps and actionable feedback
- **Result:** Pipeline continues even with corrupted files

## 🔧 **Troubleshooting**

### **"File does not exist" errors**
- Check that CSV files are in the expected location: `data/raw/`
- Verify paths in `run_data_inventory.sh` match your structure

### **"No columns found" in output**
- Usually indicates severe CSV corruption
- Check the structural scan output for field count anomalies
- Try manual encoding detection with `corruption_check.py`

### **"Permission denied" on shell script**
```bash
chmod +x run_data_inventory.sh
```

### **Missing Python dependencies**
```bash
pip install pandas
```

---

**Last Updated:** October 2025
**Status:** Production Ready - Pass 1 Complete ✅