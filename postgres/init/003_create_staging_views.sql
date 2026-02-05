-- Create staging view (normalized data) for Gendo imported data
CREATE OR REPLACE VIEW staging.stg_gendo_services AS
SELECT
    id AS source_id,
    service_date,
    order_code,
    TRIM(UPPER(service_name)) AS service_name,
    TRIM(UPPER(category)) AS category,
    quantity,
    unit_price,
    total_amount,
    staging.safe_utf8(professional_name) AS professional_name,
    staging.safe_utf8(client_name) AS client_name,
    client_phone,
    CASE 
        WHEN payment_method ILIKE 'pix%' THEN 'Pix'
        WHEN payment_method ILIKE '*credito pacote%' THEN 'Crédito Pacote'
        ELSE payment_method 
    END AS payment_method,
    unique_hash
FROM raw.gendo_report_304;