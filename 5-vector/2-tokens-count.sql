SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS(
    'llama3.1-70b',
    'This is a wonderful day indeed!');

SELECT SNOWFLAKE.CORTEX.SENTIMENT(
    'This is a wonderful day indeed!');

SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS(
    'sentiment',
    'This is a wonderful day indeed!');

SELECT AI_COMPLETE(
    'llama3.1-70b',
    'This is a wonderful day indeed!');

SELECT AI_COUNT_TOKENS(
    'ai_complete',
    'llama3.1-70b',
    'This is a wonderful day indeed!');

SELECT AI_CLASSIFY(
    'This is a wonderful day indeed!',
    [{'label': 'humour'}, {'label': 'exercising'}]);

SELECT AI_COUNT_TOKENS(
    'ai_classify',
    'This is a wonderful day indeed!',
    [{'label': 'humour'}, {'label': 'exercising'}]);
