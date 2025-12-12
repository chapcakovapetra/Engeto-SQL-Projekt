-- =========================================================
-- 21_view_food_wage_year.sql
-- VIEW: v_petra_chapcakova_food_wage_year
-- Účel: “Index cen potravin” (průměr price_yoy_pct napříč kategoriemi) + růst mezd za rok.
-- Vstupy: t_petra_chapcakova_project_sql_primary_final
-- Výstup: year, food_yoy_pct, wage_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

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
LEFT JOIN wages w USING (year)
ORDER BY f.year;