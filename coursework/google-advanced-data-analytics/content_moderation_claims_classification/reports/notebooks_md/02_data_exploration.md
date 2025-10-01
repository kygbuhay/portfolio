# TikTok Claims — Exploratory Data Analysis

**Owner:** Katherine Ygbuhay  
**Updated:** September 2025  
**Stage:** 02 

**Goal:**  
Perform structured exploratory data analysis (EDA) to profile the dataset, assess quality, and surface distributional patterns or imbalances that may affect modeling.  

**Contents:**  
- Dataset structure and variable types  
- Missing values and data quality checks  
- Standardization of categorical fields  
- Frequency and balance checks across claim and author ban status  
- Distributional review of engagement counts (skewness, outliers, variance)

## Dataset Overview and Schema


```python
# Core packages
import pandas as pd
import numpy as np

# Plotly renderer setup for consistent inline visuals in JupyterLab
import plotly.io as pio
pio.renderers.default = "jupyterlab"  # fallback: "png" if running outside Lab

# Improve readability of numeric outputs
pd.options.display.float_format = '{:.3f}'.format
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
# Load dataset into dataframe
df = pd.read_csv(DATA_FILE)
```


```python
# --- Basic overview: shape, columns, and a small preview --------------------
# Shape: quick sense of dataset size (rows, columns)
print("Shape:", df.shape)

# Columns: ordered list of field names to orient yourself
print("Columns:", list(df.columns))

# Preview: first 10 rows to eyeball values, formats, and obvious anomalies
display(df.head(10))
```

    Shape: (19382, 12)
    Columns: ['#', 'claim_status', 'video_id', 'video_duration_sec', 'video_transcription_text', 'verified_status', 'author_ban_status', 'video_view_count', 'video_like_count', 'video_share_count', 'video_download_count', 'video_comment_count']



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
    <tr>
      <th>5</th>
      <td>6</td>
      <td>claim</td>
      <td>8972200955</td>
      <td>35</td>
      <td>someone shared with me that gross domestic pro...</td>
      <td>not verified</td>
      <td>under review</td>
      <td>336647.000</td>
      <td>175546.000</td>
      <td>62303.000</td>
      <td>4293.000</td>
      <td>1857.000</td>
    </tr>
    <tr>
      <th>6</th>
      <td>7</td>
      <td>claim</td>
      <td>4958886992</td>
      <td>16</td>
      <td>someone shared with me that elvis presley has ...</td>
      <td>not verified</td>
      <td>active</td>
      <td>750345.000</td>
      <td>486192.000</td>
      <td>193911.000</td>
      <td>8616.000</td>
      <td>5446.000</td>
    </tr>
    <tr>
      <th>7</th>
      <td>8</td>
      <td>claim</td>
      <td>2270982263</td>
      <td>41</td>
      <td>someone shared with me that the best selling s...</td>
      <td>not verified</td>
      <td>active</td>
      <td>547532.000</td>
      <td>1072.000</td>
      <td>50.000</td>
      <td>22.000</td>
      <td>11.000</td>
    </tr>
    <tr>
      <th>8</th>
      <td>9</td>
      <td>claim</td>
      <td>5235769692</td>
      <td>50</td>
      <td>someone shared with me that about half of the ...</td>
      <td>not verified</td>
      <td>active</td>
      <td>24819.000</td>
      <td>10160.000</td>
      <td>1050.000</td>
      <td>53.000</td>
      <td>27.000</td>
    </tr>
    <tr>
      <th>9</th>
      <td>10</td>
      <td>claim</td>
      <td>4660861094</td>
      <td>45</td>
      <td>someone shared with me that it would take a 50...</td>
      <td>verified</td>
      <td>active</td>
      <td>931587.000</td>
      <td>171051.000</td>
      <td>67739.000</td>
      <td>4104.000</td>
      <td>2540.000</td>
    </tr>
  </tbody>
</table>
</div>



