/* ============================================================
   07_geographic_analysis.sql
   PHASE 9 — GEOGRAPHIC ANALYSIS
   Source: superstore_final
   Powers: Regional Analysis dashboard page (incl. map)
   ============================================================ */

-- ------------------------------------------------------------
-- 1. SALES BY REGION
-- ------------------------------------------------------------
SELECT
    region,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100, 2) AS profit_margin_pct
FROM superstore_final
GROUP BY region
ORDER BY total_sales DESC;
-- West leads sales ($725,458) and profit ($108,418);
-- Central has the lowest margin among the four regions.

-- ------------------------------------------------------------
-- 2. PROFIT BY REGION (ranked)
-- ------------------------------------------------------------
SELECT
    region,
    ROUND(SUM(profit), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM superstore_final
GROUP BY region;

-- ------------------------------------------------------------
-- 3. SALES BY STATE
-- ------------------------------------------------------------
SELECT
    state,
    region,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit
FROM superstore_final
GROUP BY state, region
ORDER BY total_sales DESC;
-- #1 California — $457,687.63 | #2 New York — $310,876.27

-- ------------------------------------------------------------
-- 4. TOP 10 CITIES BY SALES
-- ------------------------------------------------------------
SELECT
    city,
    state,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit
FROM superstore_final
GROUP BY city, state
ORDER BY total_sales DESC
LIMIT 10;
-- #1 New York City — $256,368.16

-- ------------------------------------------------------------
-- 5. WORST 10 CITIES BY PROFIT (biggest losses)
-- ------------------------------------------------------------
SELECT
    city,
    state,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit
FROM superstore_final
GROUP BY city, state
ORDER BY total_profit ASC
LIMIT 10;
-- Worst: Philadelphia, PA — -$13,837.77 (despite healthy sales volume,
-- driven by deep discounting)

-- ------------------------------------------------------------
-- 6. MAP VISUALIZATION SOURCE (state-level, lat/long joined in Power BI
--    via built-in "State" geography role — no lat/long needed if using
--    Power BI's Bing-powered map with the State field bound to Location)
-- ------------------------------------------------------------
SELECT
    state,
    region,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(SUM(profit), 2)    AS total_profit,
    SUM(quantity)             AS total_quantity,
    COUNT(DISTINCT order_id)  AS total_orders
FROM superstore_final
GROUP BY state, region
ORDER BY total_sales DESC;
