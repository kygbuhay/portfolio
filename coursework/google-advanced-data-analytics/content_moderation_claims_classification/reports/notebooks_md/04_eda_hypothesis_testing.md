# TikTok Claims — Evaluation: Data Inspection & Hypothesis Testing
***Evaluation shows a statistically significant difference in TikTok video views between verified and unverified accounts.***

**Owner:** Katherine Ygbuhay  
**Updated:** September 2025  
**Stage:** 04  

**Goal**  
Assess the quality of the TikTok claims dataset, perform cleaning to ensure reliability, and evaluate whether account verification status is associated with differences in video view counts.  

**Scope**  
This stage focuses on exploratory inspection and a targeted statistical test. It does not yet include predictive modeling or feature engineering; those follow in later stages.  

**Contents**  
- Data inspection (shape, missingness, descriptive statistics, categorical overview)  
- Data cleaning (row-wise removal of missing values)  
- Group-level metric: mean views by verification status  
- Hypothesis test: Welch’s two-sample t-test (α = 0.05)  
- Technical conclusion with statistical evidence  
- Business implications and next-step recommendations

## Imports & Readability


```python
# Core data analysis packages
import pandas as pd
import numpy as np

# Visualization packages
import matplotlib.pyplot as plt
import seaborn as sns

# Statistical analysis / hypothesis testing
from scipy import stats
```


```python
# Pandas display settings (improves readability in notebooks)
pd.options.display.float_format = '{:.3f}'.format
pd.set_option("display.max_columns", None)   # show all columns
pd.set_option("display.max_rows", 100)       # up to 100 rows

# Seaborn theme for readability + accessibility
# - "whitegrid" for clarity
# - "colorblind" = Okabe–Ito palette (colorblind-friendly)
sns.set_theme(style="whitegrid", palette="colorblind")

# Matplotlib defaults for consistent figure sizing & typography
import matplotlib as mpl
mpl.rcParams["figure.figsize"] = (7, 5)
mpl.rcParams["axes.titlesize"] = 14
mpl.rcParams["axes.labelsize"] = 12
mpl.rcParams["legend.title_fontsize"] = 11
mpl.rcParams["legend.fontsize"] = 10

# Consistent color palettes for categorical variables
claim_palette = {"claim": "#0072B2", "opinion": "#E69F00"}                 
verified_palette = {"verified": "#009E73", "not verified": "#0072B2"}      
ban_palette = {
    "active": "#0072B2", 
    "under review": "#E69F00", 
    "banned": "#D55E00"
}
```


```python
# Resolve the case-study root so paths work from any launch directory
from pathlib import Path

def find_case_root(start: Path | None = None) -> Path:
    p = start or Path.cwd()
    for q in [p, *p.parents]:
        if (q / "notebooks").exists() and (q / "data").exists():
            return q
    return p  # fallback

CASE_ROOT = find_case_root()
DATA_FILE = CASE_ROOT / "data" / "raw" / "tiktok_dataset.csv"
assert DATA_FILE.exists(), f"Missing data file: {DATA_FILE}"
```


```python
# Load dataset
df = pd.read_csv(DATA_FILE)
```

## Data Inspection Utilities
Small helper to summarize a DataFrame (shape, head, missingness, numeric stats, and top categories).


