CREATE OR REPLACE VIEW analytics.v_ticket_medio_mensal AS
SELECT
  service_month,
  SUM(total_amount) / NULLIF(COUNT(DISTINCT order_code), 0) AS ticket_medio
FROM analytics.v_gendo_304_base
GROUP BY service_month
ORDER BY service_month;
