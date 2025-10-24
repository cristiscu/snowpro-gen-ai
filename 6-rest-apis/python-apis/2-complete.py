# Local session w/ COMPLETE call through Snowflake Cortex API
# https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-rest-api#python-api-example-request

from snowflake.snowpark import Session
from snowflake.cortex import Complete
session = Session.builder.configs(...).create()

stream = Complete("mistral-7b", "This is a wonderful day indeed!", session=session, stream=True)
for update in stream:
    print(update)
