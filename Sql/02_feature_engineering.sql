/* ============================================================
   02_feature_engineering.sql
   PHASE 4 — FEATURE ENGINEERING
   Source: superstore_clean
   Goal: add business-friendly columns for reporting and build
         the final analytical table "superstore_features".
   ============================================================ */

DROP TABLE IF EXISTS superstore_features;

CREATE TABLE superstore_features AS
SELECT
    s.*,

    -- ---------------------------------------------------------
    -- DATE FEATURES
    -- ---------------------------------------------------------
    EXTRACT(YEAR  FROM order_date)                         AS order_year,
    EXTRACT(MONTH FROM order_date)                         AS order_month,
    TO_CHAR(order_date, 'Month')                           AS order_month_name,
    EXTRACT(QUARTER FROM order_date)                       AS order_quarter,
    TO_CHAR(order_date, 'Day')                             AS order_weekday,
    (ship_date - order_date)                               AS shipping_delay_days,

    -- ---------------------------------------------------------
    -- PROFITABILITY FEATURES
    -- ---------------------------------------------------------
    ROUND( (profit / NULLIF(sales, 0)) * 100 , 2)          AS profit_margin_pct,

    -- ---------------------------------------------------------
    -- SALES BAND
    --   Low       : < $50
    --   Medium    : $50 - $199.99
    --   High      : $200 - $499.99
    --   Premium   : >= $500
    -- ---------------------------------------------------------
    CASE
        WHEN sales < 50                     THEN 'Low'
        WHEN sales >= 50  AND sales < 200    THEN 'Medium'
        WHEN sales >= 200 AND sales < 500    THEN 'High'
        WHEN sales >= 500                    THEN 'Premium'
    END                                                     AS sales_band,

    -- ---------------------------------------------------------
    -- PROFIT BAND
    --   Loss           : profit < 0
    --   Low Profit     : $0 - $24.99
    --   Medium Profit  : $25 - $99.99
    --   High Profit    : >= $100
    -- ---------------------------------------------------------
    CASE
        WHEN profit < 0                        THEN 'Loss'
        WHEN profit >= 0   AND profit < 25      THEN 'Low Profit'
        WHEN profit >= 25  AND profit < 100     THEN 'Medium Profit'
        WHEN profit >= 100                      THEN 'High Profit'
    END                                                     AS profit_band

FROM superstore_clean s;

-- ------------------------------------------------------------
-- CUSTOMER SEGMENT (based on total lifetime sales per customer)
--   Low Value    : < $1,000
--   Medium Value : $1,000 - $4,999
--   High Value   : $5,000 - $14,999
--   VIP          : >= $15,000
-- ------------------------------------------------------------
DROP TABLE IF EXISTS customer_value_segment;

CREATE TABLE customer_value_segment AS
SELECT
    customer_id,
    customer_name,
    SUM(sales)   AS lifetime_sales,
    SUM(profit)  AS lifetime_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    CASE
        WHEN SUM(sales) < 1000                          THEN 'Low Value'
        WHEN SUM(sales) >= 1000  AND SUM(sales) < 5000    THEN 'Medium Value'
        WHEN SUM(sales) >= 5000  AND SUM(sales) < 15000   THEN 'High Value'
        WHEN SUM(sales) >= 15000                          THEN 'VIP'
    END AS customer_value_segment
FROM superstore_features
GROUP BY customer_id, customer_name;

-- Attach customer_value_segment back onto the fact table
DROP TABLE IF EXISTS superstore_final;

CREATE TABLE superstore_final AS
SELECT
    f.*,
    c.customer_value_segment,
    c.lifetime_sales   AS customer_lifetime_sales,
    c.lifetime_profit  AS customer_lifetime_profit
FROM superstore_features f
LEFT JOIN customer_value_segment c
       ON f.customer_id = c.customer_id;

-- ------------------------------------------------------------
-- Quick validation
-- ------------------------------------------------------------
SELECT sales_band, COUNT(*) FROM superstore_final GROUP BY sales_band;
SELECT profit_band, COUNT(*) FROM superstore_final GROUP BY profit_band;
SELECT customer_value_segment, COUNT(DISTINCT customer_id)
FROM superstore_final GROUP BY customer_value_segment;

/* Deliverable: superstore_final — business-friendly columns
   (order_year, order_month, order_quarter, order_weekday,
   profit_margin_pct, sales_band, profit_band,
   customer_value_segment) ready for Power BI. */
