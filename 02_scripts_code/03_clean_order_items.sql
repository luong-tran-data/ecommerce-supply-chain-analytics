
-- Data Cleaning & Preparation: Order Items
-- Target Table: olist_order_items_dataset
-- Target View:  vw_clean_order_items

USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_order_items_dataset (
    order_id VARCHAR(255),
    order_item_id INT,
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2)
);

-- 2. Raw Data Ingestion
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Data Integrity & Anomaly Checks

-- Verify composite primary key uniqueness (order_id + order_item_id)
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
