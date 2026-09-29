-- 01_schema.sql
-- Metering data model: customers -> metering points (MaLo) -> 15-minute readings

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    city          TEXT,
    customer_type TEXT CHECK (customer_type IN ('household', 'industry'))
);

CREATE TABLE metering_points (
    malo_id       TEXT PRIMARY KEY,                           -- market location ID
    customer_id   INT REFERENCES customers(customer_id),      -- foreign key to customers
    energy_type   TEXT CHECK (energy_type IN ('power', 'gas')),
    grid_operator TEXT
);

CREATE TABLE readings (
    reading_id SERIAL PRIMARY KEY,
    malo_id    TEXT NOT NULL REFERENCES metering_points(malo_id),
    ts         TIMESTAMP NOT NULL,
    kwh        NUMERIC(10,3),
    status     TEXT DEFAULT 'valid'
);
