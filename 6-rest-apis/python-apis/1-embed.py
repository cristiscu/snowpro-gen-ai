# Streamlit app w/ EMBED call through Snowflake Core API
# https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-rest-api#python-request-example

from snowflake.core import Root
from snowflake.snowpark.context import get_active_session
root = Root(get_active_session())

response = root.cortex_embed_service.embed(
    "e5-base-v2", ['This is a wonderful day indeed!'])
print(response)
