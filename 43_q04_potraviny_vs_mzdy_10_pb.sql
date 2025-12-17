-- Soubor: 43_q04_potraviny_vs_mzdy_10_pb.sql
-- Otázka 4: Existuje rok, kdy ceny potravin rostly o >10 p.b. rychleji než průměrné mzdy?
-- Závislosti:
--   - t_petra_chapcakova_project_sql_primary_final (20_tabulka_primary_final.sql)

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

