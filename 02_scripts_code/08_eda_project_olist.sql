-- Exploratory Data Analysis (EDA): Business & Supply Chain Metrics
-- Target Database: olist_db

USE olist_db;

-- 1. Executive Summary KPIs: GMV, Orders, Customers, AOV

SELECT 
    -- Total Gross Merchandise Value (GMV)
    ROUND(SUM(i.price), 2) AS total_gmv,
    
    -- Total distinct fulfilled orders
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    -- Total distinct customer base
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,
    
    -- Average Order Value (AOV)
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM vw_clean_orders o
JOIN vw_clean_order_items i ON o.order_id = i.order_id
JOIN vw_clean_customers c ON o.customer_id = c.customer_id;

-- 2. Top 10 Product Categories by Revenue Contribution

SELECT 
    p.product_category_name AS category_name,
    COUNT(i.order_item_id) AS total_units_sold,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM vw_clean_order_items i
JOIN vw_clean_products p ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Regional Revenue Distribution & Market Share by State

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue,
    -- Calculate regional revenue contribution percentage
    ROUND(SUM(i.price) * 100.0 / SUM(SUM(i.price)) OVER (), 2) AS revenue_share_pct
FROM vw_clean_orders o
JOIN vw_clean_order_items i ON o.order_id = i.order_id
JOIN vw_clean_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;
