def load_to_postgres(df, table_name, connection):
    """Load a DataFrame using the caller's database transaction."""

    df.to_sql(
        name=table_name,
        con=connection,
        if_exists="replace",
        index=False,
        chunksize=10_000,
        method="multi",
    )

    print(f"[OK] {table_name} loaded successfully!")