```python
# --- Schema & missingness: tidy table vs. df.info() text dump ---------------
# Build a small DataFrame summarizing each column's dtype and missingness.
# This renders cleanly in notebooks and is easier to scan/sort than raw text.

schema = (
    df.dtypes.rename("dtype").to_frame()             # column -> dtype
      .assign(
          non_null = df.notna().sum(),               # count of non-missing
          missing  = df.isna().sum(),                # count of missing
          missing_pct = lambda t: 100 * t["missing"] / len(df)  # % missing
      )
      .reset_index()
      .rename(columns={"index": "column"})
      .sort_values("column")
)

# Pretty formatting for percent column; keeps numeric types for others
display(schema.style.format({"missing_pct": "{:.2f}%"}))
```


<style type="text/css">
</style>
<table id="T_29278">
  <thead>
    <tr>
      <th class="blank level0" >&nbsp;</th>
      <th id="T_29278_level0_col0" class="col_heading level0 col0" >column</th>
      <th id="T_29278_level0_col1" class="col_heading level0 col1" >dtype</th>
      <th id="T_29278_level0_col2" class="col_heading level0 col2" >non_null</th>
      <th id="T_29278_level0_col3" class="col_heading level0 col3" >missing</th>
      <th id="T_29278_level0_col4" class="col_heading level0 col4" >missing_pct</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th id="T_29278_level0_row0" class="row_heading level0 row0" >0</th>
      <td id="T_29278_row0_col0" class="data row0 col0" >#</td>
      <td id="T_29278_row0_col1" class="data row0 col1" >int64</td>
      <td id="T_29278_row0_col2" class="data row0 col2" >19382</td>
      <td id="T_29278_row0_col3" class="data row0 col3" >0</td>
      <td id="T_29278_row0_col4" class="data row0 col4" >0.00%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row1" class="row_heading level0 row1" >6</th>
      <td id="T_29278_row1_col0" class="data row1 col0" >author_ban_status</td>
      <td id="T_29278_row1_col1" class="data row1 col1" >object</td>
      <td id="T_29278_row1_col2" class="data row1 col2" >19382</td>
      <td id="T_29278_row1_col3" class="data row1 col3" >0</td>
      <td id="T_29278_row1_col4" class="data row1 col4" >0.00%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row2" class="row_heading level0 row2" >1</th>
      <td id="T_29278_row2_col0" class="data row2 col0" >claim_status</td>
      <td id="T_29278_row2_col1" class="data row2 col1" >object</td>
      <td id="T_29278_row2_col2" class="data row2 col2" >19084</td>
      <td id="T_29278_row2_col3" class="data row2 col3" >298</td>
      <td id="T_29278_row2_col4" class="data row2 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row3" class="row_heading level0 row3" >5</th>
      <td id="T_29278_row3_col0" class="data row3 col0" >verified_status</td>
      <td id="T_29278_row3_col1" class="data row3 col1" >object</td>
      <td id="T_29278_row3_col2" class="data row3 col2" >19382</td>
      <td id="T_29278_row3_col3" class="data row3 col3" >0</td>
      <td id="T_29278_row3_col4" class="data row3 col4" >0.00%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row4" class="row_heading level0 row4" >11</th>
      <td id="T_29278_row4_col0" class="data row4 col0" >video_comment_count</td>
      <td id="T_29278_row4_col1" class="data row4 col1" >float64</td>
      <td id="T_29278_row4_col2" class="data row4 col2" >19084</td>
      <td id="T_29278_row4_col3" class="data row4 col3" >298</td>
      <td id="T_29278_row4_col4" class="data row4 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row5" class="row_heading level0 row5" >10</th>
      <td id="T_29278_row5_col0" class="data row5 col0" >video_download_count</td>
      <td id="T_29278_row5_col1" class="data row5 col1" >float64</td>
      <td id="T_29278_row5_col2" class="data row5 col2" >19084</td>
      <td id="T_29278_row5_col3" class="data row5 col3" >298</td>
      <td id="T_29278_row5_col4" class="data row5 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row6" class="row_heading level0 row6" >3</th>
      <td id="T_29278_row6_col0" class="data row6 col0" >video_duration_sec</td>
      <td id="T_29278_row6_col1" class="data row6 col1" >int64</td>
      <td id="T_29278_row6_col2" class="data row6 col2" >19382</td>
      <td id="T_29278_row6_col3" class="data row6 col3" >0</td>
      <td id="T_29278_row6_col4" class="data row6 col4" >0.00%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row7" class="row_heading level0 row7" >2</th>
      <td id="T_29278_row7_col0" class="data row7 col0" >video_id</td>
      <td id="T_29278_row7_col1" class="data row7 col1" >int64</td>
      <td id="T_29278_row7_col2" class="data row7 col2" >19382</td>
      <td id="T_29278_row7_col3" class="data row7 col3" >0</td>
      <td id="T_29278_row7_col4" class="data row7 col4" >0.00%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row8" class="row_heading level0 row8" >8</th>
      <td id="T_29278_row8_col0" class="data row8 col0" >video_like_count</td>
      <td id="T_29278_row8_col1" class="data row8 col1" >float64</td>
      <td id="T_29278_row8_col2" class="data row8 col2" >19084</td>
      <td id="T_29278_row8_col3" class="data row8 col3" >298</td>
      <td id="T_29278_row8_col4" class="data row8 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row9" class="row_heading level0 row9" >9</th>
      <td id="T_29278_row9_col0" class="data row9 col0" >video_share_count</td>
      <td id="T_29278_row9_col1" class="data row9 col1" >float64</td>
      <td id="T_29278_row9_col2" class="data row9 col2" >19084</td>
      <td id="T_29278_row9_col3" class="data row9 col3" >298</td>
      <td id="T_29278_row9_col4" class="data row9 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row10" class="row_heading level0 row10" >4</th>
      <td id="T_29278_row10_col0" class="data row10 col0" >video_transcription_text</td>
      <td id="T_29278_row10_col1" class="data row10 col1" >object</td>
      <td id="T_29278_row10_col2" class="data row10 col2" >19084</td>
      <td id="T_29278_row10_col3" class="data row10 col3" >298</td>
      <td id="T_29278_row10_col4" class="data row10 col4" >1.54%</td>
    </tr>
    <tr>
      <th id="T_29278_level0_row11" class="row_heading level0 row11" >7</th>
      <td id="T_29278_row11_col0" class="data row11 col0" >video_view_count</td>
      <td id="T_29278_row11_col1" class="data row11 col1" >float64</td>
      <td id="T_29278_row11_col2" class="data row11 col2" >19084</td>
      <td id="T_29278_row11_col3" class="data row11 col3" >298</td>
      <td id="T_29278_row11_col4" class="data row11 col4" >1.54%</td>
    </tr>
  </tbody>
