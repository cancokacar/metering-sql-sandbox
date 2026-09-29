# Index tuning: before and after

Query: all readings for metering point `50000000003` in March 2026.

## Without index

```
-- paste EXPLAIN ANALYZE output here
```

Execution time: … ms

## With index on `(malo_id, ts)`

```
-- paste EXPLAIN ANALYZE output here
```

Execution time: … ms

## What changed and why

<!-- TODO: in your own words: Seq Scan vs. index scan, why the column order (malo_id, ts) matters, and what the index costs -->
