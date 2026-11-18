-- AI Aggregations
use test.public;

SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION;

-- AI_AGG (on string list)
SELECT AI_AGG(
    '[ALGERIA, ARGENTINA, BRAZIL, CANADA, CHINA]',
    'Which of these countries are in North America?'
) AS response;

-- bad (with AI_COMPLETE)
SELECT AI_COMPLETE(
    'mistral-7b',
    'Which of these countries are in North America? [ALGERIA, ARGENTINA, BRAZIL, CANADA, CHINA]'
) AS response;

-- AI_AGG (on aggregated table values)
SELECT AI_AGG(
    N_NAME,
    'Which of these countries are in North America?') AS response
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION;

-- bad (with AI_COMPLETE)
SELECT N_NAME, AI_COMPLETE(
    'mistral-7b',
    'Which of these countries are in North America?' || N_NAME) AS response
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
LIMIT 5;

-- ==============================================================
-- AI_SUMMARIZE_AGG

-- on aggregated table values
WITH cte AS (
    SELECT 'Holly Molly' AS restaurant, 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Sandokan', 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'Holly Molly', 'It was great, but the service was meh.'
    UNION ALL SELECT 'La Plaza', 'Mediocre food and mediocre service'
    UNION ALL SELECT 'La Plaza', 'Terrible quality ingredients, I should have eaten at home.'
    UNION ALL SELECT 'Holly Molly', 'Bad restaurant, I would avoid this place.')
SELECT restaurant, AI_SUMMARIZE_AGG(review) AS summary
FROM cte
GROUP BY 1;

-- bad (with AI_SUMMARIZE)
WITH cte AS (
    SELECT 'Holly Molly' AS restaurant, 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Sandokan', 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'Holly Molly', 'It was great, but the service was meh.'
    UNION ALL SELECT 'La Plaza', 'Mediocre food and mediocre service'
    UNION ALL SELECT 'La Plaza', 'Terrible quality ingredients, I should have eaten at home.'
    UNION ALL SELECT 'Holly Molly', 'Bad restaurant, I would avoid this place.'),
sums AS (
    SELECT restaurant, LISTAGG(review, '|') AS reviews
    FROM cte
    GROUP BY 1)
SELECT restaurant, AI_SUMMARIZE(reviews) AS summary
FROM sums;

