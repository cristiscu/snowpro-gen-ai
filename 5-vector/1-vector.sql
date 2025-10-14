-- https://docs.snowflake.com/en/sql-reference/data-types-vector

CREATE OR REPLACE TABLE myvectortable (a VECTOR(float, 3), b VECTOR(float, 3));
INSERT INTO myvectortable SELECT [1.1,2.2,3]::VECTOR(FLOAT,3), [1,1,1]::VECTOR(FLOAT,3);
INSERT INTO myvectortable SELECT [1,2.2,3]::VECTOR(FLOAT,3), [4,6,8]::VECTOR(FLOAT,3);

COPY INTO @mystage/unload/
  FROM (SELECT TO_ARRAY(a), TO_ARRAY(b) FROM myvectortable);

CREATE OR REPLACE TABLE arraytable (a ARRAY, b ARRAY);

COPY INTO arraytable
  FROM @mystage/unload/mydata.csv.gz;

SELECT a::VECTOR(FLOAT, 3), b::VECTOR(FLOAT, 3)
  FROM arraytable;

-- ==================================================================

SELECT [1, 2, 3]::VECTOR(FLOAT, 3) AS vec;

ALTER TABLE myissues ADD COLUMN issue_vec VECTOR(FLOAT, 768);

UPDATE TABLE myissues
  SET issue_vec = SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2', issue_text);