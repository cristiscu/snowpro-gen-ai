-- limit access using the Cortex Analyst user role
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#access-control-requirements
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE analyst;

USE ROLE ACCOUNTADMIN;
CREATE ROLE cortex_user_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_analyst_user_role;

GRANT ROLE cortex_analyst_user_role TO USER example_user;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE analyst;

-- ------------------------------------------------------------------
-- Cortex Analyst example
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#cortex-analyst-example
CREATE DATABASE semantic_model;
CREATE SCHEMA semantic_model.definitions;
GRANT USAGE ON DATABASE semantic_model TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA semantic_model.definitions TO ROLE PUBLIC;

USE SCHEMA semantic_model.definitions;

CREATE STAGE public DIRECTORY = (ENABLE = TRUE);
GRANT READ ON STAGE public TO ROLE PUBLIC;

CREATE STAGE sales DIRECTORY = (ENABLE = TRUE);
GRANT READ ON STAGE sales TO ROLE sales_analyst;

-- disable Cortex Analyst functionality
USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET ENABLE_CORTEX_ANALYST = FALSE;

-- ------------------------------------------------------------------
-- Enabling use of Azure OpenAI models (legacy path)
USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI = TRUE;
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI' IN ACCOUNT