-- https://docs.snowflake.com/en/sql-reference/functions/summarize-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.SUMMARIZE(review_content) FROM reviews LIMIT 10;
