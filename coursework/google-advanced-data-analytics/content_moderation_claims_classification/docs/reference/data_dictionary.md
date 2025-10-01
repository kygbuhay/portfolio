# TikTok Claims – Data Dictionary  

**File:** `data/tiktok_dataset.csv`  
**Rows:** 19,383 • **Columns:** 12  
**Use:** Sample dataset provided for analysis of claims vs. opinions classification.  

| Column             | Type     | Description                                                        | Example    |
|--------------------|----------|--------------------------------------------------------------------|------------|
| video_id           | int      | Unique identifier for each video                                   | 18273645   |
| claim_status       | category | Label: `claim` (verifiable assertion) or `opinion` (subjective)    | claim      |
| view_count         | int      | Number of video views                                              | 12450      |
| like_count         | int      | Number of likes                                                    | 523        |
| share_count        | int      | Number of shares                                                   | 31         |
| download_count     | int      | Number of downloads                                                | 7          |
| comment_count      | int      | Number of comments                                                 | 82         |
| video_duration_sec | float    | Video length (seconds)                                             | 27.4       |
| author_is_banned   | bool     | Whether the author account is banned (synthetic for coursework)    | False      |
| text_length        | int      | Length of caption text (characters)                               | 142        |
| is_verified        | bool     | Whether the author account is verified                            | True       |
| reported_count     | int      | Number of user reports                                             | 2          |

---

### Notes  
- Dataset is **educational/simulated** — not real TikTok data.  
- Variables are simplified to illustrate feature engineering and model training concepts.  
- Analysis focuses on **engagement-based signals** (views, likes, shares, etc.) vs. **account metadata** (verification, ban status).  

