-- 04_indexes.sql
-- Compare the query plan before and after adding a composite index.
-- Copy both EXPLAIN ANALYZE outputs into notes/explain-before-after.md.

DROP INDEX IF EXISTS idx_readings_malo_ts;

-- Before: expect a Seq Scan over the whole table
EXPLAIN ANALYZE
SELECT * FROM readings
WHERE malo_id = '50000000003'
  AND ts BETWEEN '2026-03-01' AND '2026-03-31';

-- Add an index on the columns we filter by
CREATE INDEX idx_readings_malo_ts ON readings (malo_id, ts);
ANALYZE readings;

-- After: expect an Index Scan or Bitmap Index Scan
EXPLAIN ANALYZE
SELECT * FROM readings
WHERE malo_id = '50000000003'
  AND ts BETWEEN '2026-03-01' AND '2026-03-31';
