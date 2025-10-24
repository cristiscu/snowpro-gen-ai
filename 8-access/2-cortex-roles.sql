use role accountadmin;
use snowflake.cortex;
show functions in snowflake.cortex;

show roles in database snowflake;

-- for Snowflake Cortex overall
show grants of database role snowflake.CORTEX_USER;
show grants to database role snowflake.CORTEX_USER;

-- for Snowflake Copilot
show grants of database role snowflake.COPILOT_USER;
show grants to database role snowflake.COPILOT_USER;

-- for Cortex Analyst
show grants of database role snowflake.CORTEX_ANALYST_USER;
show grants to database role snowflake.CORTEX_ANALYST_USER;

-- for Document AI
show grants of database role snowflake.DOCUMENT_INTELLIGENCE_CREATOR;
show grants to database role snowflake.DOCUMENT_INTELLIGENCE_CREATOR;
