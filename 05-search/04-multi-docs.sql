use test.public;

-- Tutorial 3: Build a PDF chatbot with Cortex Search
-- https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-search/tutorials/cortex-search-tutorial-3-chat-advanced
SELECT AI_PARSE_DOCUMENT(
    TO_FILE('@cortex_search_tutorial_db.public.fomc', RELATIVE_PATH),
    {'mode': 'LAYOUT'}):content as content
FROM DIRECTORY('@stage1.fomc')
WHERE RELATIVE_PATH LIKE '%.pdf';

CREATE OR REPLACE TABLE test.public.fomc_raw
AS SELECT RELATIVE_PATH,
    TO_VARCHAR (AI_PARSE_DOCUMENT(
        TO_FILE('@cortex_search_tutorial_db.public.fomc', RELATIVE_PATH),
        {'mode': 'LAYOUT'}):content
    ) AS EXTRACTED_LAYOUT
FROM DIRECTORY('@cortex_search_tutorial_db.public.fomc')
WHERE RELATIVE_PATH LIKE '%.pdf';

-- Getting Started with Access Controls for RAGs (Cortex Search)
-- https://www.snowflake.com/en/developers/guides/getting-started-with-access-controls-for-cortex-search/
CREATE OR REPLACE TEMP TABLE documents_table
AS SELECT TO_FILE('@source_documents', RELATIVE_PATH) AS docs, 
    RELATIVE_PATH as RELATIVE_PATH
FROM DIRECTORY(@source_documents);

-- Use Cortex AI function to parse PDF. Create identifier column so we can filter based on user attribute
CREATE OR REPLACE TABLE EXTRACTED_TEXT_TABLE
AS SELECT RELATIVE_PATH, 
    AI_PARSE_DOCUMENT(docs, {'mode': 'OCR'}):content::VARCHAR AS EXTRACTED_TEXT,
    CASE WHEN RELATIVE_PATH ILIKE '%ski%' THEN 'SKI'
        WHEN RELATIVE_PATH ILIKE '%bike%' OR RELATIVE_PATH ILIKE '%bicycle%' THEN 'BICYCLE'
        ELSE 'Other'
        END AS product_department
FROM documents_table;
