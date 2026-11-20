-- Cortex Search service on unstructured text transcripts
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview#example-create-and-query-a-cortex-search-service
USE test.public;

CREATE OR REPLACE TABLE transcripts (
    text VARCHAR,
    region VARCHAR,
    agent_id VARCHAR);
INSERT INTO transcripts VALUES
    ('My internet has been down since yesterday, can you help?', 'North America', 'AG1001'),
    ('I was overcharged for my last bill, need an explanation.', 'Europe', 'AG1002'),
    ('How do I reset my password? The email link is not working.', 'Asia', 'AG1003'),
    ('I received a faulty router, can I get it replaced?', 'North America', 'AG1004');
SELECT * FROM transcripts;

CREATE OR REPLACE CORTEX SEARCH SERVICE search_transcripts
    ON text
    ATTRIBUTES region
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 day'
AS SELECT text, region, agent_id FROM transcripts;

CREATE OR REPLACE CORTEX SEARCH SERVICE search_transcripts
    ON text
    PRIMARY KEY (region, agent_id)
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS SELECT text, region, agent_id FROM transcripts;

SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'search_transcripts',
    '{
        "query": "internet issues",
        "columns": ["text", "region"],
        "filter": {"@eq": {"region": "North America"} },
        "limit": 1
    }'
) AS json;
/*
[{
    "transcript_text" : "My internet has been down since yesterday, can you help?",
    "region" : "North America"
}]
*/

SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS(
    'snowflake-arctic-embed-l-v2.0', 'internet issues') as tokens;

ALTER CORTEX SEARCH SERVICE search_transcripts SUSPEND;
