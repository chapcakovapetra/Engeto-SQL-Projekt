-- =========================================================
-- 12_table_secondary_final.sql
-- TABLE: t_petra_chapcakova_project_sql_secondary_final
-- Účel: Finální sekundární tabulka (Evropa mimo ČR) – HDP, populace, Gini + YoY růst HDP.
-- Logika: časový rozsah je zarovnán dle primární tabulky (bounds = min/max year).
-- Vstupy: economies, countries, t_petra_chapcakova_project_sql_primary_final
-- Filtr: continent = 'Europe' AND country <> 'Czech Republic'
-- Výstup: country, year, gdp, population, gini, gdp_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

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
  AND e.year BETWEEN b.first_year AND b.last_year
ORDER BY e.country, e.year;
