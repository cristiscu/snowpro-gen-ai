-- PARSE_DOCUMENT/AI_PARSE_DOCUMENT
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.schema1;

CREATE OR REPLACE STAGE stage1
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
-- manually upload in @stage1 the PDF doc .data/docs/predict_2022-11-01.pdf

-- ==================================================
-- PARSE_DOCUMENT
SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
    '@stage1', 'predict_2022-11-01.pdf',
    {'mode': 'OCR'});

SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
    '@stage1', 'predict_2022-11-01.pdf',
    {'mode': 'LAYOUT'});

-- ==================================================
-- AI_PARSE_DOCUMENT
SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@stage1','predict_2022-11-01.pdf'),
    {'mode': 'OCR'});

SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@stage1','predict_2022-11-01.pdf'),
    {'mode': 'LAYOUT', 'page_split': true});

SELECT AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'predict_2022-11-01.pdf'),
    {'mode': 'LAYOUT', 'page_filter': [{'start': 0, 'end': 1}]});

-- cleanup
DROP SCHEMA test.schema1;