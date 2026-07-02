/* ============================================================
   03_kpi_queries.sql
   PHASE 5 — KPI QUERIES
   Source: superstore_final
   Goal: single-value KPIs to power Power BI cards
         (Executive Overview page).
   ============================================================ */

-- ------------------------------------------------------------
-- 1. TOTAL SALES
-- ------------------------------------------------------------
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM superstore_final;
-- ≈ $2,297,200.86

-- ------------------------------------------------------------
-- 2. TOTAL PROFIT
-- ------------------------------------------------------------
SELECT ROUND(SUM(profit), 2) AS total_profit
FROM superstore_final;
-- ≈ $286,397.02

-- ------------------------------------------------------------
-- 3. TOTAL ORDERS  (distinct orders, not line items)
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM superstore_final;
-- = 5,009

-- ------------------------------------------------------------
-- 4. TOTAL CUSTOMERS
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM superstore_final;
-- = 793

-- ------------------------------------------------------------
-- 5. TOTAL QUANTITY SOLD
-- ------------------------------------------------------------
SELECT SUM(quantity) AS total_quantity
FROM superstore_final;
-- = 37,873 units

-- ------------------------------------------------------------
-- 6. AVERAGE ORDER VALUE (AOV)
-- ------------------------------------------------------------
SELECT ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM superstore_final;
-- ≈ $458.61

-- ------------------------------------------------------------
-- 7. AVERAGE DISCOUNT
-- ------------------------------------------------------------
SELECT ROUND(AVG(discount) * 100, 2) AS avg_discount_pct
FROM superstore_final;
-- ≈ 15.62%

-- ------------------------------------------------------------
-- 8. PROFIT MARGIN %
-- ------------------------------------------------------------
SELECT ROUND( (SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct
FROM superstore_final;
-- ≈ 12.47%

-- ------------------------------------------------------------
-- ALL KPIs IN ONE ROW (for a single Power BI DAX / card table)
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(sales), 2)                                        AS total_sales,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    COUNT(DISTINCT order_id)                                    AS total_orders,
    COUNT(DISTINCT customer_id)                                 AS total_customers,
    SUM(quantity)                                                AS total_quantity,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)             AS avg_order_value,
    ROUND(AVG(discount) * 100, 2)                                AS avg_discount_pct,
    ROUND( (SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)       AS profit_margin_pct
FROM superstore_final;
