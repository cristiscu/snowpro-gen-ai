-- VECTOR Similarity
use test.public;

SELECT 'This is a wonderful day indeed!' AS a,
    'It is sunny and it does not rain.' AS b,
    AI_SIMILARITY(a, b);

SELECT a, b,
    VECTOR_COSINE_SIMILARITY(a, b) AS cosine, 
    VECTOR_INNER_PRODUCT(a, b) AS inner, 
    VECTOR_L1_DISTANCE(a, b) AS l1, 
    VECTOR_L2_DISTANCE(a, b) AS l2
FROM vectors;
