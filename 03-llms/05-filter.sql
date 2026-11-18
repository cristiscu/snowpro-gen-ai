-- AI_FILTER
use test.public;

-- returns TRUE/FALSE
SELECT AI_FILTER('Is Canada in North America?');

-- qualifies reviews
WITH cte AS (
    SELECT 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'Mediocre food and mediocre service.')
SELECT review, AI_FILTER('This was a nice review: ' || review) AS nice
FROM cte;

-- alternative with PROMPT
WITH cte AS (
    SELECT 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'Mediocre food and mediocre service.')
SELECT review, AI_FILTER(PROMPT('This was a nice review {0}', review)) AS nice
FROM cte;

-- AI_FILTER in WHERE
SELECT RELATIVE_PATH,
    TO_FILE('@stage1', RELATIVE_PATH) AS f
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.png'
    AND AI_FILTER('Is this an inspection?', f);
