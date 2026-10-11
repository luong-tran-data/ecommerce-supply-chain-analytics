
-- Data Cleaning & Preparation: Products Catalog
-- Target Table: olist_products_dataset
-- Target View:  vw_clean_products

USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_products_dataset (
    product_id VARCHAR(255),
    product_category_name VARCHAR(255),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10, 2),
    product_length_cm DECIMAL(10, 2),
    product_height_cm DECIMAL(10, 2),
    product_width_cm DECIMAL(10, 2)
);

-- 2. Raw Data Ingestion
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Data Integrity & Anomaly Checks

-- Check for primary key duplicate records
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

-- Clean Products View Creation
-- Data Cleaning Rules:
-- 1. Standardize category names with English translations via LEFT JOIN
-- 2. Impute null/empty category names with 'unknown'
-- 3. Replace invalid physical dimensions (<= 0) with NULL without dropping rows

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
