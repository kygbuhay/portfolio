# Data Inventory Pipeline — Pass 1 (Baseline)

**Script:** `/mnt/data/scripts/data_inventory_master_pass1.py`

## How to run
```bash
python "/mnt/data/scripts/data_inventory_master_pass1.py" \
  --csv2023 /path/to/stackoverflow_2023.csv \
  --csv2024 /path/to/stackoverflow_2024.csv \
  --csv2025 /path/to/stackoverflow_2025.csv \
  --outdir "/mnt/data/docs"
```

Outputs will be written under `/mnt/data/docs`:
- `data_dictionary.json`
- `column_mapping.md`
- `relevant_columns.md`

## Relevant repo layout:
Documents/
└── portfolio/
    ├── scripts/
    │   └── cleaning/
    │       └── data_inventory_master_pass1.py
    └── coursework/
        └── google-data-analytics/
            └── ai_workplace_productivity_analysis/
                ├── data/
                │   └── raw/
                │       ├── stackoverflow_2023.csv
                │       ├── stackoverflow_2024.csv
                │       └── stackoverflow_2025.csv
                └── docs/

## Actual bash:

cd ~/Documents/portfolio/scripts/cleaning

python data_inventory_master_pass1.py \
  --csv2023 ../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/raw/stackoverflow_2023.csv \
  --csv2024 ../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/raw/stackoverflow_2024.csv \
  --csv2025 ../coursework/google-data-analytics/ai_workplace_productivity_analysis/data/raw/stackoverflow_2025.csv \
  --outdir ../coursework/google-data-analytics/ai_workplace_productivity_analysis/docs

