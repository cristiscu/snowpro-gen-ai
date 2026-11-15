CREATE OR REPLACE TABLE vectors(a VECTOR(INT, 3), b VECTOR(INT, 3))
AS SELECT [1, 2, 3]::VECTOR(INT, 3), [1, 1, 1]::VECTOR(INT, 3)
UNION SELECT [1 ,2, 3]::VECTOR(INT, 3), [4, 6, 8]::VECTOR(INT, 3);

SELECT a, b,
    VECTOR_COSINE_SIMILARITY(a, b) AS cosine, 
    VECTOR_INNER_PRODUCT(a, b) AS inner, 
    VECTOR_L1_DISTANCE(a, b) AS l1, 
    VECTOR_L2_DISTANCE(a, b) AS l2
FROM vectors;

SELECT
    'This is a wonderful day indeed!' AS a,
    'It is sunny and it does not rain.' AS b,
    AI_SIMILARITY(a, b);
