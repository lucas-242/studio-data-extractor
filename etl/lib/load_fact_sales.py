import psycopg2
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import DB_CONFIG

def refresh_fact_sales(cur):
    print("🚀 Processing fact_sales...")
    
    upsert_query = f"""
    INSERT INTO dw.fact_sales (
        source_id, service_date, service_month, weekday_number, order_code,
        professional_id, professional_name, service_id, service_name, category,
        gross_revenue, commission_percent, commission_value, service_avg_cost,
        service_duration, contribution_margin, payment_method, client_name, 
        client_phone, unique_hash
    )
    SELECT
        s.unique_hash, 
        s.service_date,
        date_trunc('month', s.service_date)::date,
        EXTRACT(DOW FROM s.service_date),
        s.order_code,
        p.professional_id,
        s.professional_name,
        srv.service_id,
        s.service_name,
        srv.base_category,
        s.total_amount,
        
        -- Comission (Exception > Professional > Service > 0)
        COALESCE(exc.commission_percentage, p.fixed_commission_rate, srv.default_commission_percentage, 0) as cp,
        
        -- Commission Value
        (s.total_amount * (COALESCE(exc.commission_percentage, p.fixed_commission_rate, srv.default_commission_percentage, 0) / 100))::numeric(10,2),
        
        -- Interval to Integer
        COALESCE(srv.avg_cost, 0),
        srv.duration,
        
        -- Contribution Margin
        (s.total_amount 
         - (s.total_amount * (COALESCE(exc.commission_percentage, p.fixed_commission_rate, srv.default_commission_percentage, 0) / 100)) 
         - COALESCE(srv.avg_cost, 0))::numeric(10,2),
         
        s.payment_method,
        s.client_name,
        s.client_phone,
        s.unique_hash
    FROM staging.stg_gendo_services s
    LEFT JOIN dw.dim_professionals p ON s.professional_name = p.professional_name
    LEFT JOIN dw.dim_services srv ON s.service_name = srv.service_name
    LEFT JOIN dw.dim_commission_exceptions exc 
        ON p.professional_id = exc.professional_id 
        AND srv.service_id = exc.service_id
    ON CONFLICT (unique_hash) DO NOTHING;
    """
    cur.execute(upsert_query)

def main():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    try:
        refresh_fact_sales(cur)
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"❌ Error during fact sales refresh: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()