-- https://docs.snowflake.com/en/sql-reference/functions/embed_text-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m-v1.5', 'hello world');

-- https://docs.snowflake.com/en/sql-reference/functions/embed_text_1024-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 'hello world');

SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 'hola mundo');

-- https://docs.snowflake.com/en/sql-reference/functions/ai_embed

SELECT AI_EMBED('snowflake-arctic-embed-l-v2.0', 'hello world');

SELECT AI_EMBED('voyage-multimodal-3',
        TO_FILE ('@my_images', 'CITY_WALKING1.PNG'));