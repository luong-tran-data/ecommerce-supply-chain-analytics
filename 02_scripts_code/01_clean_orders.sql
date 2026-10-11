create database olist_db;
use olist_db;

CREATE TABLE IF NOT EXISTS olist_db.olist_geolocation_dataset (
    geolocation_zip_code_prefix INT,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS olist_db.product_category_name_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

USE olist_db;

-- 1. Bảng dịch tên danh mục
CREATE TABLE IF NOT EXISTS olist_db.product_category_name_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

-- 2. Bảng Đánh giá / Reviews (Xử lý chuỗi dài & xuống dòng)
CREATE TABLE IF NOT EXISTS olist_db.olist_order_reviews_dataset (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

USE olist_db;

-- Xóa dữ liệu cũ nếu có và nạp lại sạch sẽ
TRUNCATE TABLE product_category_name_translation;

INSERT INTO product_category_name_translation (product_category_name, product_category_name_english) VALUES
('beleza_saude', 'health_beauty'),
('informatica_acessorios', 'computers_accessories'),
('automotivo', 'auto'),
('cama_mesa_banho', 'bed_bath_table'),
('moveis_decoracao', 'furniture_decor'),
('esporte_lazer', 'sports_leisure'),
('perfumaria', 'perfumery'),
('utilidades_domesticas', 'housewares'),
('telefonia', 'telephony'),
('relogios_presentes', 'watches_gifts'),
('alimentos_bebidas', 'food_drink'),
('bebes', 'baby'),
('papelaria', 'stationery'),
('tablets_impressao_imagem', 'tablets_printing_image'),
('brinquedos', 'toys'),
('telefonia_fixa', 'fixed_telephony'),
('ferramentas_jardim', 'garden_tools'),
('fashion_bolsas_e_acessorios', 'fashion_bags_accessories'),
('eletrodomesticos', 'housewares'),
('consoles_games', 'consoles_games');

SET GLOBAL local_infile = 1;

USE olist_db;

LOAD DATA LOCAL INFILE '/Users/itswillhoney/Documents/Data analytics/olist_db/olist_db/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM olist_orders_dataset
LIMIT 10;

DATEDIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date)) -- DATE() để rút gọn chỉ lấy phần Ngày của cả 2 cột trước khi trừ, tránh trường hợp bị lệch vài tiếng khiến đơn hàng bị tính trễ hạn sai nha!

SELECT * 
FROM olist_db.olist_order_items_dataset 
WHERE order_item_id > 1 
LIMIT 10;
COUNT(DISTINCT order_id) -- Vì một order_id có thể xuất hiện nhiều lần (mỗi dòng là 1 món hàng order_item_id), nên:




SELECT *
FROM `olist_products_dataset`
LIMIT 10;

SELECT *
FROM `olist_order_reviews_dataset`
LIMIT 10;

-- step 0 CREATE OR REPLACE (bảo vệ dataset gốc)
-- step 1 Lọc trùng lặp - Đánh số dòng để phát hiện trùng lặp order_id (nếu có)
-- step 2: Ép kiểu dữ liệu và lấy phần Ngày (DATE)



CREATE OR REPLACE VIEW vw_clean_orders AS 
WITH ranked_orders AS (
	SELECT
		order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date, -- PARTITION BY order_id Ví dụ: Tất cả những ai mang mã Đơn_101 đứng chung một chỗ)
        order_estimated_delivery_date,  -- Bác bảo vệ bảo tiếp: "Trong từng nhóm, ai bấm đặt hàng MỚI NHẤT thì đứng lên ĐẦU HÀNG, ai trùng/cũ hơn đứng lùi về sau!
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_purchase_timestamp DESC) AS row_num -- tạo cột mới để dán nhãn 1,2,3
    FROM olist_orders_dataset
)
SELECT
	order_id,
    customer_id,
    order_status,

-- Bước 2: Ép kiểu dữ liệu và lấy phần Ngày (DATE)
    DATE(order_purchase_timestamp) AS purchase_date,
    DATE(order_delivered_customer_date) AS actual_delivery_date,
    DATE(order_estimated_delivery_date) AS estimated_delivery_date,
    
    -- Tính toán thêm các chỉ số phụ vụ phân tích Logistics
    DATEDIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp)) AS actual_delivery_days,
    DATEDIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date)) AS delay_days
FROM ranked_orders
WHERE row_num = 1 -- Bước 1: Chỉ lấy dòng không trùng lặp
  AND order_status = 'delivered' -- Bước 3: Lọc lấy các đơn hoàn thành
  AND order_delivered_customer_date IS NOT NULL -- Bước 3: Loại bỏ dòng bị NULL ngày giao
  AND order_delivered_customer_date >= order_purchase_timestamp; -- Bước 3: Loại bỏ lỗi logic ngày 

SELECT * FROM vw_clean_orders;
























