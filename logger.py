import logging
from pathlib import Path


log_folder = Path(__file__).parent.parent / "logs"
log_folder.mkdir(exist_ok=True)

log_file = log_folder / "etl.log"


logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)


def write_log(message):

    logging.info(message)