USE olist_db;
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
