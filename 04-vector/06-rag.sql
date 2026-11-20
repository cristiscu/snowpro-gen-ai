-- Basic RAG Architecture in Snowflake
USE test.public;

-- AI_PARSE_DOCUMENT (OCR mode)
CREATE OR REPLACE TABLE raw_store
AS SELECT RELATIVE_PATH,
    AI_PARSE_DOCUMENT(
		TO_FILE('@stage1', RELATIVE_PATH)
        ):content::STRING AS content
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH LIKE 'spool/reviews/%.pdf';
select * from raw_store;

-- SPLIT_TEXT_RECURSIVE_CHARACTER --> chunks + AI_EMBED
CREATE OR REPLACE TABLE vector_store
AS SELECT RELATIVE_PATH,
    c.value::TEXT AS chunk,
    c.INDEX::INTEGER as chunk_index,
	AI_EMBED('e5-base-v2', chunk) as chunk_embedding
from raw_store, LATERAL FLATTEN(
    input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
        content, 'none', 30, 10)) c;
select * from vector_store;

-- AI_EMBED(question) + VECTOR_COSINE_SIMILARITY to get closest embedding
SELECT chunk, VECTOR_COSINE_SIMILARITY(chunk_embedding,
    AI_EMBED('e5-base-v2', 'reported problems')) as dist
FROM vector_store
ORDER BY dist DESC
LIMIT 1;

-- AI_COMPLETE with returned closest embedding
SELECT AI_COMPLETE('mistral-7b',
    'There have been some problems reported by my customers at Here We Go? '
    || 'plusieurs problèmes de');
