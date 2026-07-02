/* ============================================================
   09_business_recommendations.sql
   PHASE 11 — EXECUTIVE RECOMMENDATIONS
   Source: superstore_final
   Includes: shipping-mode profitability + the finding/recommendation
             pairs summarized on the "Business Recommendations" page.
   ============================================================ */

-- ------------------------------------------------------------
-- SHIPPING ANALYSIS — which ship mode is most profitable?
-- ------------------------------------------------------------
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                           AS orders,
    ROUND(SUM(sales), 2)                                AS total_sales,
    ROUND(SUM(profit), 2)                                AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)  AS profit_margin_pct
FROM superstore_final
GROUP BY ship_mode
ORDER BY profit_margin_pct DESC;
-- Result:
--   First Class     margin 13.93%  (most profitable per dollar of sales)
--   Second Class    margin 12.51%
--   Same Day        margin 12.38%
--   Standard Class  margin 12.08%  (generates the most total profit in
--                                   absolute dollars because of its volume)

-- ============================================================
-- FINDING / RECOMMENDATION SUMMARY
-- Each block below is a query that quantifies one finding used in the
-- Executive Recommendations page. Numbers reflect the Sample Superstore
-- dataset (2014-2017).
-- ============================================================

-- FINDING 1: Furniture has strong sales but weak profit.
SELECT category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100, 2) AS margin_pct
FROM superstore_final
WHERE category = 'Furniture'
GROUP BY category;
-- Furniture: $741,999.80 sales but only $18,451.27 profit (2.49% margin) —
-- the weakest margin of the three categories despite being the 2nd-largest
-- by revenue.
-- RECOMMENDATION: Review Furniture pricing/cost structure, particularly
-- Tables and Bookcases (both net-loss sub-categories). Renegotiate supplier
-- costs or reduce blanket discounting on this category.

-- FINDING 2: California generates the highest revenue.
SELECT state, ROUND(SUM(sales),2) AS total_sales, ROUND(SUM(profit),2) AS total_profit
FROM superstore_final
WHERE state = 'California'
GROUP BY state;
-- California: $457,687.63 sales — the single highest-revenue state,
-- roughly 20% of total company sales.
-- RECOMMENDATION: Prioritize California in inventory planning and
-- regional marketing spend; consider a West-region fulfillment hub to
-- reduce delivery times and support further growth.

-- FINDING 3: Large discounts reduce profit.
SELECT
    ROUND(SUM(CASE WHEN discount > 0.2 THEN profit ELSE 0 END), 2) AS profit_lost_over_20pct_discount,
    COUNT(CASE WHEN discount > 0.2 THEN 1 END) AS lines_over_20pct
FROM superstore_final;
-- Line items discounted above 20% collectively LOSE $135,376.06,
-- across 1,393 line items — discounting above this threshold is
-- systematically unprofitable.
-- RECOMMENDATION: Cap standard discounts at 20% except for approved
-- clearance/bulk-order exceptions; require manager approval above that
-- threshold.

-- FINDING 4: Technology has the highest margins.
SELECT category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100, 2) AS margin_pct
FROM superstore_final
WHERE category = 'Technology'
GROUP BY category;
-- Technology: 17.40% margin, the highest of the three categories, and also
-- the largest category by both sales ($836,154) and profit ($145,455).
-- RECOMMENDATION: Increase advertising/promotional budget behind
-- Technology (especially Copiers and Accessories, its most profitable
-- sub-categories) to compound an already-strong return.

-- FINDING 5: Standard Class shipping drives most profit dollars, but
-- First Class is the most efficient per sales dollar.
SELECT ship_mode,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2) AS margin_pct
FROM superstore_final
GROUP BY ship_mode
ORDER BY margin_pct DESC;
-- RECOMMENDATION: Investigate why Standard Class (68% of sales volume)
-- runs ~1.9pp lower margin than First Class — likely tied to slower-moving,
-- heavier-discounted SKUs shipping Standard. Test shifting high-margin
-- SKUs toward First/Second Class promotion.

-- ------------------------------------------------------------
-- SUMMARY TABLE — Top 5 Findings, Recommendations & Expected Impact
-- (for direct use on the Business Recommendations dashboard page)
-- ------------------------------------------------------------
-- | # | Finding                                            | Recommendation                                  | Expected Impact                          |
-- |---|-----------------------------------------------------|--------------------------------------------------|-------------------------------------------|
-- | 1 | Furniture: $742K sales, only 2.49% margin            | Review Furniture pricing & discount policy        | Recover a meaningful share of the ~$21K   |
-- |   | (Tables & Bookcases are net-loss sub-categories)     |                                                    | currently lost in Tables/Bookcases        |
-- | 2 | California is the top revenue state ($458K, ~20%)   | Prioritize CA inventory & West-region fulfillment | Support continued growth in top market    |
-- | 3 | Discounts >20% lose $135K across 1,393 line items    | Cap standard discounts at 20%                     | Protect up to $135K in annual profit      |
-- | 4 | Technology has the best margin (17.4%) & profit      | Increase Technology advertising budget            | Compound growth in the highest-ROI segment|
-- | 5 | Standard Class ships 68% of sales at the lowest      | Audit Standard Class discount/cost mix            | Close ~1.9pp margin gap vs First Class    |
--     margin (12.08%) of all ship modes
