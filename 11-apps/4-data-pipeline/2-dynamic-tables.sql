-- Create a landing table to store raw JSON data.
CREATE OR REPLACE TABLE raw (var VARIANT);

-- Create a dynamic table containing the names of office visitors from the raw data.
-- Try to keep the data up to date within 1 minute of real time.
CREATE OR REPLACE DYNAMIC TABLE names
    TARGET_LAG = '1 minute'
    WAREHOUSE = mywh
AS
    SELECT var:id::int id, var:fname::string first_name, var:lname::string last_name
    FROM raw;