REM Replace with your own PAT and ACCT (as org-acct), then execute one by one in a PowerShell window
$PAT = "..."
$ACCT = "zyexmeq-kub68192"
$API = "https://$ACCT.snowflakecomputing.com/api/v2"
$SEARCH = "$API/databases/test/schemas/search/cortex-search-services/search:query"

REM Named scoring profiles
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#named-scoring-profiles
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "technology",
      "columns": ["DOCUMENT_CONTENTS", "LIKES", "COMMENTS"],
      "scoring_profile": "heavy_comments_with_likes,
      "limit": 10
    }'

REM Filter Example - Simple query with an equality filter
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#filter-examples
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "technology",
      "columns": ["DOCUMENT_CONTENTS", "LIKES"],
      "filter": {"@eq": {"REGION": "US"}},
      "limit": 5
    }'

REM Filter Example - Range filter
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#range-filter
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "business",
      "columns": ["DOCUMENT_CONTENTS", "LIKES", "COMMENTS"],
      "filter": {"@and": [
        {"@gte": {"LIKES": 50}},
        {"@lte": {"COMMENTS": 50}}
      ]},
      "limit": 10
    }'

REM Scoring examples - Numeric Boost
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#scoring-examples
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "technology",
      "columns": ["DOCUMENT_CONTENTS", "LIKES", "COMMENTS"],
      "scoring_config": {
        "functions": {
          "numeric_boosts": [
            {"column": "comments", "weight": 2},
            {"column": "likes", "weight": 1}
          ]
        }
      }
    }'

REM Scoring examples - Time Decay
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#time-decays
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "technology",
      "columns": ["DOCUMENT_CONTENTS", "LAST_MODIFIED_TIMESTAMP"],
      "scoring_config": {
        "functions": {
          "time_decays": [{
            "column": "LAST_MODIFIED_TIMESTAMP",
            "weight": 1,
            "limit_hours": 240,
            "now": "2024-04-23T00:00:00.000-08:00"}]
        }
      }
    }'

REM Scoring examples - Disabling reranking
REM https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#disabling-reranking
curl --location $SEARCH `
    --header 'Content-Type: application/json' `
    --header 'Accept: application/json' `
    --header "Authorization: Bearer $PAT" `
    --data '{
      "query": "technology",
      "columns": ["DOCUMENT_CONTENTS", "LAST_MODIFIED_TIMESTAMP"],
      "scoring_config": {"reranker": "none"}
    }'
