use test.public;

SELECT AI_CLASSIFY(
    'One day I will see the world',
    ['travel', 'cooking']
) as json;

SELECT AI_CLASSIFY(
    'One day I will see the world and learn to cook my favorite dishes',
    ['travel', 'cooking', 'reading', 'driving'],
    {'output_mode': 'multi'}
) as json;

SELECT AI_CLASSIFY(
    'One day I will see the world and learn to cook my favorite dishes',
    [
        {'label': 'travel', 'description': 'content related to traveling'},
        {'label': 'cooking'},
        {'label': 'reading'},
        {'label': 'driving'}
    ],{
        'task_description': 'Determine topics related to the given text',
        'output_mode': 'multi',
        'examples': [{
            'input': 'i love traveling with a good book',
            'labels': ['travel', 'reading'],
            'explanation': 'the text mentions traveling and a good book which relates to reading'
        }]
    }
) as json;

SELECT AI_CLASSIFY(
    TO_FILE(file_url),
    ['invoice', 'contract', 'lab_report']
) as json;

-- =============================================================================
-- multiple docs

-- classify documents
-- https://docs.snowflake.com/en/sql-reference/functions/ai_classify#ai_classify-documents
WITH staged_docs AS
    (SELECT TO_FILE(file_url) AS doc FROM DIRECTORY(@my_doc_stage))
SELECT doc, AI_CLASSIFY(doc,
    ['invoice', 'contract', 'lab_report']):labels AS classification
FROM staged_docs;

-- classify images from folder
-- https://docs.snowflake.com/en/sql-reference/functions/ai_classify#ai_classify-images
WITH food_pictures AS
    (SELECT TO_FILE(file_url) AS img FROM DIRECTORY(@file_stage))
SELECT *, AI_CLASSIFY(img,
    ['dessert', 'drink', 'main dish', 'side dish']):labels AS classification
FROM food_pictures;

WITH food_pictures AS (
    SELECT TO_FILE(file_url) AS img FROM DIRECTORY(@file_stage))
SELECT *, AI_CLASSIFY(
    PROMPT('Please help me classify the food within this image {0}', img),
    ['dessert', 'drink', 'main dish', 'side dish']):labels AS classification
FROM food_pictures;

-- classification from TABLE
-- https://docs.snowflake.com/en/sql-reference/functions/ai_classify#ai_classify-text
CREATE OR REPLACE TEMPORARY TABLE text_classification_table AS
SELECT 'France' AS input, ['North America', 'Europe', 'Asia'] AS classes
UNION ALL
SELECT 'Singapore', ['North America', 'Europe', 'Asia']
UNION ALL
SELECT 'one day I will see the world', ['travel', 'cooking', 'dancing']
UNION ALL
SELECT 'my lobster bisque is second to none', ['travel', 'cooking', 'dancing'];

SELECT input, classes,
    AI_CLASSIFY(input, classes):labels AS classification
FROM text_classification_table;

