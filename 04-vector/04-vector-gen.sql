-- VECTOR Generation
use test.public;

-- ~SNOWFLAKE.CORTEX.EMBED_TEXT_768/1024(...) --> 768/1024 dims
SELECT 'This is a wonderful day indeed!' AS txt,
    AI_EMBED('snowflake-arctic-embed-l-v2.0', txt) AS v,
    SYSTEM$TYPEOF(v),
    ARRAY_SIZE(v::ARRAY);

SELECT AI_EMBED(
        'snowflake-arctic-embed-m-v1.5',
        'This is a wonderful day indeed!') AS v,
    VECTOR_NORMALIZE(VECTOR_TRUNCATE(v, 256));

-- for image
SELECT AI_EMBED(
    'voyage-multimodal-3',
    TO_FILE('@stage1', 'spool/inspection.png')) AS v;

SELECT 'This is a wonderful day indeed!' AS txt,
    AI_MULTI_EMBED('snowflake-arctic-embed-l-v2.0', txt) AS v,
    SYSTEM$TYPEOF(v),
    ARRAY_SIZE(v::ARRAY);

-- for image
SELECT AI_MULTI_EMBED(
    'twelvelabs-marengo-embed-3-0',
    TO_FILE('@stage1', 'spool/inspection.png')) AS v;

-- for video/audio
SELECT AI_MULTI_EMBED(
    'twelvelabs-marengo-embed-3-0',
    TO_FILE('@stage1', 'spool/test.mp4')) AS v;

-- ================================================================
-- legacy (may not work in some accounts)

SELECT 'This is a wonderful day indeed!' AS txt,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768(
        'snowflake-arctic-embed-m-v1.5', txt) AS v,
    SYSTEM$TYPEOF(v),
    ARRAY_SIZE(TO_ARRAY(v));

SELECT 'This is a wonderful day indeed!' AS txt,
    SNOWFLAKE.CORTEX.EMBED_TEXT_1024(
        'snowflake-arctic-embed-l-v2.0', txt) AS v,
    SYSTEM$TYPEOF(v),
    ARRAY_SIZE(v::ARRAY);

