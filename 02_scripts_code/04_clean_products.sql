USE olist_db;

SELECT 
    product_id, 
    COUNT(*) AS duplicate_count
FROM olist_products_dataset
GROUP BY product_id
HAVING duplicate_count > 1;

-- Check distribution of product categories
SELECT 
    product_category_name, 
    COUNT(*) AS total_skus
FROM olist_products_dataset
GROUP BY product_category_name
ORDER BY total_skus DESC;

-- Identify dimension/weight anomalies (negative, zero, or null values)
SELECT *
FROM olist_products_dataset
WHERE product_photos_qty < 0 OR product_photos_qty IS NULL
   OR product_weight_g <= 0 OR product_weight_g IS NULL
   OR product_length_cm <= 0 OR product_length_cm IS NULL
   OR product_height_cm <= 0 OR product_height_cm IS NULL
   OR product_width_cm <= 0 OR product_width_cm IS NULL;

CREATE OR REPLACE VIEW vw_clean_products AS
SELECT
    p.product_id,
    -- Map English translation; fallback to original category or 'unknown'
    COALESCE(
        NULLIF(TRIM(t.product_category_name_english), ''),
        NULLIF(TRIM(p.product_category_name), ''),
        'unknown'
    ) AS product_category_name,
    p.product_photos_qty,
    -- Convert non-positive dimensions and weights to NULL
    NULLIF(p.product_weight_g, 0) AS product_weight_g,
    NULLIF(p.product_length_cm, 0) AS product_length_cm,
    NULLIF(p.product_height_cm, 0) AS product_height_cm,
    NULLIF(p.product_width_cm, 0) AS product_width_cm
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

-- Data Validation Checks
-- Preview clean products view output
SELECT * 
FROM vw_clean_products 
LIMIT 10;
