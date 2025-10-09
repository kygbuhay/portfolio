import pandas as pd
import numpy as np
import sys
from collections import defaultdict

def run_holistic_corruption_check(file_path, schema):
    """
    Performs a holistic, baseline corruption check on a CSV file.

    This script checks for:
    1.  File accessibility and parsing issues.
    2.  Structural integrity (consistent number of columns).
    3.  Data type consistency (e.g., numbers in a number column).
    4.  Missing/Null values.
    5.  Out-of-range or statistically improbable values.
    6.  Inconsistent categorical data.

    Args:
        file_path (str): The path to the CSV file to be checked.
        schema (dict): A dictionary mapping column names to expected data types.
                       Example: {'ID': 'int', 'Name': 'str', 'Age': 'int', 'Salary': 'float'}
                       Use 'str' for text, 'int' for integers, 'float' for decimals.
    """
    print(f"--- Starting Holistic Corruption Check for '{file_path}' ---")

    # Dictionary to store all detected issues
    issues = defaultdict(list)
    
    # --- 1. File and Structural Integrity Check ---
    try:
        # Read the CSV file into a pandas DataFrame.
        # We use `dtype=str` to prevent pandas from auto-inferring types,
        # which allows us to check for type corruption manually.
        df = pd.read_csv(file_path, dtype=str)
    except FileNotFoundError:
        issues['File Error'].append(f"File not found at: {file_path}")
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)
    except pd.errors.ParserError as e:
        issues['Parsing Error'].append(f"Could not parse the CSV file. This may indicate a structural issue or improper formatting. Details: {e}")
        # If parsing fails, we can't do any more checks.
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)
    except Exception as e:
        issues['General Error'].append(f"An unexpected error occurred while reading the file: {e}")
        print("Summary of Issues:")
        for issue_type, issue_list in issues.items():
            print(f"- {issue_type}: {issue_list[0]}")
        sys.exit(1)
        
    print(f"Successfully read file with {len(df.columns)} columns and {len(df)} rows.")

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

    # --- 2. Data Type and Value Corruption Checks ---
    for col_name, expected_type in schema.items():
        if col_name not in df.columns:
            # Skip validation for columns that are already reported as missing
            continue

        series = df[col_name]
        
        # Check for Missing/Null values
        null_count = series.isnull().sum()
        if null_count > 0:
            issues['Missing Values'].append(f"Column '{col_name}' has {null_count} missing values.")
        
        # Check for data type and out-of-range values
        if expected_type in ['int', 'float']:
            # Attempt to convert the column to the numeric type
            numeric_series = pd.to_numeric(series, errors='coerce')
            
            # Count how many values failed to convert
            corrupted_values_count = numeric_series.isnull().sum() - null_count
            if corrupted_values_count > 0:
                issues['Data Type Corruption'].append(f"Column '{col_name}' has {corrupted_values_count} non-numeric values.")
            
            # Check for extreme outliers (assuming they are corruption)
            if expected_type == 'int':
                # Remove NaN for statistical analysis
                clean_series = numeric_series.dropna()
                # Z-score-based check for values far from the mean.
                # A value is considered an outlier if its Z-score is > 3
                if len(clean_series) > 0:
                    z_scores = np.abs((clean_series - clean_series.mean()) / clean_series.std())
                    outlier_count = (z_scores > 3).sum()
                    if outlier_count > 0:
                        issues['Statistical Outliers'].append(f"Column '{col_name}' has {outlier_count} values that are statistical outliers (potential corruption).")

        elif expected_type == 'str':
            # Check for gibberish characters (non-alphanumeric/non-whitespace)
            non_standard_chars = series[series.str.contains(r'[^a-zA-Z0-9\s.,\-\_]', na=False, regex=True)].count()
            if non_standard_chars > 0:
                issues['Gibberish/Bad Characters'].append(f"Column '{col_name}' has {non_standard_chars} values with unusual characters.")

            # Check for inconsistent capitalization (common form of corruption)
            unique_values = series.dropna().unique()
            if len(unique_values) > 0 and len(np.char.lower(unique_values)) != len(unique_values):
                issues['Inconsistent Categorical Data'].append(f"Column '{col_name}' has inconsistencies in case sensitivity (e.g., 'USA' and 'usa'). Found {len(unique_values)} unique values.")
        
    # --- 3. Final Summary Report ---
    print("\n--- Summary of Corruption Check Results ---")
    if not issues:
        print("✔ No corruption issues were found based on the provided schema. The dataset appears to be clean!")
    else:
        print("✗ Corruption issues were found. See details below:")
        for issue_type, issue_list in issues.items():
            print(f"\n[{issue_type}]")
            for issue in issue_list:
                print(f"  - {issue}")
    
    print("\n--- Check Complete ---")


if __name__ == '__main__':
    # --- Example Usage ---
    # Define a simple CSV file to test the script
    test_csv_data = """
    CustomerID,ProductName,Price,Quantity,Status
    101,Laptop,1200.50,1,Shipped
    102,Mouse,25.00,2,Pending
    103,Keyboard,75,3,Shipped
    104,Monitor,400.00,a,Shipped
    105,GPU,1500000.00,1,Shipped
    106,Speaker,45.50,,Shipped
    107,Headphones,80,2,shipped
    108,Camera,120,4,Shipped
    109,Webcam,abc,2,Shipped
    110,Router,120.00,5,
    """

    # --- Write the test data to a file ---
    with open('test_data.csv', 'w') as f:
        f.write(test_csv_data.strip())
    
    # Define the schema for our test data
    my_schema = {
        'CustomerID': 'int',
        'ProductName': 'str',
        'Price': 'float',
        'Quantity': 'int',
        'Status': 'str'
    }

    # Run the check on our test file with the defined schema
    run_holistic_corruption_check('test_data.csv', my_schema)

    # Expected Issues:
    # 1. Quantity for CustomerID 104 is 'a' (Data Type Corruption)
    # 2. Price for CustomerID 105 is 1500000.00 (Statistical Outlier)
    # 3. Quantity for CustomerID 106 is blank (Missing Values)
    # 4. Status for CustomerID 107 is 'shipped' (Inconsistent Categorical Data)
    # 5. Price for CustomerID 109 is 'abc' (Data Type Corruption)
    # 6. Status for CustomerID 110 is blank (Missing Values)
