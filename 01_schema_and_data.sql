-- 01_schema_and_data.sql
PRAGMA foreign_keys = ON;

-- Safety drops
DROP TABLE IF EXISTS monthly_production;
DROP TABLE IF EXISTS wells;
DROP TABLE IF EXISTS operators;
DROP TABLE IF EXISTS leases;
DROP TABLE IF EXISTS price_assumptions;

CREATE TABLE leases (
  id INTEGER PRIMARY KEY,
  lease_name TEXT NOT NULL,
  county TEXT NOT NULL,
  state TEXT NOT NULL CHECK(state IN ('OK')),
  royalty_rate REAL NOT NULL CHECK(royalty_rate BETWEEN 0 AND 1)
);

CREATE TABLE operators (
  id INTEGER PRIMARY KEY,
  operator_name TEXT NOT NULL UNIQUE
);

CREATE TABLE wells (
  id INTEGER PRIMARY KEY,
  api_number TEXT NOT NULL UNIQUE,
  well_name TEXT NOT NULL,
  lease_id INTEGER NOT NULL REFERENCES leases(id),
  operator_id INTEGER NOT NULL REFERENCES operators(id),
  status TEXT NOT NULL CHECK(status IN ('ACTIVE','SHUT-IN','PLUGGED'))
);

CREATE TABLE monthly_production (
  well_id INTEGER NOT NULL REFERENCES wells(id),
  prod_month TEXT NOT NULL,             -- 'YYYY-MM'
  oil_bbl REAL NOT NULL CHECK(oil_bbl >= 0),
  gas_mcf REAL NOT NULL CHECK(gas_mcf >= 0),
  PRIMARY KEY (well_id, prod_month)
);

CREATE TABLE price_assumptions (
  product TEXT PRIMARY KEY CHECK(product IN ('OIL','GAS')),
  usd_per_unit REAL NOT NULL CHECK(usd_per_unit > 0)
);

-- Leases localized to OK plays/fields
INSERT INTO leases(id, lease_name, county, state, royalty_rate) VALUES
  (1, 'STACK - Sooner Trend Unit', 'Canadian', 'OK', 0.20),
  (2, 'SCOOP - Springer South',    'Grady',    'OK', 0.22),
  (3, 'Anadarko - Blaine Core',    'Blaine',   'OK', 0.20),
  (4, 'Woodford - Garvin',         'Garvin',   'OK', 0.25),
  (5, 'Miss Lime - Grant North',   'Grant',    'OK', 0.18),
  (6, 'Granite Wash - Caddo Line', 'Caddo',    'OK', 0.21),
  (7, 'Hunton - Kingfisher East',  'Kingfisher','OK',0.20),
  (8, 'Arkoma - Pittsburg Gas',    'Pittsburg','OK', 0.25),
  (9, 'Red Fork - Creek Legacy',   'Creek',    'OK', 0.20);

-- Operators
INSERT INTO operators(id, operator_name) VALUES
  (1, 'Sooner Energy LLC'),
  (2, 'Red Fork Resources'),
  (3, 'Cimarron Operating'),
  (4, 'Prairie Rock Oil & Gas');

-- Wells (IDs 1..14)
INSERT INTO wells(id, api_number, well_name, lease_id, operator_id, status) VALUES
  (1,  '35-017-30001', 'STU 12-1H',              1, 1, 'ACTIVE'),
  (2,  '35-017-30002', 'STU 12-2H',              1, 1, 'ACTIVE'),
  (3,  '35-051-40001', 'SPRINGER SOUTH 1-9H',    2, 3, 'ACTIVE'),
  (4,  '35-051-40002', 'SPRINGER SOUTH 2-9H',    2, 3, 'ACTIVE'),
  (5,  '35-011-50001', 'BLAINE CORE 18-1H',      3, 1, 'ACTIVE'),
  (6,  '35-049-60002', 'GARVIN WOODFORD 7-2H',   4, 2, 'ACTIVE'),
  (7,  '35-053-70001', 'GRANT ML 3-1',           5, 2, 'SHUT-IN'),
  (8,  '35-015-80001', 'CADDOGW 10-1H',          6, 4, 'ACTIVE'),
  (9,  '35-073-90001', 'HUNTON EAST 5-1',        7, 4, 'ACTIVE'),
  (10, '35-121-10001', 'PITTSBURG GAS 22-1',     8, 3, 'ACTIVE'),
  (11, '35-037-11001', 'CREEK RF 4-1',           9, 2, 'PLUGGED'),
  (12, '35-011-50002', 'BLAINE CORE 18-2H',      3, 1, 'ACTIVE'),
  (13, '35-017-30003', 'STU 13-1H',              1, 1, 'ACTIVE'),
  (14, '35-049-60003', 'GARVIN WOODFORD 7-3H',   4, 2, 'ACTIVE');

-- Monthly production for 2025-06 .. 2025-09
INSERT INTO monthly_production(well_id, prod_month, oil_bbl, gas_mcf) VALUES
  -- 1 STU 12-1H (liquids-rich, modest decline)
  (1,'2025-06',820,600),(1,'2025-07',805,610),(1,'2025-08',790,620),(1,'2025-09',775,615),
  -- 2 STU 12-2H
  (2,'2025-06',680,520),(2,'2025-07',670,530),(2,'2025-08',655,540),(2,'2025-09',640,535),
  -- 3 SPRINGER SOUTH 1-9H (strong)
  (3,'2025-06',1100,1300),(3,'2025-07',1120,1280),(3,'2025-08',1085,1290),(3,'2025-09',1095,1310),
  -- 4 SPRINGER SOUTH 2-9H
  (4,'2025-06',950,1150),(4,'2025-07',940,1140),(4,'2025-08',930,1130),(4,'2025-09',920,1120),
  -- 5 BLAINE CORE 18-1H
  (5,'2025-06',760,900),(5,'2025-07',745,920),(5,'2025-08',735,910),(5,'2025-09',720,905),
  -- 6 GARVIN WOODFORD 7-2H
  (6,'2025-06',540,700),(6,'2025-07',555,710),(6,'2025-08',565,705),(6,'2025-09',575,695),
  -- 7 GRANT ML 3-1 (shut-in after June)
  (7,'2025-06',150,80),(7,'2025-07',0,0),(7,'2025-08',0,0),(7,'2025-09',0,0),
  -- 8 CADDOGW 10-1H
  (8,'2025-06',430,1200),(8,'2025-07',445,1180),(8,'2025-08',455,1195),(8,'2025-09',460,1210),
  -- 9 HUNTON EAST 5-1
  (9,'2025-06',380,500),(9,'2025-07',370,510),(9,'2025-08',365,505),(9,'2025-09',360,500),
  -- 10 PITTSBURG GAS 22-1 (gas-heavy)
  (10,'2025-06',70,1900),(10,'2025-07',75,1950),(10,'2025-08',72,1925),(10,'2025-09',74,1980),
  -- 11 CREEK RF 4-1 (plugged after June)
  (11,'2025-06',50,20),(11,'2025-07',0,0),(11,'2025-08',0,0),(11,'2025-09',0,0),
  -- 12 BLAINE CORE 18-2H
  (12,'2025-06',790,950),(12,'2025-07',780,960),(12,'2025-08',770,955),(12,'2025-09',760,945),
  -- 13 STU 13-1H
  (13,'2025-06',720,560),(13,'2025-07',730,570),(13,'2025-08',725,565),(13,'2025-09',735,575),
  -- 14 GARVIN WOODFORD 7-3H
  (14,'2025-06',520,690),(14,'2025-07',510,680),(14,'2025-08',505,675),(14,'2025-09',498,670);

INSERT INTO price_assumptions(product, usd_per_unit) VALUES
  ('OIL', 80.0),
  ('GAS', 2.50);
