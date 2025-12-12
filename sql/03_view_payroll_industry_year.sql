-- =========================================================
-- 03_view_payroll_industry_year.sql
-- VIEW: v_petra_chapcakova_payroll_industry_year
-- Účel: Roční průměrná hrubá mzda podle odvětví (CZ-NACE) + YoY % změna mezd.
-- Vstupy: czechia_payroll, czechia_payroll_value_type, czechia_payroll_industry_branch
-- Výstup: year, industry_code, industry_name, avg_gross_wage, wage_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

CREATE OR REPLACE VIEW v_petra_chapcakova_payroll_industry_year AS
WITH industry_year AS (
    SELECT
        p.payroll_year AS year,
        ib.code        AS industry_code,
        ib.name        AS industry_name,
        AVG(p.value)   AS avg_gross_wage
    FROM czechia_payroll p
    JOIN czechia_payroll_value_type vt
        ON p.value_type_code = vt.code
    JOIN czechia_payroll_industry_branch ib
        ON p.industry_branch_code = ib.code
    WHERE vt.name ILIKE 'Průměrná hrubá mzda%'
      AND p.value IS NOT NULL
    GROUP BY p.payroll_year, ib.code, ib.name
)
SELECT
    year,
    industry_code,
    industry_name,
    avg_gross_wage,
    100.0 * (
        avg_gross_wage / LAG(avg_gross_wage) OVER (
            PARTITION BY industry_code
            ORDER BY year
        ) - 1
    ) AS wage_yoy_pct
FROM industry_year
ORDER BY industry_code, year;
