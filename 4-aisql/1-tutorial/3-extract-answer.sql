-- https://docs.snowflake.com/en/sql-reference/functions/extract_answer-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(review_content,
    'What dishes does this review mention?')
FROM reviews LIMIT 10;