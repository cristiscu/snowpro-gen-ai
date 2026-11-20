-- Query a service with custom vector embeddings
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#query-a-service-with-custom-vector-embeddings
USE test.public;

CREATE OR REPLACE TABLE docs_embs(docs VARCHAR, embs VECTOR(FLOAT, 3));
INSERT INTO docs_embs VALUES
    ('Quarterly financial report for Q1 2024: Revenue increased by 15%, with expenses stable. Highlights include strategic investments in marketing and technology.', [1, 1, 1]::VECTOR(float, 3)),
    ('IT manual for employees: Instructions for usage of internal technologies, including hardware and software guides and commonly asked tech questions.', [2, 2, 2]::VECTOR(float, 3)),
    ('Employee handbook 2024: Updated policies on remote work, health benefits, and company culture initiatives.', [2, 3, 2]::VECTOR(float, 3)),
    ('Marketing strategy document: Target audience segmentation for upcoming product launch.', [1, -1, -1]::VECTOR(float, 3));
SELECT * FROM docs_embs;

-- Cortex Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE search_docs_embs
    TEXT INDEXES (docs)
    VECTOR INDEXES (embs)
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 minute'
AS SELECT * FROM docs_embs;

SELECT value['docs']::text as docs
FROM TABLE(FLATTEN(PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'search_docsembs',
        '{
            "multi_index_query": {
                "embs": [ {"vector": [1, 1, 1] } ],
                "docs": [ {"text": "IT"} ]
          },
          "columns": ["docs"],
          "limit": 2
        }'
    )
)['results']));

ALTER CORTEX SEARCH SERVICE search_docs_embs SUSPEND;