```python
# DataFrame summary utility (run once, reuse below)
def df_summary(df, head=5, top_k=5):
    """
    Structured DataFrame summary:
      - Shape (rows, columns)
      - Head (first N rows)
      - Column info: dtype, non-null, missing count, % missing
      - Descriptive stats (numeric)
      - Categorical overview: top-K values per object/category column
    """
    import numpy as np
    import pandas as pd
    from IPython.display import display

    # Shape
    print("=== Shape ===")
    print(f"Rows: {df.shape[0]:,} | Columns: {df.shape[1]:,}\n")

    # Head
    print(f"=== Head (first {head} rows) ===")
    display(df.head(head))
    print()

    # Column info (missingness)
    print("=== Column Info ===")
    rows, info = df.shape[0], []
    for col in df.columns:
        non_null = df[col].notna().sum()
        nulls = rows - non_null
        pct_missing = (nulls / rows * 100) if rows else 0.0
        info.append([col, df[col].dtype, non_null, nulls, f"{pct_missing:.2f}%"])
    info_df = pd.DataFrame(
        info, columns=["Column", "Dtype", "Non-Null Count", "Missing Count", "% Missing"]
    )
    display(info_df)
    print()

    # Numeric stats
    print("=== Descriptive Statistics (Numeric) ===")
    display(df.describe(include=[np.number]).T.round(3))

    # Categorical overview
    cat_cols = [c for c in df.columns if df[c].dtype == "object" or str(df[c].dtype) == "category"]
    if cat_cols:
        print()
        print(f"=== Categorical Overview (top {top_k}) ===")
        cat_rows = []
        for c in cat_cols:
            vc = df[c].value_counts(dropna=False)
            total = int(vc.sum())
            for val, cnt in vc.head(top_k).items():
                pct = (cnt / total * 100) if total else 0.0
                cat_rows.append([c, str(val), int(cnt), f"{pct:.2f}%"])
        cat_df = pd.DataFrame(cat_rows, columns=["Column", "Value", "Count", "Percent"])
        display(cat_df)
```

## Raw Data: Initial Inspection


