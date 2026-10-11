
-- Data Cleaning & Preparation: Sellers Master Data
-- Target Table: olist_sellers_dataset
-- Target View:  vw_clean_sellers

USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_sellers_dataset (
    seller_id VARCHAR(255),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(255),
    seller_state VARCHAR(10)
);

-- 2. Raw Data Ingestion
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- Data Integrity & Anomaly Checks

-- Verify seller_id uniqueness (check duplicate records)
SELECT 
    seller_id, 
    COUNT(*) AS duplicate_count
FROM olist_sellers_dataset
GROUP BY seller_id
HAVING duplicate_count > 1;

-- Clean Sellers View Creation
-- Cleaning Rules:
-- 1. Standardize geographic text casing (lowercase city, uppercase state)
-- 2. Trim unnecessary leading/trailing whitespace
-- 3. Filter out records with null key attributes

CREATE OR REPLACE VIEW vw_clean_sellers AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    TRIM(LOWER(seller_city)) AS seller_city,
    TRIM(UPPER(seller_state)) AS seller_state
FROM olist_sellers_dataset
WHERE seller_id IS NOT NULL
  AND seller_zip_code_prefix IS NOT NULL
  AND seller_city IS NOT NULL
  AND seller_state IS NOT NULL;
-- Validation Checks

-- Preview clean sellers output
SELECT * 
FROM vw_clean_sellers 
LIMIT 10;

-- Distribution of sellers across states
SELECT 
    seller_state, 
    COUNT(*) AS total_sellers
FROM vw_clean_sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;
