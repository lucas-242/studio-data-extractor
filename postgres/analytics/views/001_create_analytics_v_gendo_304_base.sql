CREATE OR REPLACE VIEW analytics.v_gendo_304_base AS
SELECT
  id,
  service_date,
  date_trunc('month', service_date)::date AS service_month,

  order_code,

  service_name,
  category,

  quantity,
  unit_price,
  total_amount,
  balance,

  analytics.safe_utf8(professional_name) AS professional_name,
  analytics.safe_utf8(client_name)       AS client_name,

  client_cpf,
  client_email,
  client_phone,

  payment_method,

  extracted_at
FROM raw.gendo_report_304;
