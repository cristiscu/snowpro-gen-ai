SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15) txt;

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 3) txt;

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 0, ['#', '\n']) txt;

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'markdown', 15) txt;

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
    '# This is\na wonderful day\n## indeed!',
    OBJECT_CONSTRUCT('#', 'H1', '##', 'H2', '###', 'H3'),
    15) txt;

-- =====================================================

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
