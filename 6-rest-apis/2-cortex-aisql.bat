REM Replace with your own PAT and ACCT (as org-acct), then execute one by one in a PowerShell window
$PAT = "..."
$ACCT = "zyexmeq-kub68192"
$API = "https://$ACCT.snowflakecomputing.com/api/v2"

REM Test connection to Snowflake --> get database info in JSON
curl -X GET -H "Authorization: Bearer $PAT" "$API/databases"
curl --location "$API/databases" --header "Authorization: Bearer $PAT"

REM Cortex (LLM) REST API
REM https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-rest-api

REM Embed examples
curl --location "$API/cortex/inference:embed" `
    --header "Authorization: Bearer $PAT" `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json, text/event-stream' `
    --data '{"text": ["foo", "bar"], "model": "e5-base-v2"}'

REM Complete basic example
curl -X POST `
    -H "Authorization: Bearer $PAT" `
    -H 'Content-Type: application/json' `
    -H 'Accept: application/json, text/event-stream' `
    -d '{
      "model": "mistral-large",
      "messages": [{"content": "This is a wonderful day indeed!"}],
      "top_p": 0,
      "temperature": 0
    }' `
    "$API/cortex/inference:complete"

REM Complete tool calling with chain of thought
curl -X POST `
    -H "Authorization: Bearer $PAT" `
    -H 'Content-Type: application/json' `
    -H 'Accept: application/json, text/event-stream' `
    -d '{
      "model": "claude-3-5-sonnet",
      "messages": [{
          "role": "user",
          "content": "What is the weather like in San Francisco?"
        }],
      "tools": [{
          "tool_spec": {
            "type": "generic",
            "name": "get_weather",
            "input_schema": {
              "type": "object",
              "properties": {
                "location": {
                  "type": "string",
                  "description": "The city and state, e.g. San Francisco, CA"
                }
              },
              "required": ["location"]
            }
          }
        }],
      "max_tokens": 4096,
      "top_p": 1,
      "stream": true
    }' `
    "$API/cortex/inference:complete"

