CREATE OR REPLACE VIEW analytics.v_servicos_mais_vendidos AS
SELECT
  service_name,
  category,
  SUM(quantity) AS total_quantidade,
  SUM(total_amount) AS faturamento
FROM analytics.v_gendo_304_base
GROUP BY service_name, category
ORDER BY faturamento DESC;
