SELECT 
    -- 1. Tổng doanh thu sản phẩm (GMV)
   ROUND(SUM(i.price),2) AS total_gmv,
    
    -- 2. Tổng số đơn hàng (chỉ tính các đơn có phát sinh mặt hàng)
   COUNT(DISTINCT(o.order_id)) AS total_orders,
    
    -- 3. Số lượng khách hàng thực tế (Unique Customers)
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,
    
    -- 4. Giá trị trung bình trên mỗi đơn hàng (AOV - Average Order Value)
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM `vw_clean_orders` o
JOIN `vw_clean_order_items` i ON o.order_id = i.order_id
JOIN `vw_clean_custoners` c ON o.customer_id = c.customer_id;

-- Top 10 Ngành hàng (Category) mang lại doanh thu khủng nhất
SELECT 
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category_name,
    COUNT(i.order_item_id) AS total_units_sold,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM `vw_clean_order_items` i
JOIN `vw_clean_products` p ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY category_name -- 1
ORDER BY total_revenue DESC
LIMIT 10;

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_revenue,
    -- Tính tỷ lệ phần trăm đóng góp doanh thu (% Revenue Share)
    ROUND(SUM(i.price) * 100.0 / SUM(SUM(i.price)) OVER(), 2) AS revenue_share_pct
FROM `vw_clean_orders` o
JOIN `vw_clean_order_items` i ON o.order_id = i.order_id
JOIN `vw_clean_custoners` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;












