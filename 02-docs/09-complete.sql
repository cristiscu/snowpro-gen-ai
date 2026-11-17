-- AI_COMPLETE and PROMPT with documents
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/ai-complete-document-intelligence
use test.public;

-- ===========================================================
-- PROMPT

SELECT PROMPT('What is the capital of {0} in {1}?',
    'Romania', 'Europe', 'Bucharest') as json;
/*
{
  "template": "What is the capital of {0} in {1}?"
  "args": [ "Romania", "Europe", "Bucharest" ],
}
*/

SELECT PROMPT('Help me classify the type of this document {0}',
    TO_FILE('@stage1', 'spool/inspection.pdf')) as json;
/*
{
  "template": "Help me classify the type of this document {0}",
  "args": [{
      "CONTENT_TYPE": "application/pdf",
      "ETAG": "3ac889654645c33a1ef654c970b8f4f1",
      "LAST_MODIFIED": "Mon, 16 Nov 2026 17:53:29 GMT",
      "RELATIVE_PATH": "spool/inspection.pdf",
      "SCOPED_FILE_URL": null,
      "SIZE": 304014,
      "STAGE": "@TEST.PUBLIC.STAGE1"
    }]
}
*/

SELECT RELATIVE_PATH, AI_CLASSIFY(
    TO_FILE('@stage1', RELATIVE_PATH),
    ['invoice', 'contract', 'lab_report']):labels[0]::STRING AS category
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.pdf';

SELECT RELATIVE_PATH, AI_CLASSIFY(PROMPT(
    'Help me classify the type of this document {0}',
    TO_FILE('@stage1', RELATIVE_PATH)),
    ['invoice', 'contract', 'lab_report']):labels[0]::STRING AS category
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.pdf';

-- ===========================================================
-- AI_COMPLETE on documents (with PROMPT) --> see in https://markdownlivepreview.com/

SELECT AI_COMPLETE(
    MODEL => 'gemini-3.1-pro',
    PROMPT => PROMPT('How many times is AI_PARSE_DOCUMENT mentioned in {0}?',
        TO_FILE('@stage1', 'spool/study-guide.pdf')))::STRING as response;

SELECT AI_COMPLETE(
    MODEL => 'claude-opus-5',
    PROMPT => PROMPT('summarize the requirements of Domain 3 in {0}',
        TO_FILE('@stage1', 'spool/study-guide.pdf')))::STRING as response;

SELECT AI_COMPLETE(
    MODEL => 'gemini-3.1-pro',
    PROMPT => PROMPT('What are the expectations from a candidate in {0}?',
        TO_FILE('@stage1', 'spool/study-guide.pdf')))::STRING as response;

SELECT AI_COMPLETE(
    MODEL => 'claude-sonnet-5',
    PROMPT => PROMPT('Sort the exam domains by their weightings from {0} and return them as a labeled bar chart',
        TO_FILE('@stage1', 'spool/study-guide.pdf')))::STRING as response;

