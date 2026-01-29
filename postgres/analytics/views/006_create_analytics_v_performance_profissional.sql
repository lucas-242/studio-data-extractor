CREATE OR REPLACE VIEW analytics.v_performance_profissional AS
SELECT
  professional_name,
  COUNT(DISTINCT order_code) AS qtd_atendimentos,
  SUM(quantity) AS total_servicos,
  SUM(total_amount) AS faturamento
FROM analytics.v_gendo_304_base
GROUP BY professional_name
ORDER BY faturamento DESC;
