-- SNOWFLAKE.CORTEX.COMPLETE, for text+images (multimodal)
-- https://docs.snowflake.com/en/sql-reference/functions/complete-snowflake-cortex
-- https://docs.snowflake.com/en/sql-reference/functions/complete-snowflake-cortex-multimodal

SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic', 'What are large language models?');

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'openai-gpt-4.1',
    CONCAT('Critique this review in bullet points: <review>', content, '</review>'))
FROM reviews
LIMIT 10;

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'claude-4-sonnet ',
    [
        {
            'role': 'user',
            'content': 'how does a snowflake get its unique pattern?'
        }
    ],
    {
        'temperature': 0.7,
        'max_tokens': 10
    }
);

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    [
        {
            'role': 'user',
            'content': <'Prompt that generates an unsafe response'>
        }
    ],
    {
        'guardrails': true
    }
);

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    [
        {'role': 'system', 'content': 'You are a helpful AI assistant. Analyze the movie review text and determine the overall sentiment. Answer with just \"Positive\", \"Negative\", or \"Neutral\"' },
        {'role': 'user', 'content': 'this was really good'}
    ], {}
) as response;

-- =============================================================================
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/complete-structured-outputs

SELECT AI_COMPLETE(
    model => 'mistral-large2',
    prompt => 'Return the customer sentiment for the following review: New kid on the block, this pizza joint! The pie arrived neither in a flash nor a snail\'s pace, but the taste? Divine! Like a symphony of Italian flavors, it was a party in my mouth. But alas, the party was a tad pricey for my humble abode\'s standards. A mixed bag, I\'d say!',
    response_format => {
            'type':'json',
            'schema':{'type' : 'object','properties' : {'sentiment_categories':{'type': 'object','properties':
            {'food_quality' : {'type' : 'string'},'food_taste': {'type':'string'}, 'wait_time': {'type':'string'}, 'food_cost': {'type':'string'}},'required':['food_quality','food_taste' ,'wait_time','food_cost']}}}

    }
);

SELECT AI_COMPLETE(
    model => 'mistral-large2',
    prompt => 'Return the customer sentiment for the following review: New kid on the block, this pizza joint! The pie arrived neither in a flash nor a snail\'s pace, but the taste? Divine! Like a symphony of Italian flavors, it was a party in my mouth. But alas, the party was a tad pricey for my humble abode\'s standards. A mixed bag, I\'d say!',
    response_format => {
            'type':'json',
            'schema':{'type' : 'object','properties' : {'sentiment_categories':{'type': 'object','properties':
            {'food_quality' : {'type' : 'string'},'food_taste': {'type':'string'}, 'wait_time': {'type':'string'}, 'food_cost': {'type':'string'}},'required':['food_quality','food_taste' ,'wait_time','food_cost']}}}

    }
    show_details => TRUE
);

-- =============================================================================
-- https://docs.snowflake.com/en/sql-reference/functions/try_complete-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.TRY_COMPLETE('snowflake-arctic', 'What are large language models?');

SELECT SNOWFLAKE.CORTEX.TRY_COMPLETE(
    'llama2-70b-chat',
    [
        {
            'role': 'user',
            'content': 'how does a snowflake get its unique pattern?'
        }
    ],
    {
        'temperature': 0.7,
        'max_tokens': 10
    }
);

