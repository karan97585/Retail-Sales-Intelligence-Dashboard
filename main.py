import time
import logging

from database import get_engine
from config import DATASETS
from extract import process_dataset
from load import load_to_postgres
from verify import verify_data
from logger import write_log

def main():
    """Run the ETL pipeline and return a process exit code."""
    start_time = time.perf_counter()
    datasets_processed = 0
    status = "SUCCESS"
    engine = None

    try:
        write_log("ETL Pipeline Started")
        engine = get_engine()

        # PostgreSQL supports transactional DDL. Loading all datasets in one
        # transaction prevents a half-loaded pipeline if any step fails.
        with engine.begin() as connection:
            print("[OK] PostgreSQL connected successfully!")
            for file_name, dataset_name in DATASETS:
                print(f"\n[INFO] Processing: {dataset_name}")
                df = process_dataset(file_name, dataset_name)
                load_to_postgres(df, dataset_name, connection)
                verify_data(df, dataset_name, connection)
                write_log(f"{dataset_name} loaded and verified successfully")
                print(f"[OK] Finished: {dataset_name}")
                datasets_processed += 1

    except Exception as exc:
        status = "FAILED"
        logging.exception("ETL pipeline failed")
        print(f"[ERROR] ETL pipeline failed: {exc}")
        return 1

    finally:
        total_time = time.perf_counter() - start_time
        print("\n" + "=" * 50)
        print(f"ETL PIPELINE {status}")
        print("=" * 50)
        print(f"Datasets Processed : {datasets_processed}")
        print(f"Status             : {status}")
        print(f"Total Time         : {total_time:.2f} seconds")
        print("=" * 50)
        write_log(f"ETL Pipeline {status} in {total_time:.2f} seconds")
        if engine is not None:
            engine.dispose()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
