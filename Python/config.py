import os
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"


def load_dotenv(dotenv_path=PROJECT_ROOT / ".env"):
    path = Path(dotenv_path)
    if not path.exists():
        return False

    with path.open(encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = value
    return True


load_dotenv()

# PostgreSQL database configuration. Values are validated only when a database
# connection is requested, so modules can still be imported for local checks.
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT", "5432"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
}


def get_db_config():
    """Return validated PostgreSQL configuration when a database is needed."""
    env_names = {
        "host": "DB_HOST",
        "port": "DB_PORT",
        "database": "DB_NAME",
        "user": "DB_USER",
        "password": "DB_PASSWORD",
    }
    missing = [env_names[name] for name, value in DB_CONFIG.items() if not value]
    if missing:
        raise ValueError(
            "Missing database configuration: "
            + ", ".join(missing)
            + ". Add these values to .env (see .env.example)."
        )

    try:
        port = int(DB_CONFIG["port"])
    except ValueError as exc:
        raise ValueError("DB_PORT must be a valid integer.") from exc

    return {**DB_CONFIG, "port": port}

# (source filename, target table name)
DATASETS = [
    ("olist_customers_dataset.csv", "customers"),
    ("olist_orders_dataset.csv", "orders"),
    ("olist_products_dataset.csv", "products"),
    ("olist_order_items_dataset.csv", "order_items"),
    ("olist_order_payments_dataset.csv", "order_payments"),
    ("olist_order_reviews_dataset.csv", "order_reviews"),
    ("olist_sellers_dataset.csv", "sellers"),
    ("olist_geolocation_dataset.csv", "geolocation"),
    ("product_category_name_translation.csv", "category_translation")
]
