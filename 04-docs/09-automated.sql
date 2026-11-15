-- Automated Pipeline with Stream and Task
create or replace schema test.auto;
use test.auto;

create stage stage1
    ENCRYPTION=(TYPE='SNOWFLAKE_SSE')
    DIRECTORY=(ENABLE=true);

CREATE TABLE docs (
    file_name STRING,
    file_url STRING,
    extracted_data VARIANT,
    processed_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP());

CREATE STREAM stream1
    ON STAGE stage1;

CREATE TASK task1
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('stream1')
AS
INSERT INTO docs (file_name, file_url, extracted_data)
SELECT 
    RELATIVE_PATH AS file_name,
    BUILD_SCOPED_FILE_URL('@stage1', RELATIVE_PATH) AS file_url,
    AI_EXTRACT(
        file => TO_FILE('@stage1', RELATIVE_PATH),
        responseFormat => {
            'machine_name': 'What is the inspected machine name?',
            'serial_number': 'What is the serial number of the inspection?',
            'inspection_grade': 'What was the inspection grade?'
        }
    ) AS extracted_data
FROM new_documents_stream
WHERE METADATA$ACTION = 'INSERT';

CREATE VIEW view1 AS
SELECT file_name,
    extracted_data:response:machine::STRING AS machine_name,
    extracted_data:response:serial_number::STRING AS serial_number,
    extracted_data:response:inspection_grade::STRING AS inspection_grade,
    processed_at
FROM docs;

-- ===================================================================

-- "Copy full path" of a file from /spool and replace below
list snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/2-docs/spool/inspection.pdf;
copy files into @stage1/
    from snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/2-docs/spool/inspection.pdf;
list @stage1;

ALTER TASK task1 RESUME;
EXECUTE TASK task1 IMMEDIATE;
SELECT * FROM view1;

EXECUTE TASK task1 IMMEDIATE;
SELECT * FROM view1;

ALTER TASK task1 SUSPEND;
