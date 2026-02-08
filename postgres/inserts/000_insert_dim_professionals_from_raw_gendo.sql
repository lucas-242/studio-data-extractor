-- Insert professionals based on imported data
INSERT INTO dw.dim_professionals (full_name, contract_model, is_active)
SELECT DISTINCT 
    staging.safe_utf8(professional_name),
    'PJ',
    TRUE
FROM raw.gendo_report_304
ON CONFLICT (full_name) DO NOTHING;
