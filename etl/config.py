"""
ETL configuration file.
"""

import os
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "postgres"),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "port": os.getenv("POSTGRES_PORT", 5432),
}

CSV_PATHS = {
    "services": os.getenv("GENDO_CSV_SERVICES_PATH", "/data/gendo/services"),
    "gendo_304": os.getenv("GENDO_CSV_304_PATH", "/data/gendo/report-304"),
}

DW_SCHEMA = "dw"
RAW_SCHEMA = "raw"
