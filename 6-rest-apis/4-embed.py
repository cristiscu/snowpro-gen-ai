# Python API example - EMBED
# https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-rest-api#python-request-example

from snowflake.core import Root
from snowflake.snowpark.context import get_active_session

def embed_service():
    # Initialize Snowflake session and root
    session = get_active_session()
    root = Root(session)

    # Send embed_request request and process response
    response = root.cortex_embed_service.embed("e5-base-v2", ['foo', 'bar'])
    print(response)

if __name__ == "__main__":
    embed_service()