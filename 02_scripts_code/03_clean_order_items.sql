SELECT * 
FROM olist_order_items_dataset 
LIMIT 100;

SELECT order_id, order_item_id, count(*) -- không lỗi duplicate
FROM olist_order_items_dataset 
GROUP BY order_id, order_item_id
having count(*) >1;

SELECT *
FROM olist_order_items_dataset 
WHERE price <= 0 
	OR price IS NULL
	OR freight_value < 0 
    OR freight_value  IS NULL
;

CREATE OR REPLACE VIEW vw_clean_order_items AS
SELECT 
	order_id,
    order_item_id,
    product_id,
    seller_id,
    DATE(shipping_limit_date) AS shipping_limit_date,
    price,
    freight_value
FROM olist_order_items_dataset ;

SELECT *
FROM olist_order_items_dataset ;







