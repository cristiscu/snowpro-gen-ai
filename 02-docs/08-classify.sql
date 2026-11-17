-- Classify text/image/doc into Categories
use test.public;

SELECT AI_CLASSIFY(
    'One day I will see the world',
    ['travel', 'cooking']
) as json;
/*
{ "labels": [ "travel" ] }
*/

SELECT AI_CLASSIFY(
    TO_FILE('@stage1', 'spool/inspection.pdf'),
    ['invoice', 'contract', 'lab_report', 'signed']
) as json;
/*
{ "labels": [ "lab_report" ] }
*/

SELECT AI_CLASSIFY(
    TO_FILE('@stage1', 'spool/inspection.png'),
    ['invoice', 'contract', 'lab_report', 'signed'],
    {'output_mode': 'multi'}
) as json;
/*
{ "labels": [ "lab_report", "signed" ]}
*/

-- with better instructions
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
/*
{ "labels": [ "travel", "cooking" ] }
*/

-- for multiple docs (PDFs)
SELECT RELATIVE_PATH, AI_CLASSIFY(
    TO_FILE('@stage1', RELATIVE_PATH),
    ['invoice', 'contract', 'lab_report']):labels[0]::STRING AS category
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.pdf';

-- legacy function (may not work in new accounts!)
SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    'One day I will see the world',
    ['travel', 'cooking']
) as json;
/*
{ "label": "travel" }
*/
