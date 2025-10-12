-- Required privileges
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql#required-privileges
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;
REVOKE IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE FROM ROLE PUBLIC;

USE ROLE ACCOUNTADMIN;

CREATE ROLE cortex_user_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_user_role;

GRANT ROLE cortex_user_role TO USER some_user;

GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE analyst;

-- Using AISQL functions in stored procedures with EXECUTE AS RESTRICTED CALLER
GRANT INHERITED CALLER USAGE ON ALL SCHEMAS IN DATABASE snowflake TO ROLE <role_that_created_the_stored_procedure>;
GRANT INHERITED CALLER USAGE ON ALL FUNCTIONS IN DATABASE snowflake TO ROLE <role_that_created_the_stored_procedure>;
GRANT CALLER USAGE ON DATABASE snowflake TO ROLE <role_that_created_the_stored_procedure>;