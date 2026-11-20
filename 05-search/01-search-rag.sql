-- Cortex Search service on vector stores (chunks/tokens of text)
USE test.public;

SELECT * FROM raw_store_more;
CREATE OR REPLACE CORTEX SEARCH SERVICE search_rag
    ON contents
    ATTRIBUTES category
    warehouse = COMPUTE_WH
    TARGET_LAG = '1 minute'
AS
    SELECT contents, category
    FROM raw_store_more;
DESC CORTEX SEARCH SERVICE search_rag;
SELECT * FROM TABLE(CORTEX_SEARCH_DATA_SCAN(SERVICE_NAME => 'search_rag'));

SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'search_rag',
    '{
        "query": "test query",
        "columns": ["contents"],
        "limit": 1
    }'
) AS json;

ALTER CORTEX SEARCH SERVICE search_rag REFRESH;
ALTER CORTEX SEARCH SERVICE search_rag SUSPEND INDEXING;
ALTER CORTEX SEARCH SERVICE search_rag RESUME SERVING;
ALTER CORTEX SEARCH SERVICE search_rag SUSPEND;
ALTER CORTEX SEARCH SERVICE search_rag SUSPEND;

DROP CORTEX SEARCH SERVICE search_rag;

-- ==============================================================

SELECT * FROM vector_store_more;
CREATE OR REPLACE CORTEX SEARCH SERVICE search_rag
    ON chunk
    ATTRIBUTES category
    warehouse = COMPUTE_WH
    TARGET_LAG = '1 minute'
AS
    SELECT chunk, chunk_index, relative_path, file_url, category
    FROM vector_store_more;

SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'search_rag',
    '{
        "query": "test query",
        "columns": ["chunk"],
        "limit": 3
    }'
) AS json;

ALTER CORTEX SEARCH SERVICE search_rag SUSPEND;
