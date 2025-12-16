-- =========================================================
-- 31_q1.sql (Výzkumná otázka 1)
-- Otázka v zadání: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Účel: Ověřit, zda mzdy rostou ve všech odvětvích kontinuálně, nebo se v některých objevují roky poklesu.
-- Vstup: v_petra_chapcakova_payroll_industry_year
-- Výstup:
--   - Q1a: seznam odvětví, kde existuje alespoň jeden rok s poklesem mezd (wage_yoy_pct < 0)
--   - Q1b: min/max meziroční změna mezd dle odvětví (rozsah volatility)
-- =========================================================


SET search_path TO data_academy_content;

-- Q1a
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

-- Q1b
SELECT
    industry_code,
    industry_name,
    MIN(wage_yoy_pct) AS min_yoy_pct,
    MAX(wage_yoy_pct) AS max_yoy_pct
FROM v_petra_chapcakova_payroll_industry_year
GROUP BY industry_code, industry_name

ORDER BY min_yoy_pct;
