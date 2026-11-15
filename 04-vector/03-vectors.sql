SELECT 'This is a wonderful day indeed!' AS txt,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m-v1.5', txt) AS f,
    SYSTEM$TYPEOF(f),
    ARRAY_SIZE(TO_ARRAY(f));

SELECT 'This is a wonderful day indeed!' AS txt,
    SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', txt) AS f,
    SYSTEM$TYPEOF(f),
    ARRAY_SIZE(f::ARRAY);

SELECT 'This is a wonderful day indeed!' AS txt,
    AI_EMBED('snowflake-arctic-embed-l-v2.0', txt) AS f,
    SYSTEM$TYPEOF(f),
    ARRAY_SIZE(f::ARRAY);
