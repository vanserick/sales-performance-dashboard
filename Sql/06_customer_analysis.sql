/* ============================================================
   06_customer_analysis.sql
   PHASE 8 — CUSTOMER ANALYSIS
   Source: superstore_final
   Powers: Customer Analysis dashboard page
   ============================================================ */

-- ------------------------------------------------------------
-- 1. TOP 10 CUSTOMERS BY SALES
-- ------------------------------------------------------------
SELECT
    customer_name,
    segment,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    COUNT(DISTINCT order_id) AS orders
FROM superstore_final
GROUP BY customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;
-- #1 Sean Miller — $25,043.05 lifetime sales

-- ------------------------------------------------------------
-- 2. AVERAGE CUSTOMER SPENDING
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS avg_customer_spending
FROM superstore_final;
-- ≈ $2,896.85 per customer over the full period

-- ------------------------------------------------------------
-- 3. CUSTOMER RANKING (window function, all customers ranked by sales)
-- ------------------------------------------------------------
SELECT
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM superstore_final
GROUP BY customer_name
ORDER BY sales_rank;

-- ------------------------------------------------------------
-- 4. CUSTOMER SEGMENTS (Segment field: Consumer / Corporate / Home Office)
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(DISTINCT customer_id)                         AS customers,
    ROUND(SUM(sales), 2)                                AS total_sales,
    ROUND(SUM(profit), 2)                                AS total_profit,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100, 2)       AS profit_margin_pct
FROM superstore_final
GROUP BY segment
ORDER BY total_sales DESC;
-- Consumer segment is largest by sales ($1.16M, 409 customers) and profit.

-- 4b. Customer VALUE segment (Low/Medium/High/VIP, built in feature engineering)
SELECT
    customer_value_segment,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(sales), 2)        AS total_sales,
    ROUND(AVG(sales), 2)        AS avg_line_sales
FROM superstore_final
GROUP BY customer_value_segment
ORDER BY total_sales DESC;

-- ------------------------------------------------------------
-- 5. REPEAT CUSTOMERS
-- ------------------------------------------------------------
WITH order_counts AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS num_orders
    FROM superstore_final
    GROUP BY customer_id
)
SELECT
    COUNT(*) FILTER (WHERE num_orders > 1)             AS repeat_customers,
    COUNT(*)                                            AS total_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE num_orders > 1) / COUNT(*), 1) AS repeat_rate_pct
FROM order_counts;
-- Result: 781 of 793 customers (98.5%) placed more than one order —
-- an extremely high repeat-purchase rate.

-- ------------------------------------------------------------
-- 6. CUSTOMER LIFETIME VALUE (approximation)
--    CLV ≈ average order value × avg orders per customer × avg profit margin
--    Here computed directly as cumulative historical profit per customer,
--    which is the simplest defensible CLV proxy for a static dataset.
-- ------------------------------------------------------------
SELECT
    customer_name,
    COUNT(DISTINCT order_id)                              AS total_orders,
    ROUND(SUM(sales), 2)                                  AS lifetime_sales,
    ROUND(SUM(profit), 2)                                 AS lifetime_profit_clv,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)       AS avg_order_value
FROM superstore_final
GROUP BY customer_name
ORDER BY lifetime_profit_clv DESC
LIMIT 10;