```python
# Inspect the raw dataset
df_summary(df)
```

    === Shape ===
    Rows: 19,382 | Columns: 12
    
    === Head (first 5 rows) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>#</th>
      <th>claim_status</th>
      <th>video_id</th>
      <th>video_duration_sec</th>
      <th>video_transcription_text</th>
      <th>verified_status</th>
      <th>author_ban_status</th>
      <th>video_view_count</th>
      <th>video_like_count</th>
      <th>video_share_count</th>
      <th>video_download_count</th>
      <th>video_comment_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>claim</td>
      <td>7017666017</td>
      <td>59</td>
      <td>someone shared with me that drone deliveries a...</td>
      <td>not verified</td>
      <td>under review</td>
      <td>343296.000</td>
      <td>19425.000</td>
      <td>241.000</td>
      <td>1.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>claim</td>
      <td>4014381136</td>
      <td>32</td>
      <td>someone shared with me that there are more mic...</td>
      <td>not verified</td>
      <td>active</td>
      <td>140877.000</td>
      <td>77355.000</td>
      <td>19034.000</td>
      <td>1161.000</td>
      <td>684.000</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>claim</td>
      <td>9859838091</td>
      <td>31</td>
      <td>someone shared with me that american industria...</td>
      <td>not verified</td>
      <td>active</td>
      <td>902185.000</td>
      <td>97690.000</td>
      <td>2858.000</td>
      <td>833.000</td>
      <td>329.000</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>claim</td>
      <td>1866847991</td>
      <td>25</td>
      <td>someone shared with me that the metro of st. p...</td>
      <td>not verified</td>
      <td>active</td>
      <td>437506.000</td>
      <td>239954.000</td>
      <td>34812.000</td>
      <td>1234.000</td>
      <td>584.000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>claim</td>
      <td>7105231098</td>
      <td>19</td>
      <td>someone shared with me that the number of busi...</td>
      <td>not verified</td>
      <td>active</td>
      <td>56167.000</td>
      <td>34987.000</td>
      <td>4110.000</td>
      <td>547.000</td>
      <td>152.000</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Column Info ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Column</th>
      <th>Dtype</th>
      <th>Non-Null Count</th>
      <th>Missing Count</th>
      <th>% Missing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>#</td>
      <td>int64</td>
      <td>19382</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>1</th>
      <td>claim_status</td>
      <td>object</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>2</th>
      <td>video_id</td>
      <td>int64</td>
      <td>19382</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>3</th>
      <td>video_duration_sec</td>
      <td>int64</td>
      <td>19382</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>4</th>
      <td>video_transcription_text</td>
      <td>object</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>5</th>
      <td>verified_status</td>
      <td>object</td>
      <td>19382</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>6</th>
      <td>author_ban_status</td>
      <td>object</td>
      <td>19382</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>7</th>
      <td>video_view_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>8</th>
      <td>video_like_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>9</th>
      <td>video_share_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>10</th>
      <td>video_download_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>11</th>
      <td>video_comment_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Descriptive Statistics (Numeric) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>count</th>
      <th>mean</th>
      <th>std</th>
      <th>min</th>
      <th>25%</th>
      <th>50%</th>
      <th>75%</th>
      <th>max</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>#</th>
      <td>19382.000</td>
      <td>9691.500</td>
      <td>5595.246</td>
      <td>1.000</td>
      <td>4846.250</td>
      <td>9691.500</td>
      <td>14536.750</td>
      <td>19382.000</td>
    </tr>
    <tr>
      <th>video_id</th>
      <td>19382.000</td>
      <td>5627454067.339</td>
      <td>2536440464.169</td>
      <td>1234959018.000</td>
      <td>3430416807.250</td>
      <td>5618663579.000</td>
      <td>7843960211.250</td>
      <td>9999873075.000</td>
    </tr>
    <tr>
      <th>video_duration_sec</th>
      <td>19382.000</td>
      <td>32.422</td>
      <td>16.230</td>
      <td>5.000</td>
      <td>18.000</td>
      <td>32.000</td>
      <td>47.000</td>
      <td>60.000</td>
    </tr>
    <tr>
      <th>video_view_count</th>
      <td>19084.000</td>
      <td>254708.559</td>
      <td>322893.281</td>
      <td>20.000</td>
      <td>4942.500</td>
      <td>9954.500</td>
      <td>504327.000</td>
      <td>999817.000</td>
    </tr>
    <tr>
      <th>video_like_count</th>
      <td>19084.000</td>
      <td>84304.636</td>
      <td>133420.547</td>
      <td>0.000</td>
      <td>810.750</td>
      <td>3403.500</td>
      <td>125020.000</td>
      <td>657830.000</td>
    </tr>
    <tr>
      <th>video_share_count</th>
      <td>19084.000</td>
      <td>16735.248</td>
      <td>32036.174</td>
      <td>0.000</td>
      <td>115.000</td>
      <td>717.000</td>
      <td>18222.000</td>
      <td>256130.000</td>
    </tr>
    <tr>
      <th>video_download_count</th>
      <td>19084.000</td>
      <td>1049.430</td>
      <td>2004.300</td>
      <td>0.000</td>
      <td>7.000</td>
      <td>46.000</td>
      <td>1156.250</td>
      <td>14994.000</td>
    </tr>
    <tr>
      <th>video_comment_count</th>
      <td>19084.000</td>
      <td>349.312</td>
      <td>799.639</td>
      <td>0.000</td>
      <td>1.000</td>
      <td>9.000</td>
      <td>292.000</td>
      <td>9599.000</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Categorical Overview (top 5) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Column</th>
      <th>Value</th>
      <th>Count</th>
      <th>Percent</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>claim_status</td>
      <td>claim</td>
      <td>9608</td>
      <td>49.57%</td>
    </tr>
    <tr>
      <th>1</th>
      <td>claim_status</td>
      <td>opinion</td>
      <td>9476</td>
      <td>48.89%</td>
    </tr>
    <tr>
      <th>2</th>
      <td>claim_status</td>
      <td>nan</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>3</th>
      <td>video_transcription_text</td>
      <td>nan</td>
      <td>298</td>
      <td>1.54%</td>
    </tr>
    <tr>
      <th>4</th>
      <td>video_transcription_text</td>
      <td>a colleague learned  from the media that chihu...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>5</th>
      <td>video_transcription_text</td>
      <td>someone learned  from the media that halley’s ...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>6</th>
      <td>video_transcription_text</td>
      <td>i read  in the media that a candle’s flame is ...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>7</th>
      <td>video_transcription_text</td>
      <td>a friend read  in the media a claim that icela...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>8</th>
      <td>verified_status</td>
      <td>not verified</td>
      <td>18142</td>
      <td>93.60%</td>
    </tr>
    <tr>
      <th>9</th>
      <td>verified_status</td>
      <td>verified</td>
      <td>1240</td>
      <td>6.40%</td>
    </tr>
    <tr>
      <th>10</th>
      <td>author_ban_status</td>
      <td>active</td>
      <td>15663</td>
      <td>80.81%</td>
    </tr>
    <tr>
      <th>11</th>
      <td>author_ban_status</td>
      <td>under review</td>
      <td>2080</td>
      <td>10.73%</td>
    </tr>
    <tr>
      <th>12</th>
      <td>author_ban_status</td>
      <td>banned</td>
      <td>1639</td>
      <td>8.46%</td>
    </tr>
  </tbody>
