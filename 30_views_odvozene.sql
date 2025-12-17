-- Soubor: 30_views_odvozene.sql
-- Účel: Vytvoření odvozených VIEW, které už závisí na primární tabulce.
-- Závislosti:
--   - t_petra_chapcakova_project_sql_primary_final
--   - v_petra_chapcakova_cz_gdp_year (ze souboru 10_views_zakladni.sql)

SET search_path TO data_academy_content;

-- =========================================================
-- 3) ODVOZENÉ VIEW – ZÁVISLÉ NA PRIMÁRNÍ TABULCE
-- =========================================================

-- 3.1 v_petra_chapcakova_food_wage_year
-- Účel: Souhrnný „index cen potravin“ (průměr price_yoy_pct) + růst mezd podle roku.
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


-- 3.2 v_petra_chapcakova_macro_vs_food_wage
-- Účel: Spojení růstu HDP, indexu cen potravin a růstu mezd podle roku (pro Q5).
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
