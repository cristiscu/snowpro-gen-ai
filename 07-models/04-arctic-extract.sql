-- Extraction using a fine-tuned arctic-extract model
-- https://docs.snowflake.com/en/sql-reference/functions/ai_extract#extraction-using-a-fine-tuned-arctic-extract-model
use test.public;

SELECT AI_EXTRACT(
    model => 'db.schema.my_tuned_model',
    file => TO_FILE('@stage1', 'spool/inspection.pdf'));

SELECT AI_EXTRACT(
    model => 'db.schema.my_tuned_model',
    file => TO_FILE('@stage1', 'spool/inspection.pdf'),
    responseFormat => [['name', 'What is the first name of the employee?'], ['city', 'Where does the employee live?']]);
