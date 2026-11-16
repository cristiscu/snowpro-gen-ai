-- Automated Pipeline with Stream and Task
create or replace schema test.auto;
use test.auto;

create stage stage1
    ENCRYPTION=(TYPE='SNOWFLAKE_SSE')
    DIRECTORY=(ENABLE=true);

-- "Copy full path" of /spool/inspection.pdf and replace below
list snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/.spool/inspection.pdf;
copy files into @stage1/spool/
    from snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/.spool/
    files = ('inspection.pdf');
list @stage1;

select * from directory(@stage1);
alter stage stage1 refresh;
select * from directory(@stage1);

-- extract doc info into table
CREATE TABLE docs
AS SELECT RELATIVE_PATH AS file_name,
    BUILD_SCOPED_FILE_URL('@stage1', RELATIVE_PATH) AS file_url,
    AI_EXTRACT(
        file => TO_FILE('@stage1', RELATIVE_PATH),
        responseFormat => {
            'machine_name': 'What is the inspected machine name?',
            'serial_number': 'What is the serial number of the inspection?',
            'inspection_grade': 'What was the inspection grade?'
        }) AS extracted_data,
    CURRENT_TIMESTAMP() AS processed_at
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.pdf';

CREATE VIEW view1 AS
SELECT file_name,
    extracted_data:response:machine_name::STRING AS machine_name,
    extracted_data:response:serial_number::STRING AS serial_number,
    extracted_data:response:inspection_grade::STRING AS inspection_grade,
    processed_at
FROM docs;

SELECT * FROM view1;

-- ===================================================================
-- Automate with Stream (on Stage) & Task

CREATE STREAM stream1 ON STAGE stage1;

CREATE TASK task1
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('stream1')
AS INSERT INTO docs
SELECT RELATIVE_PATH,
    BUILD_SCOPED_FILE_URL('@stage1', RELATIVE_PATH),
    AI_EXTRACT(
        file => TO_FILE('@stage1', RELATIVE_PATH),
        responseFormat => {
            'machine_name': 'What is the inspected machine name?',
            'serial_number': 'What is the serial number of the inspection?',
            'inspection_grade': 'What was the inspection grade?'
        }),
    CURRENT_TIMESTAMP()
FROM stream1
WHERE METADATA$ACTION = 'INSERT';

ALTER TASK task1 RESUME;
-- ALTER TASK task1 SUSPEND;
