-- 02_queries_and_views.sql
-- Add your CREATE VIEW statements here, one-by-one, and re-run this file.
-- You can re-run safely; each view is dropped before creation.
-- Helpful SQLite shell commands:
--   .mode column
--   .headers on
--   .tables
--   SELECT MAX(prod_month) FROM monthly_production;

-- 1) v1_leases(lease_name, county, state, royalty_rate_pct)
-- Hint: multiply royalty_rate by 100 and round to one decimal place (e.g., 20.0).
DROP VIEW IF EXISTS v1_leases;
-- CREATE VIEW v1_leases AS
-- SELECT ... FROM leases;
CREATE VIEW v1_leases AS
SELECT lease_name, county, state, ROUND(royalty_rate*100, 1) AS royalty_rate_pct FROM leases
WHERE state = 'OK' ORDER BY royalty_rate_pct DESC;

-- 2) v2_active_wells(lease_name, well_name, api_number, operator_name)
-- Hint: JOIN wells→leases→operators. Filter WHERE status='ACTIVE'.
DROP VIEW IF EXISTS v2_active_wells;
-- CREATE VIEW v2_active_wells AS
-- SELECT ... FROM ... JOIN ... WHERE ...;
CREATE VIEW v2_active_wells AS
SELECT l.lease_name, w.well_name, w.api_number, o.operator_name
FROM leases l
JOIN wells w ON l.id = w.lease_id
JOIN operators o ON o.id = w.operator_id
WHERE status = 'ACTIVE'; 

-- 3) v3_last_month_oil(well_name, prod_month, oil_bbl)
-- Hint: Use a CTE or subquery to get MAX(prod_month) from monthly_production.
DROP VIEW IF EXISTS v3_last_month_oil;
-- CREATE VIEW v3_last_month_oil AS
-- WITH maxm AS (SELECT MAX(prod_month) AS m FROM monthly_production)
-- SELECT ... WHERE m.prod_month=(SELECT m FROM maxm);
CREATE VIEW v3_last_month_oil AS
WITH maxm AS (SELECT MAX(prod_month) AS m FROM monthly_production)
SELECT w.well_name, mp.prod_month, mp.oil_bbl FROM wells w
JOIN monthly_production mp ON mp.well_id = w.id 
JOIN maxm ON mp.prod_month = maxm.m
ORDER BY w.well_name ASC;

-- 4) v4_lease_totals_last_month(lease_name, prod_month, total_oil_bbl)
-- Hint: leases→wells→monthly_production, GROUP BY lease.
DROP VIEW IF EXISTS v4_lease_totals_last_month;
-- CREATE VIEW v4_lease_totals_last_month AS
-- WITH maxm AS (...)
-- SELECT l.lease_name, (SELECT m FROM maxm) AS prod_month, SUM(m.oil_bbl) AS total_oil_bbl
-- FROM monthly_production m JOIN wells w ON ... JlOIN leases l ON ...
-- WHERE m.prod_month=(SELECT m FROM maxm)
-- GROUP BY l.id, l.lease_name;
CREATE VIEW v4_lease_totals_last_month AS
WITH maxm AS (SELECT MAX(prod_month) AS m FROM monthly_production)
SELECT l.lease_name, (SELECT m FROM maxm) AS prod_month, SUM(m.oil_bbl) AS total_oil_bbl
FROM monthly_production m
JOIN wells w ON w.id = m.well_id
JOIN leases l ON l.id = w.lease_id
WHERE m.prod_month = (SELECT m FROM maxm)
GROUP BY l.id, l.lease_name;

-- 5) v5_avg_oil_by_well(well_name, avg_oil_bbl)
-- Hint: AVG over all months; ROUND to 1 decimal.
DROP VIEW IF EXISTS v5_avg_oil_by_well;
-- CREATE VIEW v5_avg_oil_by_well AS
-- SELECT w.well_name, ROUND(AVG(m.oil_bbl),1) AS avg_oil_bbl
-- FROM monthly_production m JOIN wells w ON ...
-- GROUP BY w.id, w.well_name;
CREATE VIEW v5_avg_oil_by_well AS
SELECT w.well_name, ROUND(AVG(m.oil_bbl),1) AS avg_oil_bbl
FROM monthly_production m JOIN wells w ON w.id = m.well_id
GROUP BY w.id, w.well_name;

