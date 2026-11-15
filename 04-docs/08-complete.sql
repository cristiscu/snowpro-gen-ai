-- AI_COMPLETE and PROMPT with documents
-- see text in https://markdownlivepreview.com/
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/ai-complete-document-intelligence
use test.public;

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