</table>




```python
# --- Numeric summary: go beyond describe() with median, skew, missing% ------
# We start from describe(), transpose so rows = features, and add useful stats.

# Select numeric-only to avoid warnings in skew/describe
num_cols = df.select_dtypes(include="number")

# If there are no numeric columns, skip gracefully
if num_cols.shape[1] == 0:
    print("No numeric columns to summarize.")
else:
    num_summary = (
        num_cols.describe(percentiles=[0.25, 0.5, 0.75]).T
          .rename(columns={"50%": "median"})            # clearer than '50%'
          .assign(
              missing = num_cols.isna().sum(),          # missing counts
              missing_pct = lambda t: 100 * t["missing"] / len(df),
              skew = num_cols.skew(numeric_only=True)   # distribution asymmetry
          )
          # Order columns for stakeholder readability
          .loc[:, ["count","mean","std","min","25%","median","75%","max","skew","missing_pct"]]
          .sort_index()
    )

    # Format skew and missing% to two decimals; leave others as-is
    display(num_summary.style.format({"skew": "{:.2f}", "missing_pct": "{:.2f}%"}))
```


<style type="text/css">
</style>
<table id="T_b4735">
  <thead>
    <tr>
      <th class="blank level0" >&nbsp;</th>
      <th id="T_b4735_level0_col0" class="col_heading level0 col0" >count</th>
      <th id="T_b4735_level0_col1" class="col_heading level0 col1" >mean</th>
      <th id="T_b4735_level0_col2" class="col_heading level0 col2" >std</th>
      <th id="T_b4735_level0_col3" class="col_heading level0 col3" >min</th>
      <th id="T_b4735_level0_col4" class="col_heading level0 col4" >25%</th>
      <th id="T_b4735_level0_col5" class="col_heading level0 col5" >median</th>
      <th id="T_b4735_level0_col6" class="col_heading level0 col6" >75%</th>
      <th id="T_b4735_level0_col7" class="col_heading level0 col7" >max</th>
      <th id="T_b4735_level0_col8" class="col_heading level0 col8" >skew</th>
      <th id="T_b4735_level0_col9" class="col_heading level0 col9" >missing_pct</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th id="T_b4735_level0_row0" class="row_heading level0 row0" >#</th>
      <td id="T_b4735_row0_col0" class="data row0 col0" >19382.000000</td>
      <td id="T_b4735_row0_col1" class="data row0 col1" >9691.500000</td>
      <td id="T_b4735_row0_col2" class="data row0 col2" >5595.245794</td>
      <td id="T_b4735_row0_col3" class="data row0 col3" >1.000000</td>
      <td id="T_b4735_row0_col4" class="data row0 col4" >4846.250000</td>
      <td id="T_b4735_row0_col5" class="data row0 col5" >9691.500000</td>
      <td id="T_b4735_row0_col6" class="data row0 col6" >14536.750000</td>
      <td id="T_b4735_row0_col7" class="data row0 col7" >19382.000000</td>
      <td id="T_b4735_row0_col8" class="data row0 col8" >0.00</td>
      <td id="T_b4735_row0_col9" class="data row0 col9" >0.00%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row1" class="row_heading level0 row1" >video_comment_count</th>
      <td id="T_b4735_row1_col0" class="data row1 col0" >19084.000000</td>
      <td id="T_b4735_row1_col1" class="data row1 col1" >349.312146</td>
      <td id="T_b4735_row1_col2" class="data row1 col2" >799.638865</td>
      <td id="T_b4735_row1_col3" class="data row1 col3" >0.000000</td>
      <td id="T_b4735_row1_col4" class="data row1 col4" >1.000000</td>
      <td id="T_b4735_row1_col5" class="data row1 col5" >9.000000</td>
      <td id="T_b4735_row1_col6" class="data row1 col6" >292.000000</td>
      <td id="T_b4735_row1_col7" class="data row1 col7" >9599.000000</td>
      <td id="T_b4735_row1_col8" class="data row1 col8" >3.89</td>
      <td id="T_b4735_row1_col9" class="data row1 col9" >1.54%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row2" class="row_heading level0 row2" >video_download_count</th>
      <td id="T_b4735_row2_col0" class="data row2 col0" >19084.000000</td>
      <td id="T_b4735_row2_col1" class="data row2 col1" >1049.429627</td>
      <td id="T_b4735_row2_col2" class="data row2 col2" >2004.299894</td>
      <td id="T_b4735_row2_col3" class="data row2 col3" >0.000000</td>
      <td id="T_b4735_row2_col4" class="data row2 col4" >7.000000</td>
      <td id="T_b4735_row2_col5" class="data row2 col5" >46.000000</td>
      <td id="T_b4735_row2_col6" class="data row2 col6" >1156.250000</td>
      <td id="T_b4735_row2_col7" class="data row2 col7" >14994.000000</td>
      <td id="T_b4735_row2_col8" class="data row2 col8" >2.74</td>
      <td id="T_b4735_row2_col9" class="data row2 col9" >1.54%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row3" class="row_heading level0 row3" >video_duration_sec</th>
      <td id="T_b4735_row3_col0" class="data row3 col0" >19382.000000</td>
      <td id="T_b4735_row3_col1" class="data row3 col1" >32.421732</td>
      <td id="T_b4735_row3_col2" class="data row3 col2" >16.229967</td>
      <td id="T_b4735_row3_col3" class="data row3 col3" >5.000000</td>
      <td id="T_b4735_row3_col4" class="data row3 col4" >18.000000</td>
      <td id="T_b4735_row3_col5" class="data row3 col5" >32.000000</td>
      <td id="T_b4735_row3_col6" class="data row3 col6" >47.000000</td>
      <td id="T_b4735_row3_col7" class="data row3 col7" >60.000000</td>
      <td id="T_b4735_row3_col8" class="data row3 col8" >0.00</td>
      <td id="T_b4735_row3_col9" class="data row3 col9" >0.00%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row4" class="row_heading level0 row4" >video_id</th>
      <td id="T_b4735_row4_col0" class="data row4 col0" >19382.000000</td>
      <td id="T_b4735_row4_col1" class="data row4 col1" >5627454067.339129</td>
      <td id="T_b4735_row4_col2" class="data row4 col2" >2536440464.169367</td>
      <td id="T_b4735_row4_col3" class="data row4 col3" >1234959018.000000</td>
      <td id="T_b4735_row4_col4" class="data row4 col4" >3430416807.250000</td>
      <td id="T_b4735_row4_col5" class="data row4 col5" >5618663579.000000</td>
      <td id="T_b4735_row4_col6" class="data row4 col6" >7843960211.250000</td>
      <td id="T_b4735_row4_col7" class="data row4 col7" >9999873075.000000</td>
      <td id="T_b4735_row4_col8" class="data row4 col8" >0.00</td>
      <td id="T_b4735_row4_col9" class="data row4 col9" >0.00%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row5" class="row_heading level0 row5" >video_like_count</th>
      <td id="T_b4735_row5_col0" class="data row5 col0" >19084.000000</td>
      <td id="T_b4735_row5_col1" class="data row5 col1" >84304.636030</td>
      <td id="T_b4735_row5_col2" class="data row5 col2" >133420.546814</td>
      <td id="T_b4735_row5_col3" class="data row5 col3" >0.000000</td>
      <td id="T_b4735_row5_col4" class="data row5 col4" >810.750000</td>
      <td id="T_b4735_row5_col5" class="data row5 col5" >3403.500000</td>
      <td id="T_b4735_row5_col6" class="data row5 col6" >125020.000000</td>
      <td id="T_b4735_row5_col7" class="data row5 col7" >657830.000000</td>
      <td id="T_b4735_row5_col8" class="data row5 col8" >1.79</td>
      <td id="T_b4735_row5_col9" class="data row5 col9" >1.54%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row6" class="row_heading level0 row6" >video_share_count</th>
      <td id="T_b4735_row6_col0" class="data row6 col0" >19084.000000</td>
      <td id="T_b4735_row6_col1" class="data row6 col1" >16735.248323</td>
      <td id="T_b4735_row6_col2" class="data row6 col2" >32036.174350</td>
      <td id="T_b4735_row6_col3" class="data row6 col3" >0.000000</td>
      <td id="T_b4735_row6_col4" class="data row6 col4" >115.000000</td>
      <td id="T_b4735_row6_col5" class="data row6 col5" >717.000000</td>
      <td id="T_b4735_row6_col6" class="data row6 col6" >18222.000000</td>
      <td id="T_b4735_row6_col7" class="data row6 col7" >256130.000000</td>
      <td id="T_b4735_row6_col8" class="data row6 col8" >2.72</td>
      <td id="T_b4735_row6_col9" class="data row6 col9" >1.54%</td>
    </tr>
    <tr>
      <th id="T_b4735_level0_row7" class="row_heading level0 row7" >video_view_count</th>
      <td id="T_b4735_row7_col0" class="data row7 col0" >19084.000000</td>
      <td id="T_b4735_row7_col1" class="data row7 col1" >254708.558688</td>
      <td id="T_b4735_row7_col2" class="data row7 col2" >322893.280814</td>
      <td id="T_b4735_row7_col3" class="data row7 col3" >20.000000</td>
      <td id="T_b4735_row7_col4" class="data row7 col4" >4942.500000</td>
      <td id="T_b4735_row7_col5" class="data row7 col5" >9954.500000</td>
      <td id="T_b4735_row7_col6" class="data row7 col6" >504327.000000</td>
      <td id="T_b4735_row7_col7" class="data row7 col7" >999817.000000</td>
      <td id="T_b4735_row7_col8" class="data row7 col8" >0.93</td>
      <td id="T_b4735_row7_col9" class="data row7 col9" >1.54%</td>
    </tr>
  </tbody>
