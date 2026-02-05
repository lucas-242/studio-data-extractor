-- This table is used to store manual expense entries
CREATE TABLE IF NOT EXISTS dw.fact_expenses (
    expense_id SERIAL PRIMARY KEY,
    expense_date DATE NOT NULL,
    description TEXT,
    category TEXT,
    expense_type TEXT CHECK (expense_type IN ('Fixo', 'Variável')),
    amount NUMERIC(10,2) NOT NULL
);

-- This view is used to analyze sales data from the staging table
CREATE OR REPLACE VIEW dw.fact_sales AS
SELECT
    s.source_id,
    s.service_date,
    date_trunc('month', s.service_date)::date AS service_month,
    EXTRACT(DOW FROM s.service_date) AS weekday_number,
    s.order_code,
    
    p.professional_id,
    s.professional_name,
    srv.service_id,
    s.service_name,
    srv.base_category AS category,
    
    s.total_amount AS gross_revenue,
    
    -- Commission (Hierarchical: Professional Rule > Service Default > Zero)
    COALESCE(com.commission_percentage, srv.default_commission_percentage, 0) AS commission_percent,
    
    (s.total_amount * (
        COALESCE(com.commission_percentage, srv.default_commission_percentage, 0) / 100
    ))::numeric(10,2) AS commission_value,
    
    COALESCE(srv.avg_cost, 0) AS service_avg_cost,
    srv.duration AS service_duration,
    
    -- Contribution Margin = Gross Revenue - Commission - Average Cost (What's left after paying for the service and commission)
    (s.total_amount 
     - (s.total_amount * (COALESCE(com.commission_percentage, srv.default_commission_percentage, 0) / 100)) 
     - COALESCE(srv.avg_cost, 0)
    )::numeric(10,2) AS contribution_margin,
    
    s.payment_method,
    s.client_name,
    s.client_phone
FROM staging.stg_gendo_services s
LEFT JOIN dw.dim_professionals p ON s.professional_name = p.full_name
LEFT JOIN dw.dim_services srv ON s.service_name = srv.service_name
LEFT JOIN dw.dim_commission_rules com ON p.professional_id = com.professional_id 
    AND srv.service_id = com.service_id;

