-- Data Cleaning & Preparation: Customers Master Data
-- Target Table: olist_customers_dataset
-- Target View:  vw_clean_customers

USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_customers_dataset (
    customer_id VARCHAR(255),
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(255),
    customer_state VARCHAR(10)
);

-- 2. Raw Data Ingestion
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Data Integrity & Anomaly Checks

-- Verify customer_id uniqueness (check duplicate records)
SELECT 
    customer_id, 
    COUNT(*) AS duplicate_count
FROM olist_customers_dataset
GROUP BY customer_id
HAVING duplicate_count > 1;

-- Clean Customers View Creation
-- Cleaning Rules:
-- 1. Standardize text casing (lowercase city, uppercase state)
-- 2. Trim whitespace
-- 3. Filter out records missing primary identifiers or location attributes

CREATE OR REPLACE VIEW vw_clean_customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    TRIM(LOWER(customer_city)) AS customer_city,
    TRIM(UPPER(customer_state)) AS customer_state
FROM olist_customers_dataset
WHERE customer_id IS NOT NULL
  AND customer_unique_id IS NOT NULL
  AND customer_zip_code_prefix IS NOT NULL
  AND customer_city IS NOT NULL
  AND customer_state IS NOT NULL;

-- Data Validation Checks

-- Preview clean customers output
SELECT * 
FROM vw_clean_customers 
LIMIT 10;

-- Top states by unique customer concentration
SELECT 
    customer_state, 
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM vw_clean_customers
GROUP BY customer_state
ORDER BY total_unique_customers DESC;
