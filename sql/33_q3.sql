-- =========================================================
-- 33_q3.sql (Výzkumná otázka 3)
-- Otázka v zadání: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
-- Účel: Najít potraviny s nejpomalejším zdražováním (nejnižší průměrný YoY růst ceny).
-- Logika: průměr price_yoy_pct za celé období dle kategorie, seřazení od nejnižšího, TOP 5.
-- Vstup: t_petra_chapcakova_project_sql_primary_final
-- Výstup: category_code, category_name, avg_price_yoy_pct
-- =========================================================

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
