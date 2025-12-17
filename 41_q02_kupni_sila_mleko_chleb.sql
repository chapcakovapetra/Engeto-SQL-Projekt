-- Soubor: 41_q02_kupni_sila_mleko_chleb.sql
-- Otázka 2: Kolik litrů mléka / kg chleba si lze koupit z průměrné mzdy v prvním a posledním roce dat?
-- Závislosti:
--   - t_petra_chapcakova_project_sql_primary_final (20_tabulka_primary_final.sql)

SET search_path TO data_academy_content;

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

