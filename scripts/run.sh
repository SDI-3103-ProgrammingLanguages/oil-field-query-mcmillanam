#!/usr/bin/env bash
set -euo pipefail
sqlite3 basin.db < 01_schema_and_data.sql
sqlite3 basin.db < 02_queries_and_views.sql || true
echo
echo "Open the DB:"
echo "  sqlite3 basin.db"
echo "Helpful commands inside sqlite3:"
echo "  .mode column"
echo "  .headers on"
echo "  .tables"
