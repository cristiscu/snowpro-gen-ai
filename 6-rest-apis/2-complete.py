# Python API example
# https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-rest-api#python-api-example-request

from snowflake.snowpark import Session
from snowflake.cortex import Complete

session = Session.builder.configs(...).create()

stream = Complete(
  "mistral-7b",
  "What are unique features of the Snowflake SQL dialect?",
  session=session,
  stream=True)

for update in stream:
  print(update)
