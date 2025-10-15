-- Grant the required roles and privileges to Document AI users
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai/setting-up#grant-the-required-roles-and-privileges-to-document-ai-users
USE ROLE ACCOUNTADMIN;

CREATE ROLE doc_ai_role;
GRANT DATABASE ROLE SNOWFLAKE.DOCUMENT_INTELLIGENCE_CREATOR TO ROLE doc_ai_role;

CREATE DATABASE doc_ai_db;
CREATE SCHEMA doc_ai_db.doc_ai_schema;
CREATE WAREHOUSE doc_ai_wh;

GRANT USAGE, OPERATE ON WAREHOUSE doc_ai_wh TO ROLE doc_ai_role;

GRANT USAGE ON DATABASE doc_ai_db TO ROLE doc_ai_role;
GRANT USAGE ON SCHEMA doc_ai_db.doc_ai_schema TO ROLE doc_ai_role;
GRANT CREATE STAGE ON SCHEMA doc_ai_db.doc_ai_schema TO ROLE doc_ai_role;

GRANT CREATE SNOWFLAKE.ML.DOCUMENT_INTELLIGENCE ON SCHEMA doc_ai_db.doc_ai_schema TO ROLE doc_ai_role;
GRANT CREATE MODEL ON SCHEMA doc_ai_db.doc_ai_schema TO ROLE doc_ai_role;

GRANT CREATE STREAM, CREATE TABLE, CREATE TASK, CREATE VIEW ON SCHEMA doc_ai_db.doc_ai_schema TO ROLE doc_ai_role;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE doc_ai_role;

GRANT ROLE doc_ai_role TO USER doc_ai_user;
