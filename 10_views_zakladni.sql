-- Soubor: 10_views_zakladni.sql
-- Účel: Vytvoření základních VIEW (nezávislých na finálních tabulkách).
-- Pozn.: Každý VIEW je použit dále při tvorbě finálních tabulek a analytických dotazů.

SET search_path TO data_academy_content;

-- =========================================================
-- 1) ZÁKLADNÍ VIEW – NEZÁVISLÉ NA FINÁLNÍCH TABULKÁCH
-- =========================================================

-- 1.1 v_petra_chapcakova_payroll_year
-- Účel: Roční průměrná hrubá mzda v ČR + meziroční změna (%).
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
    100 * (
        avg_gross_wage / LAG(avg_gross_wage) OVER (ORDER BY year) - 1
    ) AS wage_yoy_pct
FROM wages_year
ORDER BY year;


-- 1.2 v_petra_chapcakova_price_year
-- Účel: Roční průměrné ceny potravin v ČR dle kategorií + meziroční změna (%).
-- Pozn.: Používá pouze národní průměry (region_code IS NULL).
CREATE OR REPLACE VIEW v_petra_chapcakova_price_year AS
WITH price_year AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        pc.code        AS category_code,
        pc.name        AS category_name,
        pc.price_unit  AS price_unit,
        AVG(cp.value)  AS avg_price
    FROM czechia_price cp
    JOIN czechia_price_category pc
        ON cp.category_code = pc.code
    WHERE cp.region_code IS NULL
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from),
        pc.code, pc.name, pc.price_unit
)
SELECT
    year,
    category_code,
    category_name,
    price_unit,
    avg_price,
    100 * (
        avg_price / LAG(avg_price) OVER (
            PARTITION BY category_code
            ORDER BY year
        ) - 1
    ) AS price_yoy_pct
FROM price_year
ORDER BY category_code, year;


-- 1.3 v_petra_chapcakova_payroll_industry_year
-- Účel: Roční průměrná hrubá mzda dle odvětví + meziroční změna (%).
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
    100 * (
        avg_gross_wage / LAG(avg_gross_wage) OVER (
            PARTITION BY industry_code
            ORDER BY year
        ) - 1
    ) AS wage_yoy_pct
FROM industry_year
ORDER BY industry_code, year;


-- 1.4 v_petra_chapcakova_cz_gdp_year
-- Účel: Makro data ČR podle roku (HDP, populace, GINI) + meziroční změna HDP (%).
CREATE OR REPLACE VIEW v_petra_chapcakova_cz_gdp_year AS
SELECT
    year,
    gdp,
    population,
    gini,
    100.0 * (
        gdp / LAG(gdp) OVER (ORDER BY year) - 1
    ) AS gdp_yoy_pct
FROM economies
WHERE country = 'Czech Republic';

