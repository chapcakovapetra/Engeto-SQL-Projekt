-- =========================================================
-- 34_q4.sql (Výzkumná otázka 4)
-- Otázka v zadání: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Účel: Ověřit, zda existuje rok, kdy potraviny zdražily o >10 p. b. rychleji než mzdy.
-- Logika: vytvoří index cen potravin (AVG price_yoy_pct) a porovná s wage_yoy_pct, diff_pp > 10.
-- Vstup: t_petra_chapcakova_project_sql_primary_final
-- Výstup: year, food_yoy_pct, wage_yoy_pct, diff_pp (pouze roky splňující podmínku)
-- =========================================================

SET search_path TO data_academy_content;

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
WHERE diff_pp > 10
ORDER BY year;
