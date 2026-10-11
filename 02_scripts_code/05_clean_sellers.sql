SELECT * 
FROM `olist_sellers_dataset` 
LIMIT 100;

SELECT seller_id, COUNT(*) AS count_num
FROM `olist_sellers_dataset`
GROUP BY seller_id
HAVING COUNT(*) > 1 ;

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