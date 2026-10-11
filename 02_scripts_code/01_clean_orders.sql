-- Database Initialization & Schema Setup

CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;

-- 1. Geolocation Table
CREATE TABLE IF NOT EXISTS olist_db.olist_geolocation_dataset (
    geolocation_zip_code_prefix INT,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(10)
);

-- 2. Category Name Translation Table
CREATE TABLE IF NOT EXISTS olist_db.product_category_name_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

-- 3. Customer Reviews Table
CREATE TABLE IF NOT EXISTS olist_db.olist_order_reviews_dataset (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- Data Seeding: Category Name Translations

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

-- Raw Data Ingestion

SET GLOBAL local_infile = 1;

-- Ingest customer reviews dataset
LOAD DATA LOCAL INFILE '01_raw_data/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Clean Orders View Creation (Deduplication & Logistics Metrics)

CREATE OR REPLACE VIEW vw_clean_orders AS
WITH ranked_orders AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        -- Deduplicate records by ranking latest purchase timestamps per order
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY order_purchase_timestamp DESC
        ) AS row_num
    FROM olist_orders_dataset
)
SELECT 
    order_id,
    customer_id,
    order_status,
    -- Standardize timestamp fields to DATE
    DATE(order_purchase_timestamp) AS purchase_date,
    DATE(order_delivered_customer_date) AS actual_delivery_date,
    DATE(order_estimated_delivery_date) AS estimated_delivery_date,
    -- Logistics KPIs: actual lead time & estimated variance (delay days)
    DATEDIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp)) AS actual_delivery_days,
    DATEDIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date)) AS delay_days
FROM ranked_orders
WHERE row_num = 1
  -- Retain completed deliveries with valid delivery dates
  AND order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;

-- Verify cleaned view output
SELECT * FROM vw_clean_orders LIMIT 10;
