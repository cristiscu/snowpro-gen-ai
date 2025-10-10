-- create Search resources
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview#example
CREATE DATABASE IF NOT EXISTS cortex_search_db;
CREATE OR REPLACE WAREHOUSE cortex_search_wh WITH WAREHOUSE_SIZE='X-SMALL';
CREATE OR REPLACE SCHEMA cortex_search_db.services;

CREATE OR REPLACE TABLE support_transcripts (
    transcript_text VARCHAR,
    region VARCHAR,
    agent_id VARCHAR);
INSERT INTO support_transcripts VALUES
    ('My internet has been down since yesterday, can you help?', 'North America', 'AG1001'),
    ('I was overcharged for my last bill, need an explanation.', 'Europe', 'AG1002'),
    ('How do I reset my password? The email link is not working.', 'Asia', 'AG1003'),
    ('I received a faulty router, can I get it replaced?', 'North America', 'AG1004');
ALTER TABLE support_transcripts SET CHANGE_TRACKING = TRUE;

CREATE OR REPLACE CORTEX SEARCH SERVICE transcript_search_service
    ON transcript_text
    ATTRIBUTES region
    WAREHOUSE = cortex_search_wh
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS SELECT transcript_text, region, agent_id FROM support_transcripts;

-- grant usage permissions
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview#grant-usage-permissions
GRANT USAGE ON DATABASE cortex_search_db TO ROLE customer_support;
GRANT USAGE ON SCHEMA services TO ROLE customer_support;

GRANT USAGE ON CORTEX SEARCH SERVICE transcript_search_service TO ROLE customer_support;

-- verify access
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'cortex_search_db.services.transcript_search_service',
        '{
            "query": "internet issues",
            "columns": ["transcript_text", "region"],
            "filter": {"@eq": {"region": "North America"} },
            "limit": 1
        }'
    )
)['results'] as results;

SELECT *
FROM TABLE (CORTEX_SEARCH_DATA_SCAN (SERVICE_NAME => 'transcript_search_service'));