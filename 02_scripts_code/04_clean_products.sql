SELECT *
FROM `olist_products_dataset`
LIMIT 100 ;

SELECT product_id, COUNT(*) -- khong loi
FROM `olist_products_dataset`
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT product_category_name, count(*)
FROM `olist_products_dataset`
GROUP BY  product_category_name
ORDER BY product_category_name;

SELECT 
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_products_dataset as p -- quy định tên p
LEFT JOIN product_category_name_translation as t -- quy định tên t
       ON p.product_category_name = t.product_category_name;
       
SELECT *
FROM   `olist_products_dataset`
WHERE product_photos_qty < 0 OR product_photos_qty IS NULL
	OR product_weight_g <= 0 OR product_weight_g IS NULL -- 4 product 0g
    OR product_length_cm <= 0 OR product_length_cm IS NULL
    OR product_height_cm <= 0 OR product_height_cm IS NULL
    OR product_width_cm <= 0 OR product_width_cm IS NULL;
	
CREATE OR REPLACE VIEW vw_clean_products AS
SELECT 
    product_id,
    -- 1. Chuẩn hóa danh mục: Rỗng/NULL -> 'unknown'
    COALESCE(
        NULLIF(TRIM(product_category_name), ''), 
        'unknown'
    ) AS product_category_name,
    
    product_photos_qty,
    
    -- 2. Chuyển số 0 hoặc số âm về NULL (không xóa dòng)
    NULLIF(product_weight_g, 0) AS product_weight_g,
    NULLIF(product_length_cm, 0) AS product_length_cm,
    NULLIF(product_height_cm, 0) AS product_height_cm,
    NULLIF(product_width_cm, 0) AS product_width_cm
FROM olist_products_dataset;      
       
       
       
       
       