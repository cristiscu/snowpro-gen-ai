-- CORTEX_FINE_TUNING_USAGE_HISTORY
-- = number of tokens processed and the training credits consumed
-- by Cortex Fine-tuning jobs, aggregated by the job’s base model
-- and the hour in which the job completed.
select * 
from snowflake.account_usage.CORTEX_FINE_TUNING_USAGE_HISTORY;

-- CORTEX_SEARCH_DAILY_USAGE_HISTORY
-- = daily usage history of Cortex Search, with consumption broken out by category.
select * 
from snowflake.account_usage.CORTEX_SEARCH_DAILY_USAGE_HISTORY;

-- CORTEX_SEARCH_SERVING_USAGE_HISTORY
-- = hourly serving usage history of Cortex Search.
select * 
from snowflake.account_usage.CORTEX_SEARCH_SERVING_USAGE_HISTORY;

-- CORTEX_ANALYST_USAGE_HISTORY
-- = number of credits consumed each time Cortex Analyst is called,
-- aggregated in one-hour increments.
select * 
from snowflake.account_usage.CORTEX_ANALYST_USAGE_HISTORY;

-- CORTEX_DOCUMENT_PROCESSING_USAGE_HISTORY
-- = pages processed and credits used, aggregated hourly by function and model.
select * 
from snowflake.account_usage.CORTEX_DOCUMENT_PROCESSING_USAGE_HISTORY;

-- CORTEX_FUNCTIONS_USAGE_HISTORY
-- = number of tokens and credits consumed each time a Cortex Function is called, 
-- aggregated in one hour increments based on function and model.
select * 
from snowflake.account_usage.CORTEX_FUNCTIONS_USAGE_HISTORY;

-- CORTEX_FUNCTIONS_QUERY_USAGE_HISTORY
-- = number of tokens and credits consumed for each query.
select * 
from snowflake.account_usage.CORTEX_FUNCTIONS_QUERY_USAGE_HISTORY;

-- METERING_DAILY_HISTORY
-- = daily credit usage and a cloud services rebate
-- for an account within the last 365 days (1 year).
select * 
from snowflake.account_usage.METERING_DAILY_HISTORY;

-- CORTEX_PROVISIONED_THROUGHPUT_USAGE_HISTORY
-- = billing data for provisioned throughputs.
select * 
from snowflake.account_usage.CORTEX_PROVISIONED_THROUGHPUT_USAGE_HISTORY;
