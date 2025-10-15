-- Tutorial: Create a document processing pipeline with Document AI
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai/tutorials/create-processing-pipelines
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.schema1;

GRANT CREATE SNOWFLAKE.ML.DOCUMENT_INTELLIGENCE ON SCHEMA test.schema1 TO ROLE ACCOUNTADMIN;
-- GRANT CREATE MODEL ON SCHEMA test.schema1 TO ROLE ACCOUNTADMIN;

-- ==================================================================
-- (1) Upload docs in a stage and PREDICT directly
-- (after manually creating and publishing a model1 build model, w/ training docs from .data/document-ai/testing_dataset/)
CREATE OR REPLACE STAGE stage_manual
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
-- upload in stage_manual docs from .data/document-ai/extraction_dataset/

-- extracting information from single/multiple docs (as generated extracting queries)
SELECT model1!PREDICT(GET_PRESIGNED_URL(@stage_manual, 'Manual_2022-11-01.pdf'), 1);
SELECT model1!PREDICT(GET_PRESIGNED_URL(@stage_manual, RELATIVE_PATH), 1)
FROM DIRECTORY(@stage_manual);

SELECT RELATIVE_PATH, size, last_modified, file_url,
    model1!PREDICT(GET_PRESIGNED_URL('@stage_manual', RELATIVE_PATH), 1) AS json
FROM directory(@stage_manual);

-- ==================================================================
-- (2) Create an automated document processing pipeline (w/ stream & task)
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai/tutorials/create-processing-pipelines
CREATE OR REPLACE STAGE stage1
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

CREATE STREAM stream1 ON STAGE stage1;
ALTER STAGE stage1 REFRESH;

CREATE TABLE reviews_auto (
    file_name VARCHAR,
    file_size VARIANT,
    last_modified VARCHAR,
    snowflake_file_url VARCHAR,
    json_content VARCHAR);

CREATE OR REPLACE TASK task1
    WAREHOUSE = compute_wh
    SCHEDULE = '1 minutes'
    COMMENT = 'Process new files in the stage1 and insert data into the reviews_auto table.'
WHEN SYSTEM$STREAM_HAS_DATA('stream1')
AS INSERT INTO reviews_auto (
    SELECT
        RELATIVE_PATH AS file_name,
        size AS file_size,
        last_modified,
        file_url AS snowflake_file_url,
        model1!PREDICT(GET_PRESIGNED_URL('@stage1', RELATIVE_PATH), 1) AS json_content
    FROM stream1
    WHERE METADATA$ACTION = 'INSERT');
ALTER TASK task1 RESUME;

-- manually upload in stage1 docs from .data/document-ai/extraction_dataset/
EXECUTE TASK task1;
SELECT * FROM reviews_auto;

-- ==================================================================
-- (3) Manually collect and inspect directly the info extracted from new uploaded documents
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai/tutorials/create-processing-pipelines#view-the-extracted-information
CREATE TABLE reviews_manual AS (
WITH temp AS (
    SELECT
        RELATIVE_PATH AS file_name,
        size AS file_size,
        last_modified,
        file_url AS snowflake_file_url,
        model1!PREDICT(get_presigned_url('@stage1', RELATIVE_PATH), 1) AS json_content
    FROM directory(@stage1))
 SELECT
    file_name,
    file_size,
    last_modified,
    snowflake_file_url,
    json_content:__documentMetadata.ocrScore::FLOAT AS ocrScore,
    f.value:score::FLOAT AS inspection_date_score,
    f.value:value::STRING AS inspection_date_value,
    g.value:score::FLOAT AS inspection_grade_score,
    g.value:value::STRING AS inspection_grade_value,
    i.value:score::FLOAT AS inspector_score,
    i.value:value::STRING AS inspector_value,
    ARRAY_TO_STRING(ARRAY_AGG(j.value:value::STRING), ', ') AS list_of_units
 FROM temp,
    LATERAL FLATTEN(INPUT => json_content:inspection_date) f,
    LATERAL FLATTEN(INPUT => json_content:inspection_grade) g,
    LATERAL FLATTEN(INPUT => json_content:inspector) i,
    LATERAL FLATTEN(INPUT => json_content:list_of_units) j
GROUP BY ALL);
SELECT * FROM reviews_manual;

-- cleanup
DROP SCHEMA test.schema1;