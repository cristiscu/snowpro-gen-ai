-- limit access to Copilot
-- https://docs.snowflake.com/en/user-guide/snowflake-copilot#limit-access-to-copilot
USE ROLE ACCOUNTADMIN;
REVOKE DATABASE ROLE SNOWFLAKE.COPILOT_USER FROM ROLE PUBLIC;

-- selectively provide access to specific roles/users
CREATE ROLE copilot_access_role;
GRANT DATABASE ROLE SNOWFLAKE.COPILOT_USER TO ROLE copilot_access_role;
GRANT ROLE copilot_access_role TO USER some_user;

-- restore public access to Copilot
GRANT DATABASE ROLE SNOWFLAKE.COPILOT_USER TO ROLE PUBLIC;