</table>
</div>


## Cleaning Step: Drop Rows with Missing Values


```python
# Drop rows with any missing values (row-wise) and re-inspect
df_clean = df.dropna(axis=0)
df_summary(df_clean)
```

    === Shape ===
    Rows: 19,084 | Columns: 12
    
    === Head (first 5 rows) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>#</th>
      <th>claim_status</th>
      <th>video_id</th>
      <th>video_duration_sec</th>
      <th>video_transcription_text</th>
      <th>verified_status</th>
      <th>author_ban_status</th>
      <th>video_view_count</th>
      <th>video_like_count</th>
      <th>video_share_count</th>
      <th>video_download_count</th>
      <th>video_comment_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>claim</td>
      <td>7017666017</td>
      <td>59</td>
      <td>someone shared with me that drone deliveries a...</td>
      <td>not verified</td>
      <td>under review</td>
      <td>343296.000</td>
      <td>19425.000</td>
      <td>241.000</td>
      <td>1.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>claim</td>
      <td>4014381136</td>
      <td>32</td>
      <td>someone shared with me that there are more mic...</td>
      <td>not verified</td>
      <td>active</td>
      <td>140877.000</td>
      <td>77355.000</td>
      <td>19034.000</td>
      <td>1161.000</td>
      <td>684.000</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>claim</td>
      <td>9859838091</td>
      <td>31</td>
      <td>someone shared with me that american industria...</td>
      <td>not verified</td>
      <td>active</td>
      <td>902185.000</td>
      <td>97690.000</td>
      <td>2858.000</td>
      <td>833.000</td>
      <td>329.000</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>claim</td>
      <td>1866847991</td>
      <td>25</td>
      <td>someone shared with me that the metro of st. p...</td>
      <td>not verified</td>
      <td>active</td>
      <td>437506.000</td>
      <td>239954.000</td>
      <td>34812.000</td>
      <td>1234.000</td>
      <td>584.000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>claim</td>
      <td>7105231098</td>
      <td>19</td>
      <td>someone shared with me that the number of busi...</td>
      <td>not verified</td>
      <td>active</td>
      <td>56167.000</td>
      <td>34987.000</td>
      <td>4110.000</td>
      <td>547.000</td>
      <td>152.000</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Column Info ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Column</th>
      <th>Dtype</th>
      <th>Non-Null Count</th>
      <th>Missing Count</th>
      <th>% Missing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>#</td>
      <td>int64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>1</th>
      <td>claim_status</td>
      <td>object</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>2</th>
      <td>video_id</td>
      <td>int64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>3</th>
      <td>video_duration_sec</td>
      <td>int64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>4</th>
      <td>video_transcription_text</td>
      <td>object</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>5</th>
      <td>verified_status</td>
      <td>object</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>6</th>
      <td>author_ban_status</td>
      <td>object</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>7</th>
      <td>video_view_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>8</th>
      <td>video_like_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>9</th>
      <td>video_share_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>10</th>
      <td>video_download_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
    <tr>
      <th>11</th>
      <td>video_comment_count</td>
      <td>float64</td>
      <td>19084</td>
      <td>0</td>
      <td>0.00%</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Descriptive Statistics (Numeric) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>count</th>
      <th>mean</th>
      <th>std</th>
      <th>min</th>
      <th>25%</th>
      <th>50%</th>
      <th>75%</th>
      <th>max</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>#</th>
      <td>19084.000</td>
      <td>9542.500</td>
      <td>5509.221</td>
      <td>1.000</td>
      <td>4771.750</td>
      <td>9542.500</td>
      <td>14313.250</td>
      <td>19084.000</td>
    </tr>
    <tr>
      <th>video_id</th>
      <td>19084.000</td>
      <td>5624839917.874</td>
      <td>2537030180.259</td>
      <td>1234959018.000</td>
      <td>3425100251.250</td>
      <td>5609500370.000</td>
      <td>7840823300.500</td>
      <td>9999873075.000</td>
    </tr>
    <tr>
      <th>video_duration_sec</th>
      <td>19084.000</td>
      <td>32.424</td>
      <td>16.226</td>
      <td>5.000</td>
      <td>18.000</td>
      <td>32.000</td>
      <td>47.000</td>
      <td>60.000</td>
    </tr>
    <tr>
      <th>video_view_count</th>
      <td>19084.000</td>
      <td>254708.559</td>
      <td>322893.281</td>
      <td>20.000</td>
      <td>4942.500</td>
      <td>9954.500</td>
      <td>504327.000</td>
      <td>999817.000</td>
    </tr>
    <tr>
      <th>video_like_count</th>
      <td>19084.000</td>
      <td>84304.636</td>
      <td>133420.547</td>
      <td>0.000</td>
      <td>810.750</td>
      <td>3403.500</td>
      <td>125020.000</td>
      <td>657830.000</td>
    </tr>
    <tr>
      <th>video_share_count</th>
      <td>19084.000</td>
      <td>16735.248</td>
      <td>32036.174</td>
      <td>0.000</td>
      <td>115.000</td>
      <td>717.000</td>
      <td>18222.000</td>
      <td>256130.000</td>
    </tr>
    <tr>
      <th>video_download_count</th>
      <td>19084.000</td>
      <td>1049.430</td>
      <td>2004.300</td>
      <td>0.000</td>
      <td>7.000</td>
      <td>46.000</td>
      <td>1156.250</td>
      <td>14994.000</td>
    </tr>
    <tr>
      <th>video_comment_count</th>
      <td>19084.000</td>
      <td>349.312</td>
      <td>799.639</td>
      <td>0.000</td>
      <td>1.000</td>
      <td>9.000</td>
      <td>292.000</td>
      <td>9599.000</td>
    </tr>
  </tbody>
