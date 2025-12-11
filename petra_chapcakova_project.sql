-- Petra Chapčáková
-- Data Academy 2025-04-24
-- Projekt: Projekt z SQL

SET search_path TO data_academy_content;

-- =========================================================
-- 1) POMOCNÉ POHLEDY – NEZÁVISLÉ NA FINÁLNÍCH TABULKÁCH
-- =========================================================

-- 1.1 Roční průměrná hrubá mzda za ČR
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
	100 * (avg_gross_wage
			/ LAG(avg_gross_wage) OVER (ORDER BY year)
			- 1) AS wage_yoy_pct
FROM wages_year
ORDER BY year;


-- 1.2 Roční průměrné ceny potravin podle kategorií (ČR)
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
	GROUP BY EXTRACT(YEAR FROM cp.date_from),
				pc.code, pc.name, pc.price_unit
)
SELECT
	year,
	category_code,
	category_name,
	price_unit,
	avg_price,
	100 * (avg_price
			/ LAG(avg_price) OVER (
				PARTITION BY category_code
				ORDER BY year
			) - 1) AS price_yoy_pct
FROM price_year
ORDER BY category_code, year;


-- 1.3 Roční průměrná hrubá mzda podle odvětví
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
	100 * (avg_gross_wage
			/ LAG(avg_gross_wage) OVER (
				PARTITION BY industry_code
				ORDER BY year
			) - 1) AS wage_yoy_pct
FROM industry_year
ORDER BY industry_code, year;


-- 1.4 HDP ČR podle roku
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



-- =========================================================
-- 2) FINÁLNÍ TABULKY
-- =========================================================

-- 2.1 Primární finální tabulka pro ČR
DROP TABLE IF EXISTS t_petra_chapcakova_project_sql_primary_final;

CREATE TABLE t_petra_chapcakova_project_sql_primary_final AS
SELECT
	p.year,
	p.category_code,
	p.category_name,
	p.price_unit,
	p.avg_price,
	p.price_yoy_pct,
	w.avg_gross_wage,
	w.wage_yoy_pct,
	(w.avg_gross_wage / p.avg_price) AS units_from_avg_wage
FROM v_petra_chapcakova_price_year   AS p
JOIN v_petra_chapcakova_payroll_year AS w
	ON p.year = w.year
ORDER BY p.year, p.category_code;


-- 2.2 Sekundární tabulka – evropské státy (mimo ČR)
DROP TABLE IF EXISTS t_petra_chapcakova_project_sql_secondary_final;

CREATE TABLE t_petra_chapcakova_project_sql_secondary_final AS
WITH bounds AS (
	SELECT
		MIN(year) AS first_year,
		MAX(year) AS last_year
	FROM t_petra_chapcakova_project_sql_primary_final
)
SELECT
	e.country,
	e.year,
	e.gdp,
	e.population,
	e.gini,
	100.0 * (
		e.gdp / LAG(e.gdp) OVER (
			PARTITION BY e.country
			ORDER BY e.year
		) - 1
	) AS gdp_yoy_pct
FROM economies e
JOIN countries c
	ON e.country = c.country
CROSS JOIN bounds b
WHERE c.continent = 'Europe'
	AND e.country <> 'Czech Republic'
	AND e.year BETWEEN b.first_year AND b.last_year;



-- =========================================================
-- 3) POHLEDY ZÁVISLÉ NA PRIMÁRNÍ TABULCE
-- =========================================================

-- 3.1 Souhrnný index cen potravin + růst mezd podle roku
CREATE OR REPLACE VIEW v_petra_chapcakova_food_wage_year AS
WITH food AS (
	SELECT
		year,
		AVG(price_yoy_pct) AS food_yoy_pct
	FROM t_petra_chapcakova_project_sql_primary_final
	WHERE price_yoy_pct IS NOT NULL
	GROUP BY year
),
wages AS (
	SELECT DISTINCT
		year,
		wage_yoy_pct
	FROM t_petra_chapcakova_project_sql_primary_final
	WHERE wage_yoy_pct IS NOT NULL
)
SELECT
	f.year,
	f.food_yoy_pct,
	w.wage_yoy_pct
FROM food f
LEFT JOIN wages w USING (year);


-- 3.2 HDP vs index cen potravin vs růst mezd
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



-- =========================================================
-- 4) ANALYTICKÉ DOTAZY – Q1–Q5
-- =========================================================

-- Q1: Rostou v průběhu let mzdy ve všech odvětvích,
--     nebo v některých klesají?

-- Q1a: Odvětví, kde byl aspoň jeden rok s poklesem mezd
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

-- Q1b: Minimum a maximum meziročního růstu mezd podle odvětví
SELECT
	industry_code,
	industry_name,
	MIN(wage_yoy_pct) AS min_yoy_pct,
	MAX(wage_yoy_pct) AS max_yoy_pct
FROM v_petra_chapcakova_payroll_industry_year
GROUP BY industry_code, industry_name
ORDER BY min_yoy_pct;



-- Q2: Kolik litrů mléka / kg chleba si lze koupit
--     z průměrné mzdy v prvním a posledním roce dat?

WITH bounds AS (
	SELECT
		MIN(year) AS first_year,
		MAX(year) AS last_year
	FROM t_petra_chapcakova_project_sql_primary_final
),
milk_and_bread AS (
	SELECT
		t.year,
		t.category_name,
		t.price_unit,
		t.avg_price,
		t.units_from_avg_wage
	FROM t_petra_chapcakova_project_sql_primary_final t
	CROSS JOIN bounds b
	WHERE t.year IN (b.first_year, b.last_year)
		AND (
			t.category_name ILIKE 'Mléko%'  
		OR t.category_name ILIKE 'Chléb%'  
		)
)
SELECT *
FROM milk_and_bread
ORDER BY year, category_name;



-- Q3: Která kategorie potravin zdražuje nejpomaleji?

SELECT
	category_code,
	category_name,
	AVG(price_yoy_pct) AS avg_price_yoy_pct
FROM t_petra_chapcakova_project_sql_primary_final
WHERE price_yoy_pct IS NOT NULL
GROUP BY category_code, category_name
ORDER BY avg_price_yoy_pct   
LIMIT 5;



-- Q4: Existuje rok, kdy ceny potravin rostly o >10 p.b.
--     rychleji než průměrné mzdy?

WITH food_index AS (
	SELECT
		year,
		AVG(price_yoy_pct) AS food_yoy_pct
	FROM t_petra_chapcakova_project_sql_primary_final
	WHERE price_yoy_pct IS NOT NULL
	GROUP BY year
),
wages AS (
	SELECT DISTINCT
		year,
		wage_yoy_pct
	FROM t_petra_chapcakova_project_sql_primary_final
	WHERE wage_yoy_pct IS NOT NULL
),
combined AS (
	SELECT
		f.year,
		f.food_yoy_pct,
		w.wage_yoy_pct,
		(f.food_yoy_pct - w.wage_yoy_pct) AS diff_pp
	FROM food_index f
	JOIN wages w USING (year)
)
SELECT
	year,
	food_yoy_pct,
	wage_yoy_pct,
	diff_pp
FROM combined
WHERE diff_pp > 10      -- > 10 procentních bodů
ORDER BY year;



-- Q5: Má výše HDP vliv na změny mezd a cen potravin?

SELECT
	year,
	gdp_yoy_pct,
	food_yoy_pct,
	wage_yoy_pct
FROM v_petra_chapcakova_macro_vs_food_wage
ORDER BY year;
