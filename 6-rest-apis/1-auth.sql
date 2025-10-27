-- Using programmatic access tokens (PET) for authentication
-- https://docs.snowflake.com/en/user-guide/programmatic-access-tokens

-- allow access to all public IPs (or you'll get a "Network policy is required" error)
CREATE NETWORK RULE my_allow_all_rule
    MODE=INGRESS
    TYPE=IPV4
    VALUE_LIST=('0.0.0.0/0');
CREATE NETWORK POLICY my_allow_all_policy
    ALLOWED_NETWORK_RULE_LIST=('my_allow_all_rule');
ALTER ACCOUNT SET NETWORK_POLICY=my_allow_all_policy;

-- create authentication policy (w/ PAT)
CREATE AUTHENTICATION POLICY my_auth_policy
    PAT_POLICY=(NETWORK_POLICY_EVALUATION=NOT_ENFORCED)
    AUTHENTICATION_METHODS=('OAUTH', 'PASSWORD', 'PROGRAMMATIC_ACCESS_TOKEN');
DESCRIBE AUTHENTICATION POLICY my_auth_policy;
SHOW AUTHENTICATION POLICIES;

-- create PAT for current user (update with your values)
GRANT MODIFY PROGRAMMATIC AUTHENTICATION METHODS ON USER cristiscu TO ROLE accountadmin;
ALTER USER ADD PROGRAMMATIC ACCESS TOKEN example_token;
SHOW USER PROGRAMMATIC ACCESS TOKENS FOR USER cristiscu;
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.CREDENTIALS WHERE type='PAT';

-- replace with your own PAT
SELECT SYSTEM$DECODE_PAT('...');