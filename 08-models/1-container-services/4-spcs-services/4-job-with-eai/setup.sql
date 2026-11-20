-- execute one by one in a SQL Worksheet, in a commercial Snowflake account
use role accountadmin;
use test.public;

-- check that the previous image has been uploaded
show images in image repository repo;

-- =========================================================
-- (1) create EAIs for egress HTTP/HTTPS calls to google.com and for all access
CREATE NETWORK RULE google_search_rule
    TYPE = HOST_PORT
    MODE = EGRESS
    VALUE_LIST = ('google.com:80', 'google.com:443');

CREATE EXTERNAL ACCESS INTEGRATION google_search_integration
    ALLOWED_NETWORK_RULES = (google_search_rule)
    ENABLED = true;

CREATE NETWORK RULE allow_all_rule
    TYPE = HOST_PORT
    MODE = EGRESS
    VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

CREATE EXTERNAL ACCESS INTEGRATION allow_all_integration
    ALLOWED_NETWORK_RULES = (allow_all_rule)
    ENABLED = true;

-- ======================================================
-- (2) grant access to SYSADMIN
grant read on image repository repo to role sysadmin;
grant usage, operate on compute pool cpu to role sysadmin;
grant usage on integration google_search_integration to role sysadmin;
grant usage on integration allow_all_integration to role sysadmin;

use role sysadmin;

-- ======================================================
-- (3) create and run job services
EXECUTE JOB SERVICE
    IN COMPUTE POOL cpu
    NAME = google_search_job
    EXTERNAL_ACCESS_INTEGRATIONS = (google_search_integration)
FROM SPECIFICATION $$
  spec:
    container:
    - name: curl
      image: /test/public/repo/alpine-curl
      command:
      - "curl"
      - "http://google.com/"
$$;

EXECUTE JOB SERVICE
    IN COMPUTE POOL cpu
    NAME = snowflake_job
    EXTERNAL_ACCESS_INTEGRATIONS = (google_search_integration)
FROM SPECIFICATION $$
  spec:
    container:
    - name: curl
      image: /test/public/repo/alpine-curl
      command:
      - "curl"
      - "https://docs.snowflake.com/"
$$;

EXECUTE JOB SERVICE
    IN COMPUTE POOL cpu
    NAME = allow_all_job
    EXTERNAL_ACCESS_INTEGRATIONS = (allow_all_integration)
FROM SPECIFICATION $$
  spec:
    container:
    - name: curl
      image: /test/public/repo/alpine-curl
      command:
      - "curl"
      - "https://docs.snowflake.com/"
$$;

-- ======================================================
-- (4) cleanup
DROP SERVICE google_search_job;
DROP SERVICE snowflake_job;
DROP SERVICE allow_all_job;

use role accountadmin;
alter compute pool cpu suspend;
describe compute pool cpu;

drop external access integration google_search_integration;
drop external access integration allow_all_integration;

drop network rule google_search_rule;
drop network rule allow_all_rule;