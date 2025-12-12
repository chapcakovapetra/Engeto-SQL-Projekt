-- =========================================================
-- 04_view_cz_gdp_year.sql
-- VIEW: v_petra_chapcakova_cz_gdp_year
-- Účel: HDP ČR podle roku + meziroční změna HDP (YoY %).
-- Vstupy: economies
-- Filtr: country = 'Czech Republic'
-- Výstup: year, gdp, population, gini, gdp_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

CREATE OR REPLACE VIEW v_petra_chapcakova_cz_gdp_year AS
SELECT
    year,
    gdp,
    population,
    gini,
    100.0 * (gdp / LAG(gdp) OVER (ORDER BY year) - 1) AS gdp_yoy_pct
FROM economies
WHERE country = 'Czech Republic'
ORDER BY year;