-- Soubor: 20_tabulka_primary_final.sql
-- Účel: Vytvoření primární finální tabulky pro ČR (mzdy + ceny potravin).
-- Závislosti: vyžaduje existenci VIEW:
--   - v_petra_chapcakova_payroll_year
--   - v_petra_chapcakova_price_year

SET search_path TO data_academy_content;

-- =========================================================
-- 2.1 PRIMÁRNÍ FINÁLNÍ TABULKA (ČR)
-- =========================================================

-- Tabulka obsahuje:
-- - průměrné ceny potravin (ročně, dle kategorií),
-- - průměrnou hrubou mzdu (ročně, ČR),
-- - meziroční změny (%),
-- - kupní sílu: kolik jednotek potraviny lze koupit za průměrnou mzdu.
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
