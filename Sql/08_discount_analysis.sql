/* ============================================================
   08_discount_analysis.sql
   PHASE 10 — DISCOUNT ANALYSIS
   Source: superstore_final
   Powers: Discount Analysis dashboard page
   ============================================================ */

-- ------------------------------------------------------------
-- 1. DISCOUNT BANDS vs SALES & PROFIT
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN discount = 0                       THEN '0% (No Discount)'
        WHEN discount > 0    AND discount <= 0.1 THEN '0-10%'
        WHEN discount > 0.1  AND discount <= 0.2 THEN '10-20%'
        WHEN discount > 0.2  AND discount <= 0.3 THEN '20-30%'
        WHEN discount > 0.3  AND discount <= 0.5 THEN '30-50%'
        WHEN discount > 0.5                       THEN '50%+'
    END AS discount_band,
    COUNT(*)                     AS line_items,
    ROUND(SUM(sales), 2)         AS total_sales,
    ROUND(AVG(sales), 2)         AS avg_sales_per_line,
    ROUND(SUM(profit), 2)        AS total_profit,
    ROUND(AVG(profit), 2)        AS avg_profit_per_line
FROM superstore_final
GROUP BY 1
ORDER BY MIN(discount);
-- Sales per line item does NOT consistently increase with discount depth.
-- Profit turns NEGATIVE once discount exceeds ~20%.

-- ------------------------------------------------------------
-- 2. DISCOUNT vs PROFIT — CORRELATION-STYLE SUMMARY
-- ------------------------------------------------------------
SELECT
    ROUND(AVG(discount), 4)                                   AS avg_discount,
    ROUND(SUM(profit), 2)                                     AS total_profit,
    ROUND(SUM(CASE WHEN discount = 0 THEN profit ELSE 0 END), 2)      AS profit_no_discount,
    ROUND(SUM(CASE WHEN discount > 0.2 THEN profit ELSE 0 END), 2)    AS profit_discount_over_20pct
FROM superstore_final;
-- Orders with >20% discount are collectively LOSS-MAKING overall,
-- while full-price (0% discount) orders generate the bulk of total profit.

-- ------------------------------------------------------------
-- 3. DISCOUNT vs SALES (does discount move volume?)
-- ------------------------------------------------------------
SELECT
    discount_band,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(SUM(total_sales) / SUM(line_items), 2) AS avg_sales_per_line
FROM (
    SELECT
        CASE
            WHEN discount = 0                       THEN '0% (No Discount)'
            WHEN discount > 0    AND discount <= 0.1 THEN '0-10%'
            WHEN discount > 0.1  AND discount <= 0.2 THEN '10-20%'
            WHEN discount > 0.2  AND discount <= 0.3 THEN '20-30%'
            WHEN discount > 0.3  AND discount <= 0.5 THEN '30-50%'
            WHEN discount > 0.5                       THEN '50%+'
        END AS discount_band,
        sales AS total_sales,
        1 AS line_items
    FROM superstore_final
) t
GROUP BY discount_band;
-- Roughly half of total sales dollars occur at 0% discount already —
-- deep discounts are NOT the primary driver of sales volume in this data.

-- ------------------------------------------------------------
-- 4. AVERAGE DISCOUNT (overall and by category)
-- ------------------------------------------------------------
SELECT ROUND(AVG(discount) * 100, 2) AS avg_discount_pct_overall
FROM superstore_final;

SELECT
    category,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
    ROUND(SUM(profit), 2)         AS total_profit
FROM superstore_final
GROUP BY category
ORDER BY avg_discount_pct DESC;

-- ------------------------------------------------------------
-- 5. PRODUCTS WITH HIGHEST AVERAGE DISCOUNT
-- ------------------------------------------------------------
SELECT
    product_name,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(sales), 2)          AS total_sales,
    ROUND(SUM(profit), 2)         AS total_profit
FROM superstore_final
GROUP BY product_name
HAVING COUNT(*) >= 3        -- exclude one-off outliers
ORDER BY avg_discount_pct DESC
LIMIT 15;

-- ------------------------------------------------------------
-- 6. LOSS AFTER DISCOUNT (orders that were profitable pre-discount logic
--    but ended up as losses — i.e. all currently loss-making, discounted lines)
-- ------------------------------------------------------------
SELECT
    sub_category,
    COUNT(*)                       AS discounted_loss_lines,
    ROUND(AVG(discount) * 100, 1)  AS avg_discount_pct,
    ROUND(SUM(profit), 2)          AS total_loss
FROM superstore_final
WHERE discount > 0
  AND profit < 0
GROUP BY sub_category
ORDER BY total_loss ASC;
-- Tables and Bookcases again dominate the discount-driven loss list.

-- ------------------------------------------------------------
-- 7. RECOMMENDATION-SUPPORTING QUERY: profit impact of capping discount at 20%
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(CASE WHEN discount > 0.2 THEN profit ELSE 0 END), 2) AS profit_lost_to_deep_discounts,
    COUNT(CASE WHEN discount > 0.2 THEN 1 END)                     AS lines_over_20pct_discount
FROM superstore_final;
-- Capping discounts at 20% would directly protect this amount of profit
-- currently being given away on the highest-discount transactions.
