-- =========================================================
-- 32_q2.sql (Výzkumná otázka 2)
-- Otázka v zadání: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
-- Účel: Porovnat dostupnost mléka a chleba z průměrné mzdy v prvním a posledním společném roce dat.
-- Logika: nejdřív určí bounds (min/max rok v primární tabulce), pak vybere jen mléko/chléb pro tyto roky.
-- Vstup: t_petra_chapcakova_project_sql_primary_final
-- Výstup: year, category_name, price_unit, avg_price, units_from_avg_wage
-- =========================================================

SET search_path TO data_academy_content;

WITH bounds AS (
    SELECT
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM t_petra_chapcakova_project_sql_primary_final
)
SELECT
    t.year,
    t.category_name,
    t.price_unit,
    t.avg_price,
    t.units_from_avg_wage
FROM t_petra_chapcakova_project_sql_primary_final t
CROSS JOIN bounds b
WHERE t.year IN (b.first_year, b.last_year)
  AND (t.category_name ILIKE 'Mléko%' OR t.category_name ILIKE 'Chléb%')
ORDER BY t.year, t.category_name;
