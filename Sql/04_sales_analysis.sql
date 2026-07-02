/* ============================================================
   04_sales_analysis.sql
   PHASE 6 — SALES ANALYSIS
   Source: superstore_final
   Powers: "Sales Trends" / Sales Analysis dashboard page
   ============================================================ */

-- ------------------------------------------------------------
-- 1. MONTHLY SALES (calendar month/year)
-- ------------------------------------------------------------
SELECT
    order_year,
    order_month,
    TO_CHAR(order_date, 'Mon YYYY')  AS month_label,
    ROUND(SUM(sales), 2)             AS monthly_sales
FROM superstore_final
GROUP BY order_year, order_month, TO_CHAR(order_date, 'Mon YYYY')
ORDER BY order_year, order_month;

-- ------------------------------------------------------------
-- 2. MONTHLY PROFIT
-- ------------------------------------------------------------
SELECT
    order_year,
    order_month,
    TO_CHAR(order_date, 'Mon YYYY')  AS month_label,
    ROUND(SUM(profit), 2)            AS monthly_profit
FROM superstore_final
GROUP BY order_year, order_month, TO_CHAR(order_date, 'Mon YYYY')
ORDER BY order_year, order_month;

-- ------------------------------------------------------------
-- 3. QUARTERLY SALES
-- ------------------------------------------------------------
SELECT
    order_year,
    order_quarter,
    ROUND(SUM(sales), 2)   AS quarterly_sales,
    ROUND(SUM(profit), 2)  AS quarterly_profit
FROM superstore_final
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;

-- ------------------------------------------------------------
-- 4. BEST MONTH (highest sales, across whole date range)
-- ------------------------------------------------------------
SELECT
    TO_CHAR(order_date, 'Mon YYYY') AS month_label,
    ROUND(SUM(sales), 2)            AS monthly_sales
FROM superstore_final
GROUP BY TO_CHAR(order_date, 'Mon YYYY'), order_year, order_month
ORDER BY monthly_sales DESC
LIMIT 1;
-- Result: November 2017 — $118,447.83 (highest single month, driven by
-- Black Friday / holiday season promotions)

-- ------------------------------------------------------------
-- 5. WORST MONTH (lowest sales)
-- ------------------------------------------------------------
SELECT
    TO_CHAR(order_date, 'Mon YYYY') AS month_label,
    ROUND(SUM(sales), 2)            AS monthly_sales
FROM superstore_final
GROUP BY TO_CHAR(order_date, 'Mon YYYY'), order_year, order_month
ORDER BY monthly_sales ASC
LIMIT 1;
-- Result: February 2014 — $4,519.89 (lowest single month)

-- ------------------------------------------------------------
-- 6. YEAR-OVER-YEAR GROWTH
-- ------------------------------------------------------------
WITH yearly AS (
    SELECT order_year, SUM(sales) AS yearly_sales
    FROM superstore_final
    GROUP BY order_year
)
SELECT
    order_year,
    ROUND(yearly_sales, 2) AS yearly_sales,
    ROUND(
        (yearly_sales - LAG(yearly_sales) OVER (ORDER BY order_year))
        / NULLIF(LAG(yearly_sales) OVER (ORDER BY order_year), 0) * 100
    , 2) AS yoy_growth_pct
FROM yearly
ORDER BY order_year;
-- Result: 2015 -2.83% | 2016 +29.47% | 2017 +20.36%
-- Revenue IS growing overall (2014→2017 CAGR positive), despite a dip in 2015.

-- ------------------------------------------------------------
-- 7. RUNNING TOTAL SALES (cumulative, for a running-total line chart)
-- ------------------------------------------------------------
SELECT
    order_year,
    order_month,
    TO_CHAR(order_date, 'Mon YYYY') AS month_label,
    ROUND(SUM(sales), 2)            AS monthly_sales,
    ROUND(SUM(SUM(sales)) OVER (ORDER BY order_year, order_month), 2) AS running_total_sales
FROM superstore_final
GROUP BY order_year, order_month, TO_CHAR(order_date, 'Mon YYYY')
ORDER BY order_year, order_month;
