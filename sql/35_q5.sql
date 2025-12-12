-- =========================================================
-- 35_q5.sql (Výzkumná otázka 5)
-- Otázka v zadání: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
--                  Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
--                  či mzdách ve stejném nebo následujícím roce výraznějším růstem?
-- Účel: Základní porovnání vztahu HDP vs. mzdy vs. ceny potravin v čase.
-- Pozn.: Jde o datový podklad (ne kauzální důkaz) – interpretace je v README v části odpovědí.
-- Vstup: v_petra_chapcakova_macro_vs_food_wage
-- Výstup: year, gdp_yoy_pct, food_yoy_pct, wage_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

SELECT
    year,
    gdp_yoy_pct,
    food_yoy_pct,
    wage_yoy_pct
FROM v_petra_chapcakova_macro_vs_food_wage
ORDER BY year;
