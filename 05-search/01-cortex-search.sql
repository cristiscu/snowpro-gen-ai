-- Build a RAG-based LLM assistant using Streamlit and Snowflake Cortex Search (inspired from)
-- https://quickstarts.snowflake.com/guide/ask_questions_to_your_own_documents_with_snowflake_cortex_search/index.html
USE test.public;

-- create Cortex Search service
create or replace cortex search service search_more
    ON chunk
    ATTRIBUTES category
    warehouse = COMPUTE_WH
    TARGET_LAG = '1 minute'
AS (select chunk, chunk_index, relative_path, file_url, category
    from vector_store_more);

DESC CORTEX SEARCH SERVICE search_more;

SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'search_more',
    '{ "query":"test query", "columns":["chunk"], "limit":3 }'
);
