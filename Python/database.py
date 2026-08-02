from sqlalchemy import URL, create_engine
from config import get_db_config


def get_engine():
    """
    Create and return PostgreSQL database engine.
    """

    config = get_db_config()
    connection_url = URL.create(
        "postgresql+psycopg2",
        username=config["user"],
        password=config["password"],
        host=config["host"],
        port=config["port"],
        database=config["database"],
    )
    return create_engine(connection_url, pool_pre_ping=True)
