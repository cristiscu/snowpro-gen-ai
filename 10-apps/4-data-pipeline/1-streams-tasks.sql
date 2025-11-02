-- https://docs.snowflake.com/en/user-guide/dynamic-tables-comparison

-- Create a landing table to store raw JSON data.
CREATE OR REPLACE TABLE raw (var VARIANT);

-- Create a stream to capture inserts to the landing table.
CREATE OR REPLACE STREAM rawstream1 ON TABLE raw;

-- Create a table that stores the names of office visitors from the raw data.
CREATE OR REPLACE TABLE names (id INT, first_name STRING, last_name STRING);

-- Create a task that inserts new name records from the rawstream1 stream
-- into the names table. Execute the task every minute when the stream contains records.
CREATE OR REPLACE TASK raw_to_names
    WAREHOUSE = mywh
    SCHEDULE = '1 minute'
    WHEN SYSTEM$STREAM_HAS_DATA('rawstream1')
AS
    MERGE INTO names n USING (
        SELECT var:id id, var:fname fname, var:lname lname, metadata$action, metadata$isupdate
        FROM rawstream1) r1
        ON n.id = TO_NUMBER(r1.id)
    WHEN MATCHED AND metadata$action = 'DELETE' AND NOT metadata$isupdate THEN
        DELETE
    WHEN MATCHED AND metadata$action = 'INSERT' THEN
        UPDATE SET n.first_name = r1.fname, n.last_name = r1.lname
    WHEN NOT MATCHED AND metadata$action = 'INSERT' THEN
        INSERT (id, first_name, last_name) VALUES (r1.id, r1.fname, r1.lname);
ALTER TASK raw_to_names RESUME;