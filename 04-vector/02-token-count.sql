-- Token Count Estimates
SET txt = 'This is a wonderful day indeed!';

SELECT AI_COMPLETE('llama3.1-70b', $txt) AS result;
SELECT AI_COUNT_TOKENS('ai_complete', 'llama3.1-70b', $txt) AS tokens;

SELECT AI_SENTIMENT($txt) AS result;
SELECT AI_COUNT_TOKENS('ai_sentiment', $txt) AS tokens;

SELECT AI_CLASSIFY($txt, [{'label': 'humour'}, {'label': 'exercising'}]) AS result;
SELECT AI_COUNT_TOKENS('ai_classify', $txt [{'label': 'humour'}, {'label': 'exercising'}]) AS tokens;

-- ===================================================================
-- legacy (may not work on some accounts)

SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS(
    'llama3.1-70b',
    'This is a wonderful day indeed!'
) AS tokens;

SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS(
    'summarize',
    'This is a wonderful day indeed!'
) AS tokens;
