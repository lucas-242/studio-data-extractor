CREATE OR REPLACE VIEW analytics.v_pagamentos AS
SELECT
  payment_method,
  COUNT(DISTINCT order_code) AS qtd_comandas,
  SUM(total_amount) AS faturamento
FROM analytics.v_gendo_304_base
GROUP BY payment_method
ORDER BY faturamento DESC;