</table>




```python
# --- Target label distribution: class balance sanity check ------------------
# Replace 'claim_status' with your actual label column name if different.

label_col = "claim_status"

if label_col in df.columns:
    label_counts = (
        df[label_col]
          .value_counts(dropna=False)                      # include NaN if present
          .to_frame("count")
          .assign(pct=lambda s: (s["count"] / s["count"].sum() * 100).round(2))
    )
    display(label_counts)
else:
    print(f"Label column '{label_col}' not found; skipping class balance table.")
```


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
      <th>pct</th>
    </tr>
    <tr>
      <th>claim_status</th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>claim</th>
      <td>9608</td>
      <td>49.570</td>
    </tr>
    <tr>
      <th>opinion</th>
      <td>9476</td>
      <td>48.890</td>
    </tr>
    <tr>
      <th>NaN</th>
      <td>298</td>
      <td>1.540</td>
    </tr>
  </tbody>
</table>
</div>


### Data Inspection Summary

- **Dataset structure:** The dataframe contains 19,382 observations of TikTok videos, each with categorical, text, and numerical fields describing claims, opinions, and metadata.  
- **Variable types:** Columns include five `float64`, three `int64`, and four `object` datatypes.  
- **Missing values:** Several variables have nulls, including *claim status*, *video transcription*, and the count variables.  
- **Distributional checks:** Many count variables show long right tails and potential outliers. Their maximum values are orders of magnitude larger than the interquartile ranges, resulting in high standard deviations.  

