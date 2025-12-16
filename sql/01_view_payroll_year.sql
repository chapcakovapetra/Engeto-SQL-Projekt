-- =========================================================
-- 01_view_payroll_year.sql
-- VIEW: v_petra_chapcakova_payroll_year
-- Účel: Roční průměrná hrubá mzda v ČR + meziroční změna (YoY %).
-- Vstupy: czechia_payroll, czechia_payroll_value_type
-- Výstup: year, avg_gross_wage, wage_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

CREATE OR REPLACE VIEW v_petra_chapcakova_payroll_year AS
WITH wages_year AS (
    SELECT
        payroll_year AS year,
        AVG(p.value) AS avg_gross_wage
    FROM czechia_payroll p
    JOIN czechia_payroll_value_type vt
        ON p.value_type_code = vt.code
    WHERE vt.name ILIKE 'Průměrná hrubá mzda%'
      AND p.value IS NOT NULL
    GROUP BY payroll_year
)
SELECT
    year,
    avg_gross_wage,
    100.0 * (avg_gross_wage / LAG(avg_gross_wage) OVER (ORDER BY year) - 1) AS wage_yoy_pct
FROM wages_year
ORDER BY year;
