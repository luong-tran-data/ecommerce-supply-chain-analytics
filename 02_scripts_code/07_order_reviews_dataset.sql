-- Data Cleaning & Preparation: Order Reviews
-- Target Table: olist_order_reviews_dataset
-- Target View:  vw_clean_order_reviews

USE olist_db;

-- 1. Table Schema Setup
CREATE TABLE IF NOT EXISTS olist_db.olist_order_reviews_dataset (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- 2. Raw Data Ingestion
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '01_raw_data/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Clean Reviews View Creation
-- Cleaning Rules:
-- 1. Deduplicate reviews per order: select the latest review per order_id using ROW_NUMBER()
-- 2. Validate review score range (between 1 and 5)
-- 3. Standardize timestamps to DATE
-- 4. Clean text fields (trim spaces and handle empty review comments)

CREATE OR REPLACE VIEW vw_clean_order_reviews AS
WITH ranked_reviews AS (
    SELECT 
        review_id,
        order_id,
        review_score,
        TRIM(review_comment_title) AS review_comment_title,
        TRIM(review_comment_message) AS review_comment_message,
        DATE(review_creation_date) AS review_creation_date,
        DATE(review_answer_timestamp) AS review_answer_date,
        -- Deduplicate: pick the most recent review if multiple exist for a single order
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY review_answer_timestamp DESC, review_creation_date DESC
        ) AS rank_num
    FROM olist_order_reviews_dataset
    WHERE review_score BETWEEN 1 AND 5
)
SELECT
    review_id,
    order_id,
    review_score,
    NULLIF(review_comment_title, '') AS review_comment_title,
    NULLIF(review_comment_message, '') AS review_comment_message,
    review_creation_date,
    review_answer_date
FROM ranked_reviews
WHERE rank_num = 1;

-- Data Validation Checks

-- Preview clean reviews output
SELECT * 
FROM vw_clean_order_reviews 
LIMIT 10;

-- Review score distribution summary
SELECT 
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vw_clean_order_reviews), 2) AS pct_share
FROM vw_clean_order_reviews
GROUP BY review_score
ORDER BY review_score DESC;
