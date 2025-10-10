-- Access control requirements
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents#access-control-requirements
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE agent;

USE ROLE ACCOUNTADMIN;
CREATE ROLE cortex_agent_user_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE cortex_agent_user_role;
GRANT ROLE cortex_agent_user_role TO USER example_user;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE agent;