## Exploratory Data Analysis: Claims, Engagement, and Author Status


```python
# Distribution of claim vs opinion labels
df['claim_status'].value_counts()
```




    claim_status
    claim      9608
    opinion    9476
    Name: count, dtype: int64



- The dataset is relatively balanced between *claim* and *opinion* labels.


```python
# Drop unlabeled rows before modeling
df = df[df['claim_status'].notna()].copy()
```

- Note: A small number of rows lack a `claim_status` label. These observations are excluded to ensure clean, labeled data for modeling.


```python
# Average and median view counts for claim vs opinion videos
claims = df[df['claim_status'] == 'claim']
opinions = df[df['claim_status'] == 'opinion']

print("Claims — mean:", claims['video_view_count'].mean(), 
      "median:", claims['video_view_count'].median())
print("Opinions — mean:", opinions['video_view_count'].mean(), 
      "median:", opinions['video_view_count'].median())
```

    Claims — mean: 501029.4527477102 median: 501555.0
    Opinions — mean: 4956.43224989447 median: 4953.0


- Within each label, mean and median view counts are close.  
- However, claim videos generally attract far higher view counts than opinion videos.


```python
# Normalize author ban status labels for consistency
df['author_ban_status'] = (
    df['author_ban_status']
    .str.strip().str.lower()
    .replace({'under  review': 'under review'})  # collapse double spaces
)

# Cross-tabulation of claim status and author ban status
df.groupby(['claim_status', 'author_ban_status']).size().unstack(fill_value=0)
```




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
      <th>author_ban_status</th>
      <th>active</th>
      <th>banned</th>
      <th>under review</th>
    </tr>
    <tr>
      <th>claim_status</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>claim</th>
      <td>6566</td>
      <td>1439</td>
      <td>1603</td>
    </tr>
    <tr>
      <th>opinion</th>
      <td>8817</td>
      <td>196</td>
      <td>463</td>
    </tr>
  </tbody>
