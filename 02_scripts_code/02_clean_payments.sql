USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_order_payments_dataset (
    order_id VARCHAR(255),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

-- 2. Raw Data Ingestion (Using local infile)
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Clean Payments View Creation
-- Data Cleaning Rules:
-- 1. Filter out invalid/undefined payment types ('not_defined')
-- 2. Exclude transactions with zero or negative amounts (payment_value > 0)
-- 3. Exclude invalid installments (payment_installments >= 1)
-- 4. Aggregate multiple payment splits to order-level totals

CREATE OR REPLACE VIEW vw_clean_payments AS
SELECT 
    order_id,
    COUNT(payment_sequential) AS payment_splits_count,
    GROUP_CONCAT(DISTINCT payment_type ORDER BY payment_type SEPARATOR ', ') AS payment_methods,
    MAX(payment_installments) AS max_installments,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM olist_order_payments_dataset
WHERE payment_type != 'not_defined'
  AND payment_value > 0
  AND payment_installments >= 1
GROUP BY order_id;

-- Data Validation & Integrity Checks
-- 1. Preview aggregated order payments
SELECT * 
FROM vw_clean_payments 
LIMIT 10;

-- 2. Verify total revenue and volume by payment method
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_value), 2) AS avg_transaction_value
FROM olist_order_payments_dataset
WHERE payment_type != 'not_defined' 
  AND payment_value > 0
GROUP BY payment_type
ORDER BY total_revenue DESC;
