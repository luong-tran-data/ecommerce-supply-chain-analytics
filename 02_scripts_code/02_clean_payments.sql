USE olist_db;

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
