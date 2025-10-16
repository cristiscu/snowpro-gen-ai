# Stream responses
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/open_ai_sdk#stream-responses

from openai import OpenAI

client = OpenAI(
  api_key="<SNOWFLAKE_PAT>",
  base_url="https://<account-identifier>.snowflakecomputing.com/api/v2/cortex/v1"
)

response = client.chat.completions.create(
  model="<model_name>",
  messages=[
    {"role": "system", "content": "You are a helpful assistant."},
    {
        "role": "user",
        "content": "How does a snowflake get its unique pattern?"
    }
  ],
  stream=True
)

for chunk in response:
    print(chunk.choices[0].delta.content, end="", flush=True)