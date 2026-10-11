USE olist_db;

SELECT 
    order_id, 
    order_item_id, 
    COUNT(*) AS duplicate_count
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING duplicate_count > 1;

-- Check for pricing and freight anomalies (negative or missing values)
SELECT *
FROM olist_order_items_dataset
WHERE price <= 0 
   OR price IS NULL
   OR freight_value < 0 
   OR freight_value IS NULL;

-- Clean Order Items View Creation
-- Cleaning Rules:
-- 1. Enforce positive item prices (price > 0)
-- 2. Ensure freight values are non-negative and not null
-- 3. Standardize shipping limit timestamp to DATE

CREATE OR REPLACE VIEW vw_clean_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    DATE(shipping_limit_date) AS shipping_limit_date,
    price,
    freight_value,
    ROUND(price + freight_value, 2) AS total_item_value
FROM olist_order_items_dataset
WHERE price > 0 
  AND price IS NOT NULL
  AND freight_value >= 0 
  AND freight_value IS NOT NULL;

-- Validation Checks

-- Preview cleaned items view
SELECT * 
FROM vw_clean_order_items 
LIMIT 10;
