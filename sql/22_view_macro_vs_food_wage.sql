-- =========================================================
-- 22_view_macro_vs_food_wage.sql
-- VIEW: v_petra_chapcakova_macro_vs_food_wage
-- Účel: Porovnání makro vývoje – spojení růstu HDP, indexu cen potravin a růstu mezd dle roku.
-- Vstupy: v_petra_chapcakova_cz_gdp_year, v_petra_chapcakova_food_wage_year
-- Výstup: year, gdp_yoy_pct, food_yoy_pct, wage_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

CREATE OR REPLACE VIEW v_petra_chapcakova_macro_vs_food_wage AS
SELECT
    g.year,
    g.gdp_yoy_pct,
    f.food_yoy_pct,
    f.wage_yoy_pct
FROM v_petra_chapcakova_cz_gdp_year g
LEFT JOIN v_petra_chapcakova_food_wage_year f
  ON g.year = f.year
ORDER BY g.year;
