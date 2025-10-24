-- Account-level allowlist parameter
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql#account-level-allowlist-parameter

-- usually ALL by default
SHOW PARAMETERS LIKE 'CORTEX_MODELS_ALLOWLIST' IN ACCOUNT;

-- prevent access to any model
ALTER ACCOUNT SET CORTEX_MODELS_ALLOWLIST = 'NONE';
SHOW PARAMETERS LIKE 'CORTEX_MODELS_ALLOWLIST' IN ACCOUNT;

-- access only these two models
ALTER ACCOUNT SET CORTEX_MODELS_ALLOWLIST = 'mistral-large2,llama3.1-70b';
SHOW PARAMETERS LIKE 'CORTEX_MODELS_ALLOWLIST' IN ACCOUNT;

-- change back to All
ALTER ACCOUNT SET CORTEX_MODELS_ALLOWLIST = 'ALL';
SHOW PARAMETERS LIKE 'CORTEX_MODELS_ALLOWLIST' IN ACCOUNT;

-- ==========================================================================

show models in snowflake.models;
show models;
show versions in model test.docai.model1;

show application roles in application SNOWFLAKE;

show grants of application role snowflake.CORTEX_MODELS_ADMIN;
show grants to application role snowflake.CORTEX_MODELS_ADMIN;
