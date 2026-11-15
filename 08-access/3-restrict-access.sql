-- restrict & restore access to CORTEX overall
USE ROLE ACCOUNTADMIN;
CREATE USER my_user;
CREATE ROLE my_role;
GRANT ROLE my_role TO USER my_user;

REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;
REVOKE IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE FROM ROLE PUBLIC;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE my_role;

-- restrict & restore access to Snowflake Copilot
-- https://docs.snowflake.com/en/user-guide/snowflake-copilot#limit-access-to-copilot
REVOKE DATABASE ROLE SNOWFLAKE.COPILOT_USER FROM ROLE PUBLIC;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE my_role;
GRANT DATABASE ROLE SNOWFLAKE.COPILOT_USER TO ROLE PUBLIC;

-- restrict access to Cortex Analyst
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#access-control-requirements
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE my_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE my_role;

-- restrict access to Cortex Agents
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents#access-control-requirements
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE my_role;

-- allow access to the AI_EMBED/EMBED_TEXT_768/1024 AISQL functions
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_EMBED_USER TO ROLE my_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_EMBED_USER TO ROLE PUBLIC;

-- use AISQL functions inside stored procedures (created by my_role) with EXECUTE AS RESTRICTED CALLER
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql#using-aisql-functions-in-stored-procedures-with-execute-as-restricted-caller
-- https://docs.snowflake.com/en/developer-guide/restricted-callers-rights

CREATE OR REPLACE PROCEDURE my_proc()
    RETURNS FLOAT
    EXECUTE AS RESTRICTED CALLER
AS $$
    SELECT SNOWFLAKE.CORTEX.SENTIMENT('This is a wonderful day indeed!');
$$;

GRANT INHERITED CALLER USAGE ON ALL SCHEMAS IN DATABASE snowflake TO ROLE my_role;
GRANT INHERITED CALLER USAGE ON ALL FUNCTIONS IN DATABASE snowflake TO ROLE my_role;
GRANT CALLER USAGE ON DATABASE snowflake TO ROLE my_role;