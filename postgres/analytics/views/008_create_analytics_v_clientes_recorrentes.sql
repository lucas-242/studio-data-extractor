CREATE OR REPLACE VIEW analytics.v_clientes_recorrentes AS
SELECT
  client_name,
  client_cpf,
  COUNT(DISTINCT order_code) AS qtd_visitas,
  SUM(total_amount) AS valor_total
FROM analytics.v_gendo_304_base
WHERE client_cpf IS NOT NULL
GROUP BY client_name, client_cpf
HAVING COUNT(DISTINCT order_code) > 1
ORDER BY qtd_visitas DESC;
