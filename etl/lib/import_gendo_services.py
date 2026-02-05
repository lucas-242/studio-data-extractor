import csv
import psycopg2
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import DB_CONFIG, CSV_PATHS, DW_SCHEMA

def parse_decimal(value):
    if not value or value == '0': return 0.0
    clean_val = value.replace('R$', '').replace('.', '').replace(',', '.').strip()
    try:
        return float(clean_val)
    except ValueError:
        return 0.0

def parse_duration(value):
    if not value: return None
    res = value.lower().replace('h', ' hours ').replace('min', ' minutes ')
    return res.strip()

def import_services_and_commissions(file_path, cur):
    with open(file_path, mode='r', encoding='latin-1') as csvFile:
        reader = csv.DictReader(csvFile, delimiter=';')
        
        reader.fieldnames = [name.strip().replace('"', '') for name in reader.fieldnames]
        
        for row in reader:
            service_name = row['Nome'].strip().upper()
            base_price = parse_decimal(row['Preço'])
            avg_cost = parse_decimal(row['Custo'])
            duration = parse_duration(row['Tempo'])
            category = row['Categoria'].strip().upper()
            commission_pct = parse_decimal(row['Comissão'])

            # 1. Upsert services
            cur.execute(f"""
                INSERT INTO {DW_SCHEMA}.dim_services (
                    service_name, base_category, base_price, avg_cost, duration, 
                    default_commission_percentage, is_active
                ) VALUES (%s, %s, %s, %s, %s, %s, TRUE)
                ON CONFLICT (service_name) 
                DO UPDATE SET 
                    service_name = EXCLUDED.service_name, 
                    base_category = EXCLUDED.base_category,
                    base_price = EXCLUDED.base_price,
                    avg_cost = EXCLUDED.avg_cost,
                    duration = EXCLUDED.duration,
                    default_commission_percentage = EXCLUDED.default_commission_percentage
                RETURNING service_id;
            """, (service_name, category, base_price, avg_cost, duration, commission_pct))
            
            result = cur.fetchone()
            if result:
                service_id = result[0]
            else:
                print(f"⚠️ Warning: It was not possible to get ID for service {service_name}")
                continue

            # 2. if comission is greater than 0, apply to all professionals
            if commission_pct > 0:
                cur.execute(f"""
                    INSERT INTO {DW_SCHEMA}.dim_commission_rules (professional_id, service_id, commission_percentage)
                    SELECT professional_id, %s, %s
                    FROM {DW_SCHEMA}.dim_professionals
                    ON CONFLICT (professional_id, service_id) 
                    DO UPDATE SET commission_percentage = EXCLUDED.commission_percentage;
                """, (service_id, commission_pct))

def main():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    try:
        csv_files = list(Path(CSV_PATHS["services"]).rglob("*.csv"))
        print(f"Gendo Services files found: {len(csv_files)}")

        for file_path in csv_files:
            print(f"Processing {file_path}")
            import_services_and_commissions(file_path, cur)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error to import services: {e}")
    finally:
        conn.commit()
        cur.close()
        conn.close()
        print("Services import completed.")

if __name__ == "__main__":
    main()
