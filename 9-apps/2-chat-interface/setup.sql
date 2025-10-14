-- https://quickstarts.snowflake.com/guide/tasty_bytes_rag_chatbot_using_cortex_and_streamlit/index.html?index=..%2F..index#0

-- Database
CREATE OR REPLACE DATABASE tasty_bytes_chatbot;

--Schema
CREATE OR REPLACE SCHEMA tasty_bytes_chatbot.app;

--Warehouse
CREATE OR REPLACE WAREHOUSE tasty_bytes_chatbot_wh with
WAREHOUSE_SIZE = LARGE
AUTO_SUSPEND = 60;

CREATE OR REPLACE FILE FORMAT tasty_bytes_chatbot.app.csv_ff 
TYPE = 'csv';

CREATE OR REPLACE STAGE tasty_bytes_chatbot.app.s3load
COMMENT = 'Quickstarts S3 Stage Connection'
url = 's3://sfquickstarts/tastybytes-cx/app/'
file_format = tasty_bytes_chatbot.app.csv_ff;

CREATE OR REPLACE TABLE tasty_bytes_chatbot.app.documents (
	RELATIVE_PATH VARCHAR(16777216),
	RAW_TEXT VARCHAR(16777216)
)
COMMENT = '{"origin":"sf_sit-is", "name":"voc", "version":{"major":1, "minor":0}, "attributes":{"is_quickstart":1, "source":"streamlit", "vignette":"rag_chatbot"}}';

COPY INTO tasty_bytes_chatbot.app.documents
FROM @tasty_bytes_chatbot.app.s3load/documents/;

-- https://docs.snowflake.com/en/sql-reference/data-types-vector#loading-and-unloading-vector-data
CREATE OR REPLACE TABLE tasty_bytes_chatbot.app.array_table (
  SOURCE VARCHAR(6),
	SOURCE_DESC VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216),
	SIZE NUMBER(18,0),
	CHUNK VARCHAR(16777216),
	INPUT_TEXT VARCHAR(16777216),
	CHUNK_EMBEDDING ARRAY
);

COPY INTO tasty_bytes_chatbot.app.array_table
FROM @tasty_bytes_chatbot.app.s3load/vector_store/;

CREATE OR REPLACE TABLE tasty_bytes_chatbot.app.vector_store (
	SOURCE VARCHAR(6),
	SOURCE_DESC VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216),
	SIZE NUMBER(18,0),
	CHUNK VARCHAR(16777216),
	INPUT_TEXT VARCHAR(16777216),
	CHUNK_EMBEDDING VECTOR(FLOAT, 768)
) AS
SELECT 
  source,
	source_desc,
	full_text,
	size,
	chunk,
	input_text,
  chunk_embedding::VECTOR(FLOAT, 768)
FROM tasty_bytes_chatbot.app.array_table;