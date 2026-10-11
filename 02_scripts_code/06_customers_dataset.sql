SELECT *
FROM `olist_customers_dataset`
LIMIT 100;

SELECT customer_id, count(*) as count_num
FROM `olist_customers_dataset`
GROUP BY customer_id
HAVING COUNT(*) > 1 ;

CREATE OR REPLACE VIEW vw_clean_custoners AS
SELECT distinct
	customer_id,
    customer_unique_id,
    TRIM(LOWER(customer_city)) AS customer_city,
    TRIM(UPPER(customer_state)) AS customer_state
FROM `olist_customers_dataset`
WHERE customer_id is not null
and customer_unique_id is not null
and customer_zip_code_prefix is not null
and customer_city is not null
and customer_state is not null ;