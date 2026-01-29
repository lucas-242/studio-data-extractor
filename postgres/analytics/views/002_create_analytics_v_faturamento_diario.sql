CREATE OR REPLACE VIEW analytics.v_faturamento_diario AS
SELECT
  service_date,
  SUM(total_amount) AS faturamento_bruto,
  SUM(balance) AS saldo_total,
  COUNT(DISTINCT order_code) AS qtd_comandas
FROM analytics.v_gendo_304_base
GROUP BY service_date
ORDER BY service_date;