-- 6) v6_operator_scoreboard_last_month(operator_name, active_well_count, total_oil_bbl)
-- Hint: One CTE counts ACTIVE wells per operator; another sums last-month oil per operator; JOIN them.
DROP VIEW IF EXISTS v6_operator_scoreboard_last_month;
-- CREATE VIEW v6_operator_scoreboard_last_month AS
-- WITH maxm AS (...),
-- active_counts AS (SELECT o.id AS operator_id, o.operator_name, SUM(CASE WHEN w.status='ACTIVE' THEN 1 ELSE 0 END) AS active_well_count FROM operators o LEFT JOIN wells w ON w.operator_id=o.id GROUP BY o.id),
-- last_month_oil AS (SELECT o.id AS operator_id, COALESCE(SUM(m.oil_bbl),0) AS total_oil_bbl FROM operators o LEFT JOIN wells w ON w.operator_id=o.id LEFT JOIN monthly_production m ON m.well_id=w.id AND m.prod_month=(SELECT m FROM maxm) GROUP BY o.id)
-- SELECT a.operator_name, a.active_well_count, l.total_oil_bbl FROM active_counts a JOIN last_month_oil l ON l.operator_id=a.operator_id;

-- 7) v7_estimated_lease_revenue_last_month(lease_name, prod_month, total_oil_bbl, oil_price, estimated_revenue_usd)
-- Hint: use last month + oil price from price_assumptions; ROUND revenue to 2 decimals.
DROP VIEW IF EXISTS v7_estimated_lease_revenue_last_month;
-- CREATE VIEW v7_estimated_lease_revenue_last_month AS
-- WITH maxm AS (...), oil_price AS (SELECT usd_per_unit AS p FROM price_assumptions WHERE product='OIL')
-- SELECT l.lease_name, (SELECT m FROM maxm) AS prod_month, SUM(m.oil_bbl) AS total_oil_bbl,
--        (SELECT p FROM oil_price) AS oil_price,
--        ROUND(SUM(m.oil_bbl) * (SELECT p FROM oil_price), 2) AS estimated_revenue_usd
-- FROM monthly_production m JOIN wells w ON ... JOIN leases l ON ...
-- WHERE m.prod_month=(SELECT m FROM maxm)
-- GROUP BY l.id, l.lease_name;

-- 8) v8_county_active_last_month(lease_name, well_name, prod_month, oil_bbl) -- county='Canadian'
-- Hint: filter leases.county='Canadian' AND wells.status='ACTIVE' AND last-month only.
DROP VIEW IF EXISTS v8_county_active_last_month;
-- CREATE VIEW v8_county_active_last_month AS
-- WITH maxm AS (...)
-- SELECT l.lease_name, w.well_name, (SELECT m FROM maxm) AS prod_month, m.oil_bbl
-- FROM leases l JOIN wells w ON ... JOIN monthly_production m ON ...
-- WHERE l.county='Canadian' AND w.status='ACTIVE' AND m.prod_month=(SELECT m FROM maxm);

-- 9) v9_zero_runs(well_name, zero_month_count)
-- Hint: count months where oil_bbl=0 AND gas_mcf=0; include only wells with count >= 2.
DROP VIEW IF EXISTS v9_zero_runs;
-- CREATE VIEW v9_zero_runs AS
-- WITH zeros AS (SELECT w.well_name, COUNT(*) AS zero_month_count FROM monthly_production m JOIN wells w ON ... WHERE m.oil_bbl=0 AND m.gas_mcf=0 GROUP BY w.well_name)
-- SELECT well_name, zero_month_count FROM zeros WHERE zero_month_count>=2;

-- 10) v10_view_last_month_lease_oil(lease_id, lease_name, prod_month, total_oil_bbl)
-- Hint: like task 4, but include lease_id.
DROP VIEW IF EXISTS v10_view_last_month_lease_oil;
-- CREATE VIEW v10_view_last_month_lease_oil AS
-- WITH maxm AS (...)
-- SELECT l.id AS lease_id, l.lease_name, (SELECT m FROM maxm) AS prod_month, SUM(m.oil_bbl) AS total_oil_bbl
-- FROM monthly_production m JOIN wells w ON ... JOIN leases l ON ...
-- WHERE m.prod_month=(SELECT m FROM maxm)
-- GROUP BY l.id, l.lease_name;
