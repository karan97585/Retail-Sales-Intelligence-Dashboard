import re

from sqlalchemy import text


TABLE_NAME_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def verify_data(df, table_name, connection):
    """Verify that the loaded table contains exactly the expected row count."""
    if not TABLE_NAME_PATTERN.fullmatch(table_name):
        raise ValueError(f"Unsafe table name: {table_name!r}")

    csv_rows = len(df)
    db_rows = connection.execute(text(f'SELECT COUNT(*) FROM "{table_name}"')).scalar_one()

    if csv_rows == db_rows:
        print(f"[OK] Verification passed: {table_name} ({csv_rows} rows)")
    else:
        print(f"[ERROR] Verification failed: {table_name}")
        print(f"CSV : {csv_rows}")
        print(f"DB  : {db_rows}")
        raise RuntimeError(
            f"Verification failed for {table_name}: CSV has {csv_rows} rows, "
            f"database has {db_rows} rows."
        )
