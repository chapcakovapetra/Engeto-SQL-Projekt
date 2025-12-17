-- Soubor: 44_q05_hdp_vs_mzdy_a_potraviny.sql
-- Otázka 5: Má výše HDP vliv na změny mezd a cen potravin?
-- Závislosti:
--   - v_petra_chapcakova_macro_vs_food_wage (30_views_odvozene.sql)

SET search_path TO data_academy_content;

SELECT
    year,
    gdp_yoy_pct,
    food_yoy_pct,
    wage_yoy_pct
FROM v_petra_chapcakova_macro_vs_food_wage
ORDER BY year;
