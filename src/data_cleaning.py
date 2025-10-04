"""
Data cleaning utilities for portfolio case studies.
"""

import pandas as pd

def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """Perform basic cleaning operations on a dataset.

    Operations:
        - Remove duplicate rows
        - Drop fully empty rows

    Args:
        df (pd.DataFrame): Input DataFrame containing raw data

    Returns:
        pd.DataFrame: Cleaned DataFrame with duplicates and empty rows removed
    """
    df = df.drop_duplicates()
    df = df.dropna(how="all")
    return df
