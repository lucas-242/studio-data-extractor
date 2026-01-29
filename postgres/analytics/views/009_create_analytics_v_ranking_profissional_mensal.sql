CREATE OR REPLACE VIEW analytics.v_ranking_profissional_mensal AS
SELECT
  service_month,
  professional_name,
  SUM(total_amount) AS faturamento,
  RANK() OVER (
    PARTITION BY service_month
    ORDER BY SUM(total_amount) DESC
  ) AS ranking
FROM analytics.v_gendo_304_base
GROUP BY service_month, professional_name;
