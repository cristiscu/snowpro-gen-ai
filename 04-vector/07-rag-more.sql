-- Basic RAG Architecture in Snowflake (with more AI stuff)
USE test.public;

-- AI_PARSE_DOCUMENT (OCR mode) + AI_SENTIMENT + AI_CLASSIFY + AI_TRANSLATE
CREATE OR REPLACE TEMP TABLE raw_text
AS SELECT RELATIVE_PATH, SIZE, FILE_URL,
	BUILD_SCOPED_FILE_URL(@stage1, RELATIVE_PATH) AS url,
    AI_PARSE_DOCUMENT(TO_FILE('@stage1', RELATIVE_PATH)
        ):content::STRING AS content,
    AI_SENTIMENT(content
        ):categories[0].sentiment::STRING AS mood,
    AI_CLASSIFY(content, ['English', 'French']
        )['labels'][0]::STRING AS category,
    IFF(category = 'English', content,
        AI_TRANSLATE(content, 'fr', 'en')) AS translation
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH LIKE 'spool/reviews/%.pdf';
select * from raw_text;

-- SPLIT_TEXT_RECURSIVE_CHARACTER --> chunks + AI_EMBED
CREATE OR REPLACE TABLE vector_store_more
AS SELECT relative_path, size, file_url, url, category,
    c.value::TEXT AS chunk,
    c.INDEX::INTEGER as chunk_index,
	AI_EMBED('e5-base-v2', chunk) as chunk_embedding
from raw_text, LATERAL FLATTEN(
    input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
        translation, 'none', 30, 10)) c;
select * from vector_store_more;

-- AI_EMBED(question) + VECTOR_COSINE_SIMILARITY to get closest embedding
SELECT chunk, VECTOR_COSINE_SIMILARITY(chunk_embedding,
    AI_EMBED('e5-base-v2', 'reported problems')) as dist
FROM vector_store_more
WHERE category = 'English'
ORDER BY dist DESC
LIMIT 1;

-- similarity compared directly
SELECT AI_SIMILARITY('reported problems', 'several navigation problems,');

-- AI_COMPLETE with returned closest embedding
SELECT AI_COMPLETE('mistral-7b',
    'There have been some problems reported by my customers at Here We Go? '
    || 'several navigation problems,');
