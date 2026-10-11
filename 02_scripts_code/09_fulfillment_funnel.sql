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
    LEFT JOIN olist_order_reviews_dataset r 
        ON o.order_id = r.order_id
)
SELECT 
    -- 1. Tổng số đơn hàng thành công (Delivered Orders)
    COUNT(DISTINCT order_id) AS total_delivered_orders,
    
    -- 2. Số đơn giao đúng hạn hoặc sớm hơn dự kiến (On-Time / OTIF Orders)
    COUNT(DISTINCT CASE 
        WHEN delay_days <= 0 THEN order_id 
    END) AS on_time_orders,
    
    -- 3. Số đơn bị trễ hạn (Delayed Orders)
    COUNT(DISTINCT CASE 
        WHEN delay_days > 0 THEN order_id 
    END) AS delayed_orders,
    
    -- 4. Số đơn hàng đạt điểm đánh giá cao (Review >= 4 sao)
    COUNT(DISTINCT CASE 
        WHEN review_score >= 4 THEN order_id 
    END) AS satisfied_orders,

    -- CALCULATE METRICS & RATES (%)
    -- Tỷ lệ giao hàng đúng hạn (OTIF Rate %)
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN delay_days <= 0 THEN order_id END) 
          / COUNT(DISTINCT order_id), 2) AS otif_rate_pct,
          
    -- Tỷ lệ đơn hàng bị trễ (Delay Rate %)
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN delay_days > 0 THEN order_id END) 
          / COUNT(DISTINCT order_id), 2) AS delay_rate_pct,

    -- Tỷ lệ khách hàng hài lòng (CSAT Rate %)
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN review_score >= 4 THEN order_id END) 
          / NULLIF(COUNT(DISTINCT CASE WHEN review_score IS NOT NULL THEN order_id END), 0), 2) AS csat_rate_pct

FROM funnel_base;