-- =========================================================
-- 02_view_price_year.sql
-- VIEW: v_petra_chapcakova_price_year
-- Účel: Roční průměrné ceny potravin dle kategorie + meziroční změna ceny (YoY %).
-- Filtr: pouze národní průměr (region_code IS NULL)
-- Vstupy: czechia_price, czechia_price_category
-- Výstup: year, category_code, category_name, price_unit, avg_price, price_yoy_pct
-- =========================================================

SET search_path TO data_academy_content;

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
    100.0 * (
        avg_price / LAG(avg_price) OVER (
            PARTITION BY category_code
            ORDER BY year
        ) - 1
    ) AS price_yoy_pct
FROM price_year
ORDER BY category_code, year;