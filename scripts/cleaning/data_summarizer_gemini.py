import pandas as pd
import numpy as np
import sys
from collections import defaultdict

def holistic_data_check(file_path, schema):
    """
    Performs a holistic check on a CSV file, including both corruption detection
    and basic data inventory for EDA.

    Args:
        file_path (str): The path to the CSV file to be checked.
        schema (dict): A dictionary mapping column names to expected data types.
                       Example: {'ID': 'int', 'Name': 'str', 'Age': 'int', 'Salary': 'float'}
                       Use 'str' for text, 'int' for integers, 'float' for decimals.
    """
    print(f"--- Starting Holistic Data Check for '{file_path}' ---")

    # Dictionary to store all detected issues
    issues = defaultdict(list)
    
    # --- 1. File and Structural Integrity Check ---
    try:
        # Read the CSV file into a pandas DataFrame.
        df = pd.read_csv(file_path, dtype=str)
    except FileNotFoundError:
        issues['File Error'].append(f"File not found at: {file_path}")
        print("\n--- Check Complete ---")
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)
    except pd.errors.ParserError as e:
        issues['Parsing Error'].append(f"Could not parse the CSV file. Details: {e}")
        print("\n--- Check Complete ---")
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)
    except Exception as e:
        issues['General Error'].append(f"An unexpected error occurred while reading the file: {e}")
        print("\n--- Check Complete ---")
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)

    # --- 2. Basic Inventory and High-Level Info ---
    print("\n--- Basic Data Inventory ---")
    print(f"Total Rows: {len(df)}")
    print(f"Total Columns: {len(df.columns)}")
    print("\nColumn Information (non-null counts and data types):")
    df.info(verbose=True, show_counts=True)
    
    # Check for column schema mismatch
    expected_cols = set(schema.keys())
    actual_cols = set(df.columns)
    
    if expected_cols != actual_cols:
        missing_cols = list(expected_cols - actual_cols)
        extra_cols = list(actual_cols - expected_cols)
        if missing_cols:
            issues['Schema Mismatch'].append(f"Missing columns: {missing_cols}")
        if extra_cols:
            issues['Schema Mismatch'].append(f"Extra columns: {extra_cols}")

    # --- 3. Detailed Corruption Checks and Statistics ---
    print("\n--- Detailed Column Analysis and Corruption Report ---")
    for col_name, expected_type in schema.items():
        if col_name not in df.columns:
            continue

        series = df[col_name]
        
        # Missing/Null values check
        null_count = series.isnull().sum()
        if null_count > 0:
            issues['Missing Values'].append(f"Column '{col_name}': {null_count} ({null_count/len(df):.2%}) missing values.")

        # Data type and value checks
        if expected_type in ['int', 'float']:
            # Attempt to convert the column to the numeric type
            numeric_series = pd.to_numeric(series, errors='coerce')
            
            # Count how many values failed to convert (excluding original nulls)
            corrupted_values_count = numeric_series.isnull().sum() - null_count
            if corrupted_values_count > 0:
                issues['Data Type Corruption'].append(f"Column '{col_name}': {corrupted_values_count} non-numeric values.")
            
            # Print basic stats for numeric columns if they are not all corrupted
            clean_series = numeric_series.dropna()
            if len(clean_series) > 0:
                print(f"\nStats for '{col_name}':")
                print(f"  - Count: {len(clean_series)}")
                print(f"  - Mean: {clean_series.mean():.2f}")
                print(f"  - Min: {clean_series.min():.2f}")
                print(f"  - Max: {clean_series.max():.2f}")
                print(f"  - Std Dev: {clean_series.std():.2f}")
                
                # Outlier check using z-score
                z_scores = np.abs((clean_series - clean_series.mean()) / clean_series.std())
                outlier_count = (z_scores > 3).sum()
                if outlier_count > 0:
                    issues['Statistical Outliers'].append(f"Column '{col_name}': {outlier_count} values identified as statistical outliers.")

        elif expected_type == 'str':
            # Check for consistent capitalization (common form of corruption)
            unique_values = series.dropna().unique()
            lower_case_unique = np.char.lower(unique_values)
            if len(set(lower_case_unique)) != len(unique_values):
                issues['Inconsistent Categorical Data'].append(f"Column '{col_name}': Found inconsistencies in case (e.g., 'USA' vs 'usa').")
            
            # Print unique values and their counts (inventory for categorical data)
            if len(unique_values) < 20: # Limit for readability
                print(f"\nUnique Values for '{col_name}':")
                value_counts = series.value_counts(dropna=False)
                print(value_counts)
            else:
                print(f"\nColumn '{col_name}' has {len(unique_values)} unique values.")
    
    # --- 4. Final Summary Report ---
    print("\n--- Final Summary of Corruption and EDA Insights ---")
    if not issues:
        print("✔ No major issues were found based on the provided schema. The dataset appears to be healthy.")
    else:
        print("✗ Issues were found. See details below:")
        for issue_type, issue_list in issues.items():
            print(f"\n[{issue_type}]")
            for issue in issue_list:
                print(f"  - {issue}")
    
    print("\n--- Check Complete ---")

if __name__ == '__main__':
    # --- Example Usage with a realistic dataset and corruption ---
    test_csv_data = """
    order_id,product_name,price,quantity,order_date,status
    101,Laptop,1200.50,1,2023-01-15,Shipped
    102,Mouse,25.00,2,2023-01-16,Pending
    103,Keyboard,75,3,2023-01-17,Shipped
    104,Monitor,400.00,a,2023-01-18,Shipped
    105,GPU,1500000.00,1,2023-01-19,Shipped
    106,Speaker,45.50,,2023-01-20,Shipped
    107,Headphones,80,2,2023-01-21,shipped
    108,Camera,120,4,2023-01-22,Shipped
    109,Webcam,abc,2,2023-01-23,Shipped
    110,Router,120.00,5,2023-01-24,
    111,Printer,250,5,2023-01-25,""" # An extra blank row for testing

    with open('test_data_enhanced.csv', 'w') as f:
        f.write(test_csv_data.strip())
    
    my_schema = {
        'order_id': 'int',
        'product_name': 'str',
        'price': 'float',
        'quantity': 'int',
        'order_date': 'str',
        'status': 'str'
    }

    holistic_data_check('test_data_enhanced.csv', my_schema)
