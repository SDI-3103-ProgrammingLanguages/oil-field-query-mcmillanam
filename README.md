# 🛢️ Oil Lease Tracker — SQL Practice (Oklahoma Edition)

Welcome! You'll explore a small SQLite database tracking leases, wells, operators, and monthly production (oil & gas) in Oklahoma.

## How to Run
```bash
# 1) Build the database with schema + seed data
sqlite3 basin.db < 01_schema_and_data.sql

# 2) Add your CREATE VIEW statements and run them
sqlite3 basin.db < 02_queries_and_views.sql

# 3) Explore results interactively
sqlite3 basin.db
sqlite> .mode column
sqlite> .headers on
sqlite> .tables
sqlite> SELECT * FROM leases LIMIT 5;
sqlite> SELECT * FROM v1_leases;
```

## Your Task (create these VIEWS in order)
1. `v1_leases(lease_name, county, state, royalty_rate_pct)`
2. `v2_active_wells(lease_name, well_name, api_number, operator_name)`
3. `v3_last_month_oil(well_name, prod_month, oil_bbl)`
4. `v4_lease_totals_last_month(lease_name, prod_month, total_oil_bbl)`
5. `v5_avg_oil_by_well(well_name, avg_oil_bbl)` — round to **1 decimal**
6. `v6_operator_scoreboard_last_month(operator_name, active_well_count, total_oil_bbl)`
7. `v7_estimated_lease_revenue_last_month(lease_name, prod_month, total_oil_bbl, oil_price, estimated_revenue_usd)` — **2 decimals**
8. `v8_county_active_last_month(lease_name, well_name, prod_month, oil_bbl)` — for **county='Canadian'**
9. `v9_zero_runs(well_name, zero_month_count)` — wells with **>= 2** months where oil=0 AND gas=0
10. `v10_view_last_month_lease_oil(lease_id, lease_name, prod_month, total_oil_bbl)`

### Tips
- “Last month” = `MAX(prod_month)` in `monthly_production`.
- Join path for lease totals: `leases -> wells -> monthly_production`.
- Revenue (oil only) = `total_oil_bbl × oil_price` (from `price_assumptions`).

**Edit only `02_queries_and_views.sql`.** `01_schema_and_data.sql` should remain unchanged so you can rebuild cleanly anytime.
