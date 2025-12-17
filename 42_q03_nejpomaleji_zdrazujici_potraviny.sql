-- Soubor: 42_q03_nejpomaleji_zdrazujici_potraviny.sql
-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji?
-- Závislosti:
--   - t_petra_chapcakova_project_sql_primary_final (20_tabulka_primary_final.sql)

SET search_path TO data_academy_content;

SELECT
    category_code,
    category_name,
    AVG(price_yoy_pct) AS avg_price_yoy_pct
FROM t_petra_chapcakova_project_sql_primary_final
WHERE price_yoy_pct IS NOT NULL
GROUP BY category_code, category_name
ORDER BY avg_price_yoy_pct
LIMIT 5;
