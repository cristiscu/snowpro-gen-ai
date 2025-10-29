-- Build a RAG-based LLM assistant using Streamlit and Snowflake Cortex Search (inspired from)
-- https://quickstarts.snowflake.com/guide/ask_questions_to_your_own_documents_with_snowflake_cortex_search/index.html
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.rag_search;

create stage docs
    ENCRYPTION=(TYPE='SNOWFLAKE_SSE')
    DIRECTORY=(ENABLE=true);
-- manually upload into this stage all PDF files from .data/bikes/
ls @docs;

-- use AI_PARSE_DOCUMENT to extract all LAYOUT text from the docs
CREATE TEMPORARY TABLE raw_text
AS WITH FILE_TABLE AS (
    (SELECT RELATIVE_PATH, SIZE, FILE_URL,
        build_scoped_file_url(@docs, relative_path) as scoped_file_url,
        TO_FILE('@DOCS', RELATIVE_PATH) AS docs 
    FROM DIRECTORY(@DOCS)))
SELECT RELATIVE_PATH, SIZE, FILE_URL, scoped_file_url,
    TO_VARCHAR(SNOWFLAKE.CORTEX.AI_PARSE_DOCUMENT(
        docs, {'mode':'LAYOUT'}):content) AS EXTRACTED_LAYOUT 
FROM FILE_TABLE;

-- split extracted text into chunks, using SPLIT_TEXT_RECURSIVE_CHARACTER
create table docs_chunks_table ( 
    RELATIVE_PATH VARCHAR(16777216),    -- Relative path to the PDF file
    SIZE NUMBER(38,0),                  -- Size of the PDF
    FILE_URL VARCHAR(16777216),         -- URL for the PDF
    SCOPED_FILE_URL VARCHAR(16777216),  -- Scoped url (you can choose which one to keep depending on your use case)
    CHUNK VARCHAR(16777216),            -- Piece of text
    CHUNK_INDEX INTEGER,                -- Index for the text
    CATEGORY VARCHAR(16777216));        -- Will hold the document category to enable filtering

insert into docs_chunks_table(
    relative_path, size, file_url, scoped_file_url, chunk, chunk_index)
select relative_path, size, file_url, scoped_file_url,
    c.value::TEXT as chunk, c.INDEX::INTEGER as chunk_index
from raw_text,
    LATERAL FLATTEN(input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
        EXTRACTED_LAYOUT, 'markdown', 1512, 256, ['\n\n', '\n', ' ', ''])) c;

-- label the product category, using AI_CLASSIFY
CREATE TEMPORARY TABLE docs_categories
AS WITH unique_documents AS (
    SELECT DISTINCT relative_path, chunk
    FROM docs_chunks_table
    WHERE chunk_index = 0),
docs_category_cte AS (
    SELECT relative_path,
        TRIM(snowflake.cortex.AI_CLASSIFY(
            'Title:' || relative_path || 'Content:' || chunk, ['Bike', 'Snow']
        )['labels'][0], '"') AS CATEGORY
    FROM unique_documents)
SELECT *
FROM docs_category_cte;
select * from docs_categories;

update docs_chunks_table 
    set category = docs_categories.category
    from docs_categories
    where docs_chunks_table.relative_path = docs_categories.relative_path;

-- create Cortex Search service
create cortex search service CC_SEARCH_SERVICE_CS
    ON chunk
    ATTRIBUTES category
    warehouse = COMPUTE_WH
    TARGET_LAG = '1 minute'
AS (select chunk, chunk_index, relative_path, file_url, category
    from docs_chunks_table);