USE olist_db;
SELECT 
    customer_id, 
    COUNT(*) AS duplicate_count
FROM olist_customers_dataset
GROUP BY customer_id
HAVING duplicate_count > 1;

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
