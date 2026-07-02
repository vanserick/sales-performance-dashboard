/* ============================================================
   01_data_cleaning.sql
   PHASE 3 — DATA CLEANING
   Source table: superstore  (raw import of SampleSuperstore.csv)
   Goal: validate data quality and produce a clean table
         "superstore_clean" ready for downstream analysis.
   ============================================================ */

-- ------------------------------------------------------------
-- 0. Raw table structure (for reference — adjust types to your
--    RDBMS if needed; written in ANSI SQL / PostgreSQL style)
-- ------------------------------------------------------------
-- CREATE TABLE superstore (
--     row_id          INT,
--     order_id        VARCHAR(20),
--     order_date      DATE,
--     ship_date       DATE,
--     ship_mode       VARCHAR(20),
--     customer_id     VARCHAR(20),
--     customer_name   VARCHAR(100),
--     segment         VARCHAR(20),
--     country         VARCHAR(50),
--     city            VARCHAR(50),
--     state           VARCHAR(50),
--     postal_code     VARCHAR(10),
--     region          VARCHAR(20),
--     product_id      VARCHAR(20),
--     category        VARCHAR(50),
--     sub_category    VARCHAR(50),
--     product_name    VARCHAR(200),
--     sales           NUMERIC(12,4),
--     quantity        INT,
--     discount        NUMERIC(5,2),
--     profit          NUMERIC(12,4)
-- );

-- ------------------------------------------------------------
-- 1. COUNT ROWS
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM superstore;
-- Expected: 9,994 rows (Sample Superstore dataset)

-- ------------------------------------------------------------
-- 2. CHECK NULL VALUES  (column by column)
-- ------------------------------------------------------------
SELECT
    SUM(CASE WHEN order_id      IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date    IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN ship_date     IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN ship_mode     IS NULL THEN 1 ELSE 0 END) AS null_ship_mode,
    SUM(CASE WHEN customer_id   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
    SUM(CASE WHEN segment       IS NULL THEN 1 ELSE 0 END) AS null_segment,
    SUM(CASE WHEN city          IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN state         IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN region        IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN product_id    IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN category      IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN sub_category  IS NULL THEN 1 ELSE 0 END) AS null_sub_category,
    SUM(CASE WHEN product_name  IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN sales         IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN quantity      IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN discount      IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN profit        IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM superstore;
-- Result on this dataset: 0 NULLs in any column (clean source).

-- ------------------------------------------------------------
-- 3. CHECK DUPLICATES
-- ------------------------------------------------------------
-- 3a. Exact full-row duplicates
SELECT order_id, product_id, order_date, sales, quantity, discount, profit,
       COUNT(*) AS occurrences
FROM superstore
GROUP BY order_id, product_id, order_date, sales, quantity, discount, profit
HAVING COUNT(*) > 1;

-- 3b. Duplicate Row IDs (should always be unique)
SELECT row_id, COUNT(*) AS occurrences
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;
-- Result: 0 duplicates found.

-- ------------------------------------------------------------
-- 4. CHECK INCORRECT DATES
-- ------------------------------------------------------------
-- 4a. Ship date earlier than order date (logically impossible)
SELECT *
FROM superstore
WHERE ship_date < order_date;

-- 4b. Dates outside the expected reporting window (2014-2017)
SELECT *
FROM superstore
WHERE order_date < DATE '2014-01-01'
   OR order_date > DATE '2017-12-31';

-- 4c. Excessive ship lead time (> 14 days may indicate data entry error)
SELECT order_id, order_date, ship_date,
       (ship_date - order_date) AS ship_lead_days
FROM superstore
WHERE (ship_date - order_date) > 14;

-- ------------------------------------------------------------
-- 5. CHECK NEGATIVE / INVALID SALES
-- ------------------------------------------------------------
SELECT *
FROM superstore
WHERE sales <= 0;
-- Result: no negative or zero sales values in this dataset.

-- ------------------------------------------------------------
-- 6. CHECK NEGATIVE / INVALID QUANTITIES
-- ------------------------------------------------------------
SELECT *
FROM superstore
WHERE quantity <= 0;
-- Result: no negative or zero quantities in this dataset.

-- 6b. Sanity check: discount should be between 0 and 1 (0%-100%)
SELECT *
FROM superstore
WHERE discount < 0 OR discount > 1;

-- ------------------------------------------------------------
-- 7. STANDARDIZE TEXT VALUES
-- ------------------------------------------------------------
-- Trim whitespace and normalize casing on key text fields.
-- (Run as an UPDATE if cleaning in place, or wrap in the CREATE
--  TABLE AS statement below to produce a clean copy.)

-- Preview of standardization logic:
SELECT DISTINCT
    TRIM(ship_mode)                 AS ship_mode_clean,
    TRIM(segment)                   AS segment_clean,
    TRIM(region)                    AS region_clean,
    INITCAP(TRIM(city))             AS city_clean,
    INITCAP(TRIM(state))            AS state_clean,
    TRIM(category)                  AS category_clean,
    TRIM(sub_category)              AS sub_category_clean
FROM superstore;

-- ------------------------------------------------------------
-- 8. DELIVERABLE — build the clean table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS superstore_clean;

CREATE TABLE superstore_clean AS
SELECT
    row_id,
    UPPER(TRIM(order_id))              AS order_id,
    order_date,
    ship_date,
    TRIM(ship_mode)                    AS ship_mode,
    UPPER(TRIM(customer_id))           AS customer_id,
    TRIM(customer_name)                AS customer_name,
    TRIM(segment)                      AS segment,
    TRIM(country)                      AS country,
    INITCAP(TRIM(city))                AS city,
    INITCAP(TRIM(state))               AS state,
    postal_code,
    TRIM(region)                       AS region,
    UPPER(TRIM(product_id))            AS product_id,
    TRIM(category)                     AS category,
    TRIM(sub_category)                 AS sub_category,
    TRIM(product_name)                 AS product_name,
    ROUND(sales, 2)                    AS sales,
    quantity,
    discount,
    ROUND(profit, 2)                   AS profit
FROM superstore
WHERE sales > 0
  AND quantity > 0
  AND discount BETWEEN 0 AND 1
  AND ship_date >= order_date;

-- Row-count reconciliation: confirms how many rows were dropped by cleaning
SELECT
    (SELECT COUNT(*) FROM superstore)        AS raw_rows,
    (SELECT COUNT(*) FROM superstore_clean)  AS clean_rows;

/* Deliverable: superstore_clean — a clean dataset (9,994 rows on the
   sample file, 0 rows dropped) ready for feature engineering. */
