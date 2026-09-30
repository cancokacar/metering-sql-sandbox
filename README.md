# Metering SQL Sandbox

A small PostgreSQL project built around **energy metering data**: customers, market locations (MaLo), and one year of 15-minute interval readings (~175,000 rows).

I built it to get hands-on with relational databases in a realistic energy-industry context: schema design, joins, aggregations, diagnosing data quality problems, and index tuning.

## Project structure

```
metering-sql-sandbox/
├── README.md                      ← the most important file
├── docker-compose.yml             ← one command starts Postgres
├── sql/
│   ├── init/
│   │   ├── 01_schema.sql          ← CREATE TABLE statements
│   │   └── 02_seed.sql            ← sample data + the simulated gap
│   ├── 03_queries.sql             ← the 9 practice queries, commented
│   └── 04_indexes.sql             ← index + EXPLAIN ANALYZE
└── notes/
    └── explain-before-after.md    ← pasted query plans + timings
```

## What's inside

| Path | Contents |
|---|---|
| `sql/init/01_schema.sql` | Tables with primary keys, foreign keys and CHECK constraints |
| `sql/init/02_seed.sql` | Sample customers, metering points, a year of readings, and a simulated meter outage |
| `sql/03_queries.sql` | Practice queries, from simple filters to a support-style root-cause analysis |
| `sql/04_indexes.sql` | Query plan before and after adding a composite index |
| `notes/explain-before-after.md` | Measured query plans and timings |

## Data model

```
customers 1 ──── n metering_points 1 ──── n readings
(customer_id)      (malo_id, customer_id)     (malo_id, ts, kwh, status)
```

Customer data lives only in `customers`. Metering points and readings reference it by key, so a customer's move is a one-row update, not 35,000.

## How to run

### Option A: Docker (recommended)

```bash
docker compose up -d
docker compose exec db psql -U postgres -d metering
```

The scripts in `sql/init/` run automatically the first time the container starts. To reset everything and reload from scratch:

```bash
docker compose down -v
docker compose up -d
```

Then run the exercises, e.g.:

```bash
docker compose exec -T db psql -U postgres -d metering < sql/03_queries.sql
```

### Option B: Local PostgreSQL

Install PostgreSQL ([Windows/Linux](https://www.postgresql.org/download/), or [Postgres.app](https://postgresapp.com/) on macOS), then:

```sql
CREATE DATABASE metering;
\c metering
\i sql/init/01_schema.sql
\i sql/init/02_seed.sql
```

## Highlight: diagnosing a "too low" monthly bill

**Scenario:** A household customer reports that her March bill looks too low.

**Investigation:** Joining readings → metering points → customers and breaking the March values down by `status` showed <!-- TODO: fill in your actual result, e.g. "96 readings marked 'missing' with NULL kWh on 15 March" -->.

**Root cause:** `SUM()` silently ignores NULLs, so a one-day meter outage made the monthly total too low without any error.

**Fix:** <!-- TODO: in your own words: why the right fix is substitute values (Ersatzwertbildung) in the meter data, not correcting the invoice -->

## Highlight: index tuning

<!-- TODO: fill in with your own measurements from notes/explain-before-after.md -->

| | Plan | Execution time |
|---|---|---|
| Without index | Seq Scan | … ms |
| With `(malo_id, ts)` index | Index / Bitmap Index Scan | … ms |

## What I learned

<!-- TODO: 3–5 bullet points in your own words. For example:
- Why LEFT JOIN + IS NULL finds rows with no match
- Difference between WHERE and HAVING
- How NULLs behave in aggregates
- Trade-off of indexes: faster reads, slower writes, more storage
-->

## Next steps

- [ ] Add substitute values for the missing interval and re-check the monthly total
- [ ] Write a view for monthly consumption per customer
- [ ] Try partitioning `readings` by month