</table>
</div>



- Claim videos are more common among banned authors than opinion videos.  
- This could reflect stricter moderation for claims, but causation cannot be inferred:  
  - Claim content may inherently invite more scrutiny.  
  - Or authors posting claims may also post other content that violates terms.  
- Important: we cannot conclude that specific videos caused a ban.


```python
# Engagement metrics (mean/median) by author ban status
df.groupby('author_ban_status').agg({
    'video_view_count': ['mean', 'median'],
    'video_like_count': ['mean', 'median'],
    'video_share_count': ['mean', 'median']
})
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th colspan="2" halign="left">video_view_count</th>
      <th colspan="2" halign="left">video_like_count</th>
      <th colspan="2" halign="left">video_share_count</th>
    </tr>
    <tr>
      <th></th>
      <th>mean</th>
      <th>median</th>
      <th>mean</th>
      <th>median</th>
      <th>mean</th>
      <th>median</th>
    </tr>
    <tr>
      <th>author_ban_status</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>active</th>
      <td>215927.040</td>
      <td>8616.000</td>
      <td>71036.534</td>
      <td>2222.000</td>
      <td>14111.466</td>
      <td>437.000</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>445845.439</td>
      <td>448201.000</td>
      <td>153017.237</td>
      <td>105573.000</td>
      <td>29998.943</td>
      <td>14468.000</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>392204.836</td>
      <td>365245.500</td>
      <td>128718.050</td>
      <td>71204.500</td>
      <td>25774.697</td>
      <td>9444.000</td>
    </tr>
  </tbody>
</table>
</div>



- Banned authors’ videos tend to have substantially higher engagement (views, likes, shares).  
- Mean values are consistently greater than medians, pointing to long-tailed distributions.  


```python
# Engagement metrics (count, mean, median) by author ban status
df.groupby('author_ban_status').agg({
    'video_view_count': ['count', 'mean', 'median'],
    'video_like_count': ['count', 'mean', 'median'],
    'video_share_count': ['count', 'mean', 'median']
})
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th colspan="3" halign="left">video_view_count</th>
      <th colspan="3" halign="left">video_like_count</th>
      <th colspan="3" halign="left">video_share_count</th>
    </tr>
    <tr>
      <th></th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
    </tr>
    <tr>
      <th>author_ban_status</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>active</th>
      <td>15383</td>
      <td>215927.040</td>
      <td>8616.000</td>
      <td>15383</td>
      <td>71036.534</td>
      <td>2222.000</td>
      <td>15383</td>
      <td>14111.466</td>
      <td>437.000</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>1635</td>
      <td>445845.439</td>
      <td>448201.000</td>
      <td>1635</td>
      <td>153017.237</td>
      <td>105573.000</td>
      <td>1635</td>
      <td>29998.943</td>
      <td>14468.000</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>2066</td>
      <td>392204.836</td>
      <td>365245.500</td>
      <td>2066</td>
      <td>128718.050</td>
      <td>71204.500</td>
      <td>2066</td>
      <td>25774.697</td>
      <td>9444.000</td>
    </tr>
  </tbody>
