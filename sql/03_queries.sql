-- 03_queries.sql
-- Practice queries on the metering sandbox.
-- Try each task yourself first. Solutions are further down.
-- TODO: replace each "Why:" line with your own explanation of how the query works.

-- 1. Show all customers.
SELECT * FROM customers;

-- 2. Show only household customers in Köln. (`WHERE`, `AND`)
-- Why:
SELECT * FROM customers
WHERE city = 'Köln' AND customer_type = 'household';

-- 3. Show the 10 highest single readings. (`ORDER BY ... DESC`, `LIMIT`)
-- Why:
SELECT * FROM readings
ORDER BY kwh DESC NULLS LAST
LIMIT 10;

-- 4. List each metering point together with its customer's name. (`JOIN`)
-- Why:
SELECT m.malo_id, m.energy_type, c.name
FROM metering_points m
JOIN customers c ON c.customer_id = m.customer_id;

-- 5. Find customers who have no metering point at all. (`LEFT JOIN` plus `IS NULL`)
-- Why:
SELECT c.name
FROM customers c
LEFT JOIN metering_points m ON m.customer_id = c.customer_id
WHERE m.malo_id IS NULL;

-- 6. Total consumption per metering point per month. (`GROUP BY`, `date_trunc`)
-- Why:
SELECT malo_id,
       date_trunc('month', ts) AS month,
       SUM(kwh) AS total_kwh
FROM readings
GROUP BY malo_id, month
ORDER BY malo_id, month;

-- 7. Which metering points have missing readings, and on which days? (`WHERE status = ...`, `GROUP BY`)
-- Why:
SELECT malo_id,
       ts::date AS day,
       COUNT(*) AS missing_values
FROM readings
WHERE status = 'missing'
GROUP BY malo_id, day;

-- 8. Support scenario: Familie Schneider complains her March bill looks too low. Find out why.
-- Why:
SELECT c.name,
       r.status,
       COUNT(*)   AS n_values,
       SUM(r.kwh) AS kwh
FROM readings r
JOIN metering_points m ON m.malo_id = r.malo_id
JOIN customers c       ON c.customer_id = m.customer_id
WHERE c.name = 'Familie Schneider'
  AND r.ts >= '2026-03-01' AND r.ts < '2026-04-01'
GROUP BY c.name, r.status;
-- Finding:

-- 9. Which customers used more than 60,000 kWh in total? (`HAVING`)
-- Why:
SELECT c.name, SUM(r.kwh) AS total_kwh
FROM readings r
JOIN metering_points m ON m.malo_id = r.malo_id
JOIN customers c       ON c.customer_id = m.customer_id
GROUP BY c.name
HAVING SUM(r.kwh) > 60000;
