# TikTok Claims — EDA Part 2: Visualizations & Outliers

**Owner:** Katherine Ygbuhay  
**Updated:** September 29, 2025  
**Stage:** 03

**Goal:** Profile distributions, compare groups, and quantify outliers to inform downstream feature engineering and modeling.

**Contents:**  
- Distribution profiles (histograms & boxplots: duration, views, likes, comments, shares, downloads)  
- Group comparisons by `claim_status`, `verified_status`, and `author_ban_status` (count histograms)  
- Engagement relationships (views vs. likes scatterplots: overall & opinions-only)  
- Outlier quantification per count variable using **median + 1.5×IQR**  
- Total-views composition by claim status (pie + log-scale bar)  
- Section wrap-up & next-step implications

### Imports and Data Loading


```python
# Core libraries for data manipulation
import pandas as pd
import numpy as np

# Visualization libraries
import matplotlib.pyplot as plt
import seaborn as sns

# Display settings for improved readability
pd.options.display.float_format = '{:.3f}'.format
pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", 100)
```


```python
# Seaborn theme + accessibility defaults
# - "whitegrid" improves readability
# - "colorblind" is the Okabe–Ito palette (CB-friendly)
sns.set_theme(style="whitegrid", palette="colorblind")

# Consistent figure sizing & typography
import matplotlib as mpl
mpl.rcParams["figure.figsize"] = (7, 5)    # default for most plots
mpl.rcParams["axes.titlesize"] = 14
mpl.rcParams["axes.labelsize"] = 12
mpl.rcParams["legend.title_fontsize"] = 11
mpl.rcParams["legend.fontsize"] = 10

# Category palette maps (use everywhere for consistent colors)
claim_palette = {"claim": "#0072B2", "opinion": "#E69F00"}                 # blue / orange
verified_palette = {"verified": "#009E73", "not verified": "#0072B2"}      # green / blue
ban_palette = {"active": "#0072B2", "under review": "#E69F00", "banned": "#D55E00"}  # blue / orange / vermillion
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


```python
# Display the first few records
df.head()
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




```python
# Dimensions of the dataset
df.shape
```




    (19382, 12)




```python
# Total number of elements (rows × columns)
df.size
```




    232584




```python
# Data types, non-null counts, and memory usage
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 19382 entries, 0 to 19381
    Data columns (total 12 columns):
     #   Column                    Non-Null Count  Dtype  
    ---  ------                    --------------  -----  
     0   #                         19382 non-null  int64  
     1   claim_status              19084 non-null  object 
     2   video_id                  19382 non-null  int64  
     3   video_duration_sec        19382 non-null  int64  
     4   video_transcription_text  19084 non-null  object 
     5   verified_status           19382 non-null  object 
     6   author_ban_status         19382 non-null  object 
     7   video_view_count          19084 non-null  float64
     8   video_like_count          19084 non-null  float64
     9   video_share_count         19084 non-null  float64
     10  video_download_count      19084 non-null  float64
     11  video_comment_count       19084 non-null  float64
    dtypes: float64(5), int64(3), object(4)
    memory usage: 1.8+ MB



```python
# Extended DataFrame summary with missing value counts and percentages
def df_info_plus(df):
    """
    Extended DataFrame info:
    - Column name and dtype
    - Non-null and missing counts
    - % missing values
    """
    info = []
    for col in df.columns:
        non_null = df[col].notnull().sum()
        nulls = df.shape[0] - non_null
        pct_missing = (nulls / df.shape[0]) * 100
        dtype = df[col].dtype
        info.append([col, dtype, non_null, nulls, f"{pct_missing:.2f}%"])
    
    return pd.DataFrame(
        info,
        columns=["Column", "Dtype", "Non-Null Count", "Missing Count", "% Missing"]
    )

# Display extended info table
df_info_plus(df)
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




