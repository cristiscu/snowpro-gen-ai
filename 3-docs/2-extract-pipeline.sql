CREATE OR REPLACE STAGE my_pdf_stage
  DIRECTORY = (ENABLE = TRUE)
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

CREATE STREAM my_pdf_stream ON STAGE my_pdf_stage;
ALTER STAGE my_pdf_stage REFRESH;


USE DATABASE doc_ai_db;
USE SCHEMA doc_ai_schema;

CREATE OR REPLACE TABLE pdf_reviews (
  file_name VARCHAR,
  file_size VARIANT,
  last_modified VARCHAR,
  snowflake_file_url VARCHAR,
  json_content VARCHAR
);

CREATE OR REPLACE TASK load_new_file_data
  WAREHOUSE = <your_warehouse>
  SCHEDULE = '1 minutes'
  COMMENT = 'Process new files in the stage and insert data into the pdf_reviews table.'
WHEN SYSTEM$STREAM_HAS_DATA('my_pdf_stream')
AS
INSERT INTO pdf_reviews (
  SELECT
    RELATIVE_PATH AS file_name,
    size AS file_size,
    last_modified,
    file_url AS snowflake_file_url,
    inspection_reviews!PREDICT(GET_PRESIGNED_URL('@my_pdf_stage', RELATIVE_PATH), 1) AS json_content
  FROM my_pdf_stream
  WHERE METADATA$ACTION = 'INSERT'
);
ALTER TASK load_new_file_data RESUME;

