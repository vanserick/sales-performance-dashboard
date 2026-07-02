/* ============================================================
   05_product_analysis.sql
   PHASE 7 — PRODUCT ANALYSIS
   Source: superstore_final
   Powers: Product Analysis dashboard page
   ============================================================ */

-- ------------------------------------------------------------
-- 1. TOP 10 PRODUCTS BY SALES
-- ------------------------------------------------------------
SELECT
    product_name,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    SUM(quantity)          AS total_quantity
FROM superstore_final
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;
-- #1 Canon imageCLASS 2200 Advanced Copier — $61,599.82 sales

-- ------------------------------------------------------------
-- 2. BOTTOM 10 PRODUCTS BY SALES
-- ------------------------------------------------------------
SELECT
    product_name,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit
FROM superstore_final
GROUP BY product_name
ORDER BY total_sales ASC
LIMIT 10;

-- ------------------------------------------------------------
-- 3. TOP CATEGORIES
-- ------------------------------------------------------------
SELECT
    category,
    ROUND(SUM(sales), 2)                              AS total_sales,
    ROUND(SUM(profit), 2)                              AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_pct
FROM superstore_final
GROUP BY category
ORDER BY total_sales DESC;
-- Technology leads sales ($836K) and profit ($145K);
-- Furniture has the weakest margin (2.5%).

-- ------------------------------------------------------------
-- 4. SUB-CATEGORY BREAKDOWN
-- ------------------------------------------------------------
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_pct
FROM superstore_final
GROUP BY category, sub_category
ORDER BY total_profit ASC;
-- Tables and Bookcases are the only two sub-categories operating at a
-- net loss (-$17,725 and -$3,473 respectively).

-- ------------------------------------------------------------
-- 5. PROFIT BY PRODUCT (top profit generators)
-- ------------------------------------------------------------
SELECT
    product_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore_final
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;
-- #1 Canon imageCLASS 2200 Advanced Copier — $25,199.93 profit

-- ------------------------------------------------------------
-- 6. LOSS-MAKING PRODUCTS
-- ------------------------------------------------------------
SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_loss,
    ROUND(AVG(discount)*100, 1) AS avg_discount_pct
FROM superstore_final
GROUP BY product_name, category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_loss ASC
LIMIT 15;
-- Worst: Cubify CubeX 3D Printer Double Head Print — -$8,879.97
-- Many loss-makers carry heavy average discounts (>25%).

-- ------------------------------------------------------------
-- 7. TREEMAP SOURCE QUERY (Category > Sub-Category > Sales & Profit)
-- ------------------------------------------------------------
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2)  AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore_final
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;

-- ------------------------------------------------------------
-- 8. TOP 10 PRODUCTS (by profit) — for bar chart
-- ------------------------------------------------------------
SELECT product_name, ROUND(SUM(profit), 2) AS total_profit
FROM superstore_final
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 9. BOTTOM 10 PRODUCTS (by profit) — for bar chart
-- ------------------------------------------------------------
SELECT product_name, ROUND(SUM(profit), 2) AS total_profit
FROM superstore_final
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;
