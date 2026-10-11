USE olist_db;
SELECT 
    seller_id, 
    COUNT(*) AS duplicate_count
FROM olist_sellers_dataset
GROUP BY seller_id
HAVING duplicate_count > 1;

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
