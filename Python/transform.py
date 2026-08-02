import pandas as pd


def clean_dataframe(df):
    """Normalize column names while preserving every source row."""
    cleaned_columns = df.columns.str.strip()
    if cleaned_columns.duplicated().any():
        duplicates = cleaned_columns[cleaned_columns.duplicated()].tolist()
        raise ValueError(f"Duplicate column names after trimming: {duplicates}")
    df.columns = cleaned_columns
    return df


def convert_data_types(df):
    """Convert date and timestamp columns, rejecting malformed non-null data."""
    for column in df.columns:
        if "date" in column.lower() or "timestamp" in column.lower():
            converted = pd.to_datetime(df[column], errors="coerce")
            invalid_values = int((df[column].notna() & converted.isna()).sum())
            if invalid_values:
                raise ValueError(
                    f"{column} contains {invalid_values} invalid date/timestamp values."
                )
            df[column] = converted

    return df
