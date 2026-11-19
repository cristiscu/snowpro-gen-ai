-- VECTOR Similarity
use test.public;

-- similar text?
SELECT 'This is a wonderful day indeed!' AS a,
    'It is sunny and it does not rain.' AS b,
    AI_SIMILARITY(a, b);

-- similar images?
SELECT TO_FILE('@stage1', 'spool/inspection.png') AS a,
    TO_FILE('@stage1', 'spool/inspection.png') AS b,
    AI_SIMILARITY(a, b, {'model': 'voyage-multimodal-3'});

-- on vectors
SELECT * FROM vectors;

SELECT a, b,
    VECTOR_COSINE_SIMILARITY(a, b) AS cosine, 
    VECTOR_INNER_PRODUCT(a, b) AS inner, 
    VECTOR_L1_DISTANCE(a, b) AS l1, 
    VECTOR_L2_DISTANCE(a, b) AS l2
FROM vectors;
