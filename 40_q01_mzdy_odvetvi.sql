-- Soubor: 40_q01_mzdy_odvetvi.sql
-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Závislosti:
--   - v_petra_chapcakova_payroll_industry_year (10_views_zakladni.sql)

SET search_path TO data_academy_content;

-- =========================================================
-- Q1a: Odvětví, kde byl alespoň jeden rok s poklesem mezd (wage_yoy_pct < 0)
-- =========================================================
WITH trend AS (
    SELECT *
    FROM v_petra_chapcakova_payroll_industry_year
)
SELECT DISTINCT
    industry_code,
    industry_name
FROM trend
WHERE wage_yoy_pct < 0
ORDER BY industry_name;

-- =========================================================
-- Q1b: Minimum a maximum meziročního růstu mezd podle odvětví
-- =========================================================
SELECT
    industry_code,
    industry_name,
    MIN(wage_yoy_pct) AS min_yoy_pct,
    MAX(wage_yoy_pct) AS max_yoy_pct
FROM v_petra_chapcakova_payroll_industry_year
GROUP BY industry_code, industry_name
ORDER BY min_yoy_pct;