</table>
</div>


    
    === Categorical Overview (top 5) ===



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Column</th>
      <th>Value</th>
      <th>Count</th>
      <th>Percent</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>claim_status</td>
      <td>claim</td>
      <td>9608</td>
      <td>50.35%</td>
    </tr>
    <tr>
      <th>1</th>
      <td>claim_status</td>
      <td>opinion</td>
      <td>9476</td>
      <td>49.65%</td>
    </tr>
    <tr>
      <th>2</th>
      <td>video_transcription_text</td>
      <td>a colleague learned  from the media a claim th...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>3</th>
      <td>video_transcription_text</td>
      <td>a friend read  in the media that badminton is ...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>4</th>
      <td>video_transcription_text</td>
      <td>a colleague learned  from the media a claim th...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>5</th>
      <td>video_transcription_text</td>
      <td>a colleague read  in the media that earth days...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>6</th>
      <td>video_transcription_text</td>
      <td>someone learned  from the media a claim that t...</td>
      <td>2</td>
      <td>0.01%</td>
    </tr>
    <tr>
      <th>7</th>
      <td>verified_status</td>
      <td>not verified</td>
      <td>17884</td>
      <td>93.71%</td>
    </tr>
    <tr>
      <th>8</th>
      <td>verified_status</td>
      <td>verified</td>
      <td>1200</td>
      <td>6.29%</td>
    </tr>
    <tr>
      <th>9</th>
      <td>author_ban_status</td>
      <td>active</td>
      <td>15383</td>
      <td>80.61%</td>
    </tr>
    <tr>
      <th>10</th>
      <td>author_ban_status</td>
      <td>under review</td>
      <td>2066</td>
      <td>10.83%</td>
    </tr>
    <tr>
      <th>11</th>
      <td>author_ban_status</td>
      <td>banned</td>
      <td>1635</td>
      <td>8.57%</td>
    </tr>
  </tbody>
</table>
</div>


## Group-Level Metric: Mean Views by Verification Status


```python
# Mean views by verification status (cleaned data)
views_by_verification = (
    df_clean.groupby("verified_status")["video_view_count"]
            .mean()
            .round(2)
            .sort_values(ascending=False)
)
print("=== Mean Views by Verification Status ===")
print(views_by_verification)
```

    === Mean Views by Verification Status ===
    verified_status
    not verified   265663.790
    verified        91439.160
    Name: video_view_count, dtype: float64


## Hypothesis Testing

We test whether account verification status is associated with a difference in mean video views using a two-sample t-test (Welch, unequal variances) at α = 0.05.

- **Null hypothesis (H₀):** There is no difference in mean view counts between verified and unverified accounts. Any observed difference is due to sampling variability.  
- **Alternative hypothesis (Hₐ):** There is a difference in mean view counts between verified and unverified accounts.


```python
# ------------------------------------------------------------
# Welch two-sample t-test: mean views by verification status
# ------------------------------------------------------------

# Pre-conditions
assert "verified_status" in df_clean.columns, "Missing column: verified_status"
assert "video_view_count" in df_clean.columns, "Missing column: video_view_count"

# Split samples
not_verified = df_clean.loc[df_clean["verified_status"] == "not verified", "video_view_count"]
verified     = df_clean.loc[df_clean["verified_status"] == "verified", "video_view_count"]

# Basic sample diagnostics
n_nv, n_v = len(not_verified), len(verified)
m_nv, m_v = not_verified.mean(), verified.mean()

# Welch t-test (unequal variances)
t_stat, p_val = stats.ttest_ind(a=not_verified, b=verified, equal_var=False)

print("Two-Sample t-Test (Welch)")
print(f"n (not verified) = {n_nv:,}, mean = {m_nv:,.2f}")
print(f"n (verified)     = {n_v:,}, mean = {m_v:,.2f}")
print(f"T-statistic: {t_stat:.3f}")
print(f"P-value: {p_val:.3e}")
```

    Two-Sample t-Test (Welch)
    n (not verified) = 17,884, mean = 265,663.79
    n (verified)     = 1,200, mean = 91,439.16
    T-statistic: 25.499
    P-value: 2.609e-120



```python
# ------------------------------------------------------------
# Effect size (Hedges' g) + 95% CI for mean difference (Welch)
# ------------------------------------------------------------
import numpy as np
from math import sqrt
from scipy import stats as _stats  # avoid name shadowing

s_nv = not_verified.std(ddof=1)
s_v  = verified.std(ddof=1)

# Cohen's d with pooled SD, then small-sample correction to Hedges' g
sp2 = ((n_nv - 1) * s_nv**2 + (n_v - 1) * s_v**2) / (n_nv + n_v - 2)
d   = (m_nv - m_v) / np.sqrt(sp2)
J   = 1 - 3 / (4 * (n_nv + n_v) - 9)
g   = d * J

# Welch 95% CI for mean difference
diff = m_nv - m_v
se   = np.sqrt(s_nv**2 / n_nv + s_v**2 / n_v)
df_w = (s_nv**2 / n_nv + s_v**2 / n_v)**2 / ((s_nv**2 / n_nv)**2 / (n_nv - 1) + (s_v**2 / n_v)**2 / (n_v - 1))
tcrit = _stats.t.ppf(0.975, df_w)
ci_lo, ci_hi = diff - tcrit * se, diff + tcrit * se

print(f"Mean difference (not verified − verified): {diff:,.2f}")
print(f"95% CI (Welch): [{ci_lo:,.2f}, {ci_hi:,.2f}]")
print(f"Hedges' g: {g:.2f}")
```

    Mean difference (not verified − verified): 174,224.62
    95% CI (Welch): [160,822.87, 187,626.37]
    Hedges' g: 0.54


## Conclusion

After cleaning, the dataset contained **19,084 videos × 12 features** with no missing values. Most accounts were **not verified (~94%)** and **active (~81%)**. Unverified accounts averaged ~265K views per video, while verified accounts averaged ~91K.

A Welch two-sample t-test showed the difference in mean views is **highly significant** (t ≈ 25.5, p ≈ 2.609 × 10⁻¹²⁰). Effect size analysis (Hedges’ g ≈ 0.54) indicates a **moderate practical difference**, with a mean gap of ~174K views (95% CI: 161K–188K). We therefore **reject H₀**: verified and unverified accounts differ substantially in reach.

**Implication:** Verification status is strongly associated with audience reach. Next steps: model verification alongside content and behavioral features (e.g., content type, posting cadence, follower count) to determine whether verification itself drives visibility or proxies for other factors.
