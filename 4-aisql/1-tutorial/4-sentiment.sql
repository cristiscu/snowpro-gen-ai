-- https://docs.snowflake.com/en/sql-reference/functions/sentiment-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.SENTIMENT('A tourist\'s delight, in low urban light,
  Recommended gem, a pizza night sight. Swift arrival, a pleasure so right,
  Yet, pockets felt lighter, a slight pricey bite. 💰🍕🚀');

SELECT SNOWFLAKE.CORTEX.SENTIMENT(review_content), review_content FROM reviews LIMIT 10;