</table>
</div>



- Banned and under-review authors receive far more engagement than active authors.  
- Count columns provide context: sample sizes differ between groups.  
- Means >> medians confirm outliers driving up averages.  


```python
# Median share counts by author ban status
df.groupby('author_ban_status')['video_share_count'].median()
```




    author_ban_status
    active           437.000
    banned         14468.000
    under review    9444.000
    Name: video_share_count, dtype: float64



- Banned authors’ videos have a median share count ~33× higher than active authors.  
- This dramatic difference highlights the role of virality and moderation bias.  


```python
# Per-view engagement ratios (safe against zero views)
denom = df['video_view_count'].replace(0, np.nan)

df['likes_per_view']    = df['video_like_count']    / denom
df['comments_per_view'] = df['video_comment_count'] / denom
df['shares_per_view']   = df['video_share_count']   / denom

# Replace NaNs from divide-by-zero with 0
df[['likes_per_view','comments_per_view','shares_per_view']] = (
    df[['likes_per_view','comments_per_view','shares_per_view']].fillna(0)
)

# Summary stats by claim and author ban status
df.groupby(['claim_status', 'author_ban_status']).agg({
    'likes_per_view': ['mean', 'median'],
    'comments_per_view': ['mean', 'median'],
    'shares_per_view': ['mean', 'median']
})
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th colspan="2" halign="left">likes_per_view</th>
      <th colspan="2" halign="left">comments_per_view</th>
      <th colspan="2" halign="left">shares_per_view</th>
    </tr>
    <tr>
      <th></th>
      <th></th>
      <th>mean</th>
      <th>median</th>
      <th>mean</th>
      <th>median</th>
      <th>mean</th>
      <th>median</th>
    </tr>
    <tr>
      <th>claim_status</th>
      <th>author_ban_status</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="3" valign="top">claim</th>
      <th>active</th>
      <td>0.330</td>
      <td>0.327</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>0.065</td>
      <td>0.049</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>0.345</td>
      <td>0.359</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>0.068</td>
      <td>0.052</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>0.328</td>
      <td>0.321</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>0.066</td>
      <td>0.050</td>
    </tr>
    <tr>
      <th rowspan="3" valign="top">opinion</th>
      <th>active</th>
      <td>0.220</td>
      <td>0.218</td>
      <td>0.001</td>
      <td>0.000</td>
      <td>0.044</td>
      <td>0.032</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>0.207</td>
      <td>0.198</td>
      <td>0.000</td>
      <td>0.000</td>
      <td>0.041</td>
      <td>0.031</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>0.226</td>
      <td>0.228</td>
      <td>0.001</td>
      <td>0.000</td>
      <td>0.044</td>
      <td>0.035</td>
    </tr>
  </tbody>
</table>
</div>



- Claim videos show higher per-view engagement rates than opinion videos.  
- Within claims, banned authors’ videos have slightly higher rates than others.  
- Within opinions, active/under-review authors outperform banned authors.  


```python
# Sanity check: ensure no NaN/inf values remain in per-view ratios
bad = df[['likes_per_view','comments_per_view','shares_per_view']].replace([np.inf,-np.inf], np.nan)
assert bad.isna().sum().sum() == 0, "Found NaN/inf in per-view ratios"
print("Per-view ratios look clean ✅")
```

    Per-view ratios look clean ✅



```python
# Per-view engagement ratios with counts (sample size context)
df.groupby(['claim_status', 'author_ban_status']).agg({
    'likes_per_view': ['count', 'mean', 'median'],
    'comments_per_view': ['count', 'mean', 'median'],
    'shares_per_view': ['count', 'mean', 'median']
})
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th colspan="3" halign="left">likes_per_view</th>
      <th colspan="3" halign="left">comments_per_view</th>
      <th colspan="3" halign="left">shares_per_view</th>
    </tr>
    <tr>
      <th></th>
      <th></th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
      <th>count</th>
      <th>mean</th>
      <th>median</th>
    </tr>
    <tr>
      <th>claim_status</th>
      <th>author_ban_status</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="3" valign="top">claim</th>
      <th>active</th>
      <td>6566</td>
      <td>0.330</td>
      <td>0.327</td>
      <td>6566</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>6566</td>
      <td>0.065</td>
      <td>0.049</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>1439</td>
      <td>0.345</td>
      <td>0.359</td>
      <td>1439</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>1439</td>
      <td>0.068</td>
      <td>0.052</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>1603</td>
      <td>0.328</td>
      <td>0.321</td>
      <td>1603</td>
      <td>0.001</td>
      <td>0.001</td>
      <td>1603</td>
      <td>0.066</td>
      <td>0.050</td>
    </tr>
    <tr>
      <th rowspan="3" valign="top">opinion</th>
      <th>active</th>
      <td>8817</td>
      <td>0.220</td>
      <td>0.218</td>
      <td>8817</td>
      <td>0.001</td>
      <td>0.000</td>
      <td>8817</td>
      <td>0.044</td>
      <td>0.032</td>
    </tr>
    <tr>
      <th>banned</th>
      <td>196</td>
      <td>0.207</td>
      <td>0.198</td>
      <td>196</td>
      <td>0.000</td>
      <td>0.000</td>
      <td>196</td>
      <td>0.041</td>
      <td>0.031</td>
    </tr>
    <tr>
      <th>under review</th>
      <td>463</td>
      <td>0.226</td>
      <td>0.228</td>
      <td>463</td>
      <td>0.001</td>
      <td>0.000</td>
      <td>463</td>
      <td>0.044</td>
      <td>0.035</td>
    </tr>
  </tbody>
</table>
</div>



- Adding counts confirms robust sample sizes for both claims and opinions.  
- Results validate earlier findings: claim status drives engagement more than ban status.  
- Again, right-skew is visible (mean > median).

## Section 2 Summary: Exploratory Analysis

- **Label balance:** The dataset is reasonably balanced between claims and opinions, making it suitable for supervised modeling.  
- **Claim dynamics:** Claim videos generally attract higher view counts and engagement than opinion videos.  
- **Author ban patterns:** Banned or under-review authors account for disproportionately higher engagement, though this reflects correlation only and causality cannot be inferred from the dataset.  
- **Engagement distributions:** Across groups, means are consistently greater than medians, confirming right-skewed, long-tailed distributions.  
- **Shares:** Median share counts are substantially higher for banned authors, suggesting virality dynamics that warrant closer review.  
- **Normalized engagement:** Per-view rates (e.g., likes per view, comments per view, shares per view) highlight claim status as the stronger predictor of engagement compared to ban status.  
- **Sample size context:** Including counts confirms that observed trends are based on robust subsets of the data, not artifacts of small groups.  

**Overall:** Claim content and author ban status both correlate with higher engagement, though claim status appears to drive engagement more strongly. These findings will inform subsequent feature engineering and model development.  
