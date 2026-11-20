# OpenAI SDK compatibility
# https://docs.snowflake.com/en/user-guide/snowflake-cortex/open_ai_sdk

from openai import OpenAI

ACCT = "zyexmeq-kub68192"
API = f"https://{ACCT}.snowflakecomputing.com/api/v2"
PAT = "..."
client = OpenAI(base_url=f"{API}/cortex/v1", api_key=PAT)

# simple response
response = client.chat.completions.create(
    model="openai-gpt-5",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "This is a wonderful day indeed!"}
      ])
print(response.choices[0].message)

# streaming
response = client.chat.completions.create(
    model="openai-gpt-5",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "This is a wonderful day indeed!"}],
    stream=True)
for chunk in response:
    print(chunk.choices[0].delta.content, end="", flush=True)