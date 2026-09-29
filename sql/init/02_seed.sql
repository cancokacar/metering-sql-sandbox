-- 02_seed.sql
-- Sample data: 5 customers, 5 metering points, one year of 15-minute readings

INSERT INTO customers (name, city, customer_type) VALUES
  ('Stadtbäckerei Müller', 'Köln',       'industry'),
  ('Familie Schneider',    'Aachen',     'household'),
  ('Rheinstahl GmbH',      'Düsseldorf', 'industry'),
  ('Familie Yilmaz',       'Köln',       'household'),
  ('Neukunde Weber',       'Bonn',       'household');   -- deliberately has no metering point

INSERT INTO metering_points (malo_id, customer_id, energy_type, grid_operator) VALUES
  ('50000000001', 1, 'power', 'RheinNetz'),
  ('50000000002', 1, 'gas',   'RheinNetz'),
  ('50000000003', 2, 'power', 'Regionetz'),
  ('50000000004', 3, 'power', 'Netz Düsseldorf'),
  ('50000000005', 4, 'power', 'RheinNetz');

-- One year of 15-minute values per metering point (~175,000 rows)
INSERT INTO readings (malo_id, ts, kwh)
SELECT m.malo_id, t, round((random() * 2)::numeric, 3)
FROM metering_points m,
     generate_series('2026-01-01 00:00'::timestamp,
                     '2026-12-31 23:45'::timestamp,
                     interval '15 minutes') AS t;

-- Simulate a data gap: meter 50000000003 failed on 15 March
UPDATE readings
SET kwh = NULL, status = 'missing'
WHERE malo_id = '50000000003'
  AND ts::date = '2026-03-15';

ANALYZE;