```python
# Descriptive statistics for numeric features
df.describe()
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
      <th>#</th>
      <th>video_id</th>
      <th>video_duration_sec</th>
      <th>video_view_count</th>
      <th>video_like_count</th>
      <th>video_share_count</th>
      <th>video_download_count</th>
      <th>video_comment_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>19382.000</td>
      <td>19382.000</td>
      <td>19382.000</td>
      <td>19084.000</td>
      <td>19084.000</td>
      <td>19084.000</td>
      <td>19084.000</td>
      <td>19084.000</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>9691.500</td>
      <td>5627454067.339</td>
      <td>32.422</td>
      <td>254708.559</td>
      <td>84304.636</td>
      <td>16735.248</td>
      <td>1049.430</td>
      <td>349.312</td>
    </tr>
    <tr>
      <th>std</th>
      <td>5595.246</td>
      <td>2536440464.169</td>
      <td>16.230</td>
      <td>322893.281</td>
      <td>133420.547</td>
      <td>32036.174</td>
      <td>2004.300</td>
      <td>799.639</td>
    </tr>
    <tr>
      <th>min</th>
      <td>1.000</td>
      <td>1234959018.000</td>
      <td>5.000</td>
      <td>20.000</td>
      <td>0.000</td>
      <td>0.000</td>
      <td>0.000</td>
      <td>0.000</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>4846.250</td>
      <td>3430416807.250</td>
      <td>18.000</td>
      <td>4942.500</td>
      <td>810.750</td>
      <td>115.000</td>
      <td>7.000</td>
      <td>1.000</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>9691.500</td>
      <td>5618663579.000</td>
      <td>32.000</td>
      <td>9954.500</td>
      <td>3403.500</td>
      <td>717.000</td>
      <td>46.000</td>
      <td>9.000</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>14536.750</td>
      <td>7843960211.250</td>
      <td>47.000</td>
      <td>504327.000</td>
      <td>125020.000</td>
      <td>18222.000</td>
      <td>1156.250</td>
      <td>292.000</td>
    </tr>
    <tr>
      <th>max</th>
      <td>19382.000</td>
      <td>9999873075.000</td>
      <td>60.000</td>
      <td>999817.000</td>
      <td>657830.000</td>
      <td>256130.000</td>
      <td>14994.000</td>
      <td>9599.000</td>
    </tr>
  </tbody>
</table>
</div>



### Exploratory Visualizations

Visualize distributions of engagement variables and examine relationships across claim status, verification, and author ban status. These plots help identify skewness, outliers, and group-level differences that may inform feature engineering.


```python
# Boxplot of video duration (seconds)
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_duration_sec'])
plt.title('Video Duration Boxplot')
plt.show()
```


    
![png](output_13_0.png)
    



```python
# Histogram of video duration (seconds)
plt.figure(figsize=(5, 3))
sns.histplot(df['video_duration_sec'], bins=range(0, 61, 5))
plt.title('Video Duration Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_14_0.png)
    


- **Observation — video duration:** Most videos cluster at shorter durations with a long right tail, indicating fewer long-form videos.


```python
# Boxplot of video view count
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_view_count'])
plt.title('Video View Count Boxplot')
plt.show()
```


    
![png](output_16_0.png)
    



```python
# Histogram of video view count
plt.figure(figsize=(5, 3))
sns.histplot(df['video_view_count'], bins=range(0, (10**6 + 1), 10**5))
plt.title('Video View Count Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_17_0.png)
    


- **Observation — view count:** More than half of videos receive under 100K views; the distribution is heavily right-skewed with a small subset of high-view outliers.


```python
# Boxplot of video like count
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_like_count'])
plt.title('Video Like Count Boxplot')
plt.show()
```


    
![png](output_19_0.png)
    



```python
# Histogram of video like count
plt.figure(figsize=(5, 3))
ax = sns.histplot(df['video_like_count'], bins=range(0, 7*10**5 + 1, 10**5))
ax.set_xticks(range(0, 7*10**5 + 1, 10**5))
ax.set_xticklabels([0] + [f'{i}k' for i in range(100, 701, 100)])
plt.title('Video Like Count Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_20_0.png)
    


- **Observation — like count:** The majority of videos have <100K likes; distribution tapers with a long right tail, reflecting a small set of highly liked videos.


```python
# Boxplot of video comment count
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_comment_count'])
plt.title('Video Comment Count Boxplot')
plt.show()
```


    
![png](output_22_0.png)
    



```python
# Histogram of video comment count
plt.figure(figsize=(5, 3))
sns.histplot(df['video_comment_count'], bins=range(0, 3001, 100))
plt.title('Video Comment Count Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_23_0.png)
    


- **Observation — comment count:** Most videos have fewer than 100 comments; the distribution is highly right-skewed with sparse high-comment outliers.


```python
# Boxplot of video share count
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_share_count'])
plt.title('Video Share Count Boxplot')
plt.show()
```


    
![png](output_25_0.png)
    



```python
# Histogram of video share count
plt.figure(figsize=(5, 3))
sns.histplot(df['video_share_count'], bins=range(0, 270001, 10000))
plt.title('Video Share Count Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_26_0.png)
    


- **Observation — share count:** The overwhelming majority of videos have fewer than 10,000 shares; the distribution is strongly right-skewed.


```python
# Boxplot of video download count
plt.figure(figsize=(6, 2))
sns.boxplot(x=df['video_download_count'])
plt.title('Video Download Count Boxplot')
plt.show()
```


    
![png](output_28_0.png)
    



```python
# Histogram of video download count
plt.figure(figsize=(5, 3))
sns.histplot(df['video_download_count'], bins=range(0, 15001, 500))
plt.title('Video Download Count Histogram')
plt.tight_layout()
plt.show()
```


    
![png](output_29_0.png)
    


- **Observation — download count:** Most videos are downloaded fewer than 500 times, with a long tail extending beyond 12,000 downloads.


```python
# Claims by verification status (count histogram)
plt.figure(figsize=(7, 5))
sns.histplot(
    data=df,
    x="claim_status",
    hue="verified_status",
    multiple="dodge",
    shrink=0.9,
    palette=verified_palette
)
plt.title("Claim Status by Verification Status — Counts")
plt.tight_layout()
plt.show()
```


    
![png](output_31_0.png)
    


- **Observation — verification:** Verified users are fewer overall; conditional on verification, opinion posts appear relatively more common than claims.


```python
# Claim status by author ban status (count histogram)
plt.figure(figsize=(7, 5))
sns.histplot(
    data=df,
    x="claim_status",
    hue="author_ban_status",
    multiple="dodge",
    hue_order=["active", "under review", "banned"],
    shrink=0.9,
    palette=ban_palette,
    alpha=0.6
)
plt.title("Claim Status by Author Ban Status — Counts")
plt.tight_layout()
plt.show()
```


    
![png](output_33_0.png)
    


- **Observation — moderation state:** Active authors dominate overall counts; however, claims are relatively more prevalent among under-review/banned authors than among active authors.


```python
# Median view count by author ban status (bar plot)
ban_status_medians = (
    df.groupby("author_ban_status")
      .median(numeric_only=True)
      .reset_index()
)

plt.figure(figsize=(7, 5))
sns.barplot(
    data=ban_status_medians,
    x="author_ban_status",
    y="video_view_count",
    hue="author_ban_status",          # fixes Seaborn ≥0.14 palette warning
    legend=False,
    order=["active", "under review", "banned"],
    palette=ban_palette,
    alpha=0.8
)
plt.title("Median View Count by Author Ban Status")
plt.xlabel("Author ban status")
plt.ylabel("Median view count")
plt.tight_layout()
plt.show()
```


    
![png](output_35_0.png)
    


- **Observation — median views by moderation state:** Median views for under-review/banned authors exceed those for active authors, suggesting distinct exposure/virality dynamics.


```python
# Median view count by claim status (table output)
df.groupby('claim_status')['video_view_count'].median()
```




    claim_status
    claim     501555.000
    opinion     4953.000
    Name: video_view_count, dtype: float64



- **Observation — median views by claim status:** Median view counts are higher for claim videos than for opinion videos, reinforcing the earlier engagement trend.


```python
import matplotlib.pyplot as plt

# Sum total views by claim status
totals = (
    df.groupby("claim_status")["video_view_count"]
      .sum(min_count=1)
      .reindex(["claim", "opinion"])
      .fillna(0.0)
      .astype(float)
)

# Calculate the opinion percentage for annotation
opinion_pct = totals.loc["opinion"] / totals.sum() * 100

fig, ax = plt.subplots(figsize=(5, 5))
wedges, texts, autotexts = ax.pie(
    totals.values,
    labels=totals.index,
    autopct='%1.1f%%',
    startangle=90,
    colors=['#0072B2', '#E69F00'],
    labeldistance=1.1,
    pctdistance=0.75
)

# Style percentage labels
for t in autotexts:
    t.set_fontsize(12)
    t.set_color("white")
    t.set_weight("bold")

# Remove the cramped % for the opinion wedge
autotexts[1].set_text("")

# Add your clean inside annotation line back
ax.annotate(
    f"{opinion_pct:.1f}%",
    xy=(0.03, 0.9),        # where the line points
    xytext=(0.4, 0.7),     # where the label sits
    textcoords='axes fraction',
    arrowprops=dict(arrowstyle="-", color="white", lw=1.5),
    ha='center', va='center', fontsize=12, weight='bold', color='white'
)

ax.set_title("Total Views by Claim Status", pad=20)
ax.axis('equal')
plt.tight_layout()
plt.show()
```


    
![png](output_39_0.png)
    



```python
# Total views by claim status (log scale, color-blind friendly)
totals = (
    df.groupby("claim_status")["video_view_count"]
      .sum()
      .sort_values(ascending=False)
)

plt.figure(figsize=(7, 5))
sns.barplot(
    x=totals.index,
    y=totals.values,
    hue=totals.index,      # silences palette warning
    legend=False,
    palette=[claim_palette[c] for c in totals.index]
)
plt.title("Total Views by Claim Status (Log Scale)")
plt.ylabel("Total views (log scale)")
plt.yscale("log")
plt.tight_layout()
plt.show()
```


    
![png](output_40_0.png)
    


- **Observation — total views share:** Despite similar class counts, claim videos account for the overwhelming majority of total views. Both the pie chart and bar chart confirm this imbalance.

### Outlier Detection

Outliers are defined as values exceeding:  
**Threshold = median + 1.5 × IQR**  
for each count variable. This provides a skew-robust measure of unusually high engagement values.


```python
# Count variables to check for outliers
count_cols = [
    'video_view_count',
    'video_like_count',
    'video_share_count',
    'video_download_count',
    'video_comment_count'
]

# Calculate outlier counts per variable
for column in count_cols:
    q1, q3 = df[column].quantile([0.25, 0.75])
    iqr = q3 - q1
    median = df[column].median()
    threshold = median + 1.5 * iqr
    out_count = (df[column] > threshold).sum()
    pct = 100 * out_count / len(df)
    print(f"Outliers in {column}: {out_count} ({pct:.1f}%)  [threshold={threshold:,.0f}]")
```

    Outliers in video_view_count: 2343 (12.1%)  [threshold=759,031]
    Outliers in video_like_count: 3468 (17.9%)  [threshold=189,717]
    Outliers in video_share_count: 3732 (19.3%)  [threshold=27,878]
    Outliers in video_download_count: 3733 (19.3%)  [threshold=1,770]
    Outliers in video_comment_count: 3882 (20.0%)  [threshold=446]



```python
# Views vs. Likes by Claim Status
plt.figure(figsize=(7, 5))
sns.scatterplot(
    data=df,
    x="video_view_count",
    y="video_like_count",
    hue="claim_status",
    style="claim_status",
    markers={"claim": "o", "opinion": "s"},
    palette=claim_palette,
    s=10, alpha=0.35, edgecolor="none"
)
plt.title("Views vs. Likes by Claim Status")
plt.tight_layout()
plt.show()
```


    
![png](output_44_0.png)
    



```python
# Views vs. Likes (Opinions Only)
opinion = df[df["claim_status"] == "opinion"]

plt.figure(figsize=(7, 5))
sns.scatterplot(
    data=opinion,
    x="video_view_count",
    y="video_like_count",
    color=claim_palette["opinion"],
    s=10, alpha=0.35, edgecolor="none"
)
plt.title("Views vs. Likes (Opinions Only)")
plt.tight_layout()
plt.show()
```


    
![png](output_45_0.png)
    


### Conclusion

This exploratory analysis established a detailed understanding of the TikTok dataset. Key steps included reviewing variable distributions, quantifying missing values, detecting outliers, and examining relationships across claim status, verification, and author ban status. Several consistent patterns emerged:

- **Balanced labels:** Claims and opinions are present in nearly equal proportions, supporting supervised modeling.  
- **Engagement skew:** All engagement variables are heavily right-skewed, with a small number of viral videos driving much of the variance.  
- **Claim dynamics:** Claim videos receive higher views, likes, and shares than opinion videos.  
- **Moderation effects:** Authors flagged as banned or under review tend to generate higher engagement, though this correlation does not imply causality.  
- **Outliers:** Viral outliers are a natural feature of social media data; they will need to be considered explicitly during feature engineering and modeling.

Visualizations created in this notebook, and extended in Tableau, provided complementary perspectives on these patterns and reinforced the same conclusions.

**Next steps:**  
- Engineer features that capture engagement patterns, author moderation status, and claim/opinion balance.  
- Address skewness and outliers (e.g., transformations or robust metrics).  
- Evaluate which variables provide the strongest predictive signal for claim status.  
