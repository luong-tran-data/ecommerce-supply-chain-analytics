-- Fulfillment Funnel & Logistics OTIF Analytics
-- Metrics: Total Delivered, On-Time (OTIF), Delayed, CSAT Rate
-- Target Database: olist_db

USE olist_db;

WITH funnel_base AS (
    SELECT
        o.order_id,
        o.order_status,
        o.purchase_date,
        o.actual_delivery_date,
        o.estimated_delivery_date,
        o.delay_days,
        r.review_score
    FROM vw_clean_orders o
    LEFT JOIN vw_clean_order_reviews r
        ON o.order_id = r.order_id
)
SELECT
    -- 1. Total Delivered Orders
    COUNT(DISTINCT order_id) AS total_delivered_orders,

    -- 2. On-Time / Early Fulfillment Volume (delay_days <= 0)
    COUNT(DISTINCT CASE 
        WHEN delay_days <= 0 THEN order_id 
    END) AS on_time_orders,

    -- 3. Delayed Fulfillment Volume (delay_days > 0)
    COUNT(DISTINCT CASE 
        WHEN delay_days > 0 THEN order_id 
    END) AS delayed_orders,

    -- 4. Customer Satisfaction Volume (Review Score >= 4)
    COUNT(DISTINCT CASE 
        WHEN review_score >= 4 THEN order_id 
    END) AS satisfied_orders,

    -- Fulfillment Performance Rates (%)

    -- On-Time In-Full (OTIF) Rate (%)
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN delay_days <= 0 THEN order_id END)
        / COUNT(DISTINCT order_id), 
        2
    ) AS otif_rate_pct,

    -- Order Delay Rate (%)
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN delay_days > 0 THEN order_id END)
        / COUNT(DISTINCT order_id), 
        2
    ) AS delay_rate_pct,

    -- Customer Satisfaction (CSAT) Rate (%) among reviewed orders
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN review_score >= 4 THEN order_id END)
        / NULLIF(COUNT(DISTINCT CASE WHEN review_score IS NOT NULL THEN order_id END), 0), 
        2
    ) AS csat_rate_pct

FROM funnel_base;
