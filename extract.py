import pandas as pd

from config import DATA_DIR
from transform import clean_dataframe, convert_data_types


def load_csv(file_name):
    """
    Load any CSV file from the data folder.
    """

    file_path = DATA_DIR / file_name
    if not file_path.is_file():
        raise FileNotFoundError(f"Dataset file not found: {file_path}")
    return pd.read_csv(file_path)


def validate_dataframe(df, dataset_name):
    """Print a compact data-quality summary without changing source records."""
    missing_values = int(df.isna().sum().sum())
    print(
        f"[INFO] {dataset_name}: {len(df):,} rows, {len(df.columns)} columns, "
        f"{missing_values:,} missing values"
    )


def process_dataset(file_name, dataset_name):
    """Read, normalize, type-convert, and validate one configured dataset."""
    df = load_csv(file_name)
    df = clean_dataframe(df)
    df = convert_data_types(df)
    validate_dataframe(df, dataset_name)

    return df
