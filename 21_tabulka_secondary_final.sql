-- Soubor: 21_tabulka_secondary_final.sql
-- Účel: Vytvoření sekundární tabulky – evropské státy (mimo ČR) v rozsahu let dle primární tabulky.
-- Závislosti: vyžaduje existenci tabulky:
--   - t_petra_chapcakova_project_sql_primary_final

SET search_path TO data_academy_content;

-- =========================================================
-- 2.2 SEKUNDÁRNÍ TABULKA (EVROPA MIMO ČR)
-- =========================================================

-- Tabulka obsahuje pro evropské země:
-- - HDP, populace, GINI,
-- - meziroční změnu HDP (%), a to jen v období, které odpovídá rozsahu let v primární tabulce.
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

