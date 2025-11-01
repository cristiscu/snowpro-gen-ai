docker build --platform linux/amd64 -t genai-spcs .

docker tag genai-spcs:latest your-org-name-your-account-name.registry.snowflakecomputing.com/dash_db/dash_schema/dash_repo/genai-spcs:latest

docker login your-org-name-your-account-name.registry.snowflakecomputing.com

docker push your-org-name-your-account-name.registry.snowflakecomputing.com/dash_db/dash_schema/dash_repo/llm-spcs:latest
