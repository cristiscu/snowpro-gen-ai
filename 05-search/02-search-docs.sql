-- Cortex Search service on unstructured business documents
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#examples
USE test.public;

CREATE OR REPLACE TABLE business_docs (
    contents VARCHAR,
    last_modified TIMESTAMP,
    created TIMESTAMP,
    likes INT,
    comments INT);
INSERT INTO business_docs(contents, last_modified, created, likes, comments)
VALUES
    ('Quarterly financial report for Q1 2024: Revenue increased by 15%, with expenses stable.',
     '2024-01-12 10:00:00', '2024-01-10 09:00:00', 10, 20),
    ('IT manual for employees: Instructions for usage of internal technologies, including hardware.',
     '2024-02-10 15:00:00', '2024-02-05 14:30:00', 85, 10),
    ('Employee handbook 2024: Updated policies on remote work, health benefits, and company culture.',
     '2024-02-10 15:00:00', '2024-02-05 14:30:00', 85, 10),
    ('Marketing strategy document: Target audience segmentation for upcoming product launch.',
     '2024-03-15 12:00:00', '2024-03-12 11:15:00', 150, 32),
    ('Product roadmap 2024: Key milestones for tech product development, including the launch.',
     '2024-04-22 17:30:00', '2024-04-20 16:00:00', 200, 45),
    ('Annual performance review process guidelines: Procedures for managers to conduct employee.',
     '2024-05-02 09:30:00', '2024-05-01 08:45:00', 60, 5);
SELECT * FROM business_docs;

CREATE OR REPLACE CORTEX SEARCH SERVICE search_docs
    ON contents
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 minute'
AS SELECT * FROM business_docs;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_docs',
      '{
         "query": "technology",
         "columns": ["DOCUMENT_CONTENTS", "LIKES"],
         "filter": {"@eq": {"REGION": "US"}},
         "limit": 5
      }'
  )
)['results'] as results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_docs',
      '{
         "query": "business",
         "columns": ["DOCUMENT_CONTENTS", "LIKES", "COMMENTS"],
         "filter": {"@and": [
           {"@gte": {"LIKES": 50}},
           {"@lte": {"COMMENTS": 50}}
         ]},
         "limit": 10
      }'
  )
)['results'] as results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_docs',
      '{
         "query": "technology",
         "columns": ["DOCUMENT_CONTENTS", "LIKES", "COMMENTS"],
         "scoring_config": {
           "functions": {
             "numeric_boosts": [
               {"column": "comments", "weight": 2},
               {"column": "likes", "weight": 1}
             ]
           }
         }
      }'
  )
)['results'] as results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_docs',
      '{
         "query": "technology",
         "columns": ["DOCUMENT_CONTENTS", "LAST_MODIFIED_TIMESTAMP"],
         "scoring_config": {
           "functions": {
             "time_decays": [
               {"column": "LAST_MODIFIED_TIMESTAMP", "weight": 1, "limit_hours": 240, "now": "2024-04-23T00:00:00.000-08:00"}
             ]
           }
         }
      }'
  )
)['results'] as results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_docs',
      '{
         "query": "technology",
         "columns": ["DOCUMENT_CONTENTS", "LAST_MODIFIED_TIMESTAMP"],
         "scoring_config": {
           "reranker": "none"
         }
      }'
  )
)['results'] as results;

ALTER CORTEX SEARCH SERVICE search_docs SUSPEND;
