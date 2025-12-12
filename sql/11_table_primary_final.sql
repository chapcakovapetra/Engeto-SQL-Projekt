-- =========================================================
-- 11_table_primary_final.sql
-- TABLE: t_petra_chapcakova_project_sql_primary_final
-- Účel: Finální primární tabulka (ČR) – spojení mezd a cen potravin do jednoho datasetu.
-- Logika: k cenám potravin dle roku doplní průměrnou mzdu + YoY metriky + kupní sílu (units_from_avg_wage).
-- Vstupy: v_petra_chapcakova_price_year, v_petra_chapcakova_payroll_year
-- Výstup: year, category_*, avg_price, price_yoy_pct, avg_gross_wage, wage_yoy_pct, units_from_avg_wage
-- =========================================================

SET search_path TO data_academy_content;

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
