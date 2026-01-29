import csv
import hashlib
import os
import psycopg2
from dotenv import load_dotenv
from datetime import datetime
from pathlib import Path

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "postgres"),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "port": os.getenv("POSTGRES_PORT", 5432),
}

CSV_DIR = os.getenv("GENDO_CSV_304_PATH", "/data/gendo")

def generate_hash(row):
    raw = f"{row['Data']}|{row['Cód. Comanda']}|{row['Serviço']}|{row['Colaborador']}|{row['Cliente']}|{row['Total']}|{row['Forma Pagto']}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def parse_decimal(value):
    if not value:
        return None

    value = value.strip()
    
    return float(value)



def process_csv(file_path, cur):
    with open(file_path, newline="", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)

        for row in reader:
            unique_hash = generate_hash(row)

            cur.execute(
                """
                INSERT INTO raw.gendo_report_304 (
                    service_date,
                    order_code,
                    service_name,
                    category,
                    quantity,
                    unit_price,
                    total_amount,
                    balance,
                    professional_name,
                    client_name,
                    client_cpf,
                    client_email,
                    client_phone,
                    payment_method,
                    unique_hash
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
                ON CONFLICT (unique_hash) DO NOTHING
                """,
                (
                    datetime.strptime(row["Data"], "%d/%m/%Y").date(),
                    row["Cód. Comanda"],
                    row["Serviço"],
                    row["Categoria"],
                    int(row["Qts"]) if row["Qts"] else None,
                    parse_decimal(row["Preço Uni."]),
                    parse_decimal(row["Total"]),
                    parse_decimal(row["Saldo"]),
                    row["Colaborador"],
                    row["Cliente"],
                    row["CPF"],
                    row["Email"],
                    row["Telefone"],
                    row["Forma Pagto"],
                    unique_hash,
                ),
            )


def main():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    csv_files = list(Path(CSV_DIR).rglob("*.csv"))
    print(f"Arquivos encontrados: {len(csv_files)}")

    for file_path in csv_files:
        print(f"Processando {file_path}")
        process_csv(file_path, cur)

    conn.commit()
    cur.close()
    conn.close()

    print("Importação finalizada.")

if __name__ == "__main__":
    main()
