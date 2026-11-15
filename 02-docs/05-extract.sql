-- Value Extraction with AI_EXTRACT
-- for PNG/PDF staged docs with tables/forms
use test.public;

-- https://docs.snowflake.com/en/sql-reference/functions/extract_answer-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(review_content,
    'What dishes does this review mention?')
FROM reviews LIMIT 10;

-- entity extraction (individual key values) from text
select AI_EXTRACT(
    text => 'John Smith lives in San Francisco and works for Snowflake',
    responseFormat => {
        'name': 'What is the first name of the employee?',
        'city': 'What is the address of the employee?'}
) as json;
/*
{
  "response": { "city": "San Francisco", "name": "John" },
  "error": null
}
*/

-- entity extraction (individual key values) from file+table
select AI_EXTRACT(
    file => TO_FILE('@stage1', 'spool/inspection.png'),
    responseFormat => {
        'serial': 'What is the serial number?',
        'grade': 'What was the inspection grade?'
    },
    scores => TRUE
) as json;
/*
{
  "response": { "grade": "PASS", "serial": "SGMM-12345" },
  "scoring": { "scores": { "grade": { "score": 0.95 }, "serial": { "score": 0.95 } } },
  "error": null
}
*/

-- list extraction (extract list items)
select AI_EXTRACT(
  file => TO_FILE('@stage1', 'spool/inspection.pdf'),
  responseFormat => {
    'schema': {
      'type': 'object',
      'properties': {
        'items': {
          'description': 'What are the inspection items?',
          'type': 'array'
        } } } }
) as json;
/*
{
  "response": {
    "items": [
      "Injection Unit",
      "Mold Clamping Unit",
      "Hydraulic System",
      "Temperature Control System",
      "Ejector System",
      "Lubrication System",
      "Safety Devices",
      "Control Software"
    ]
  },
  "error": null
}
*/

-- table extraction (extract whole table)
select AI_EXTRACT(
  file => TO_FILE('@stage1', 'spool/inspection.pdf'),
  responseFormat => {
    'schema': {
      'type': 'object',
      'properties': {
        'top_table': {
          'description': 'Inspection results',
          'type': 'object',
          'properties': {
            'step': { 'description': 'Injection Unit', 'type': 'array' },
            'result': { 'description': 'Good', 'type': 'array' } },
          'column_ordering': ['step', 'result']
          } } } },
  scores => TRUE
) as json;
/*
{
  "response": {
    "top_table": {
      "result": [ "Good", "Good", "Good", "Good", "Good", "Good", "Good", "Good" ],
      "step": [ "Injection Unit", "Mold Clamping Unit", "Hydraulic System", "Temperature Control System", ... ]
    } },
  "scoring": { "scores": { "top_table": { "score": 0.95 } } },
  "error": null
}
*/

-- extract signature status
SELECT AI_EXTRACT(
    file => TO_FILE('@stage1', 'spool/inspection.pdf'),
    responseFormat => [['signature', 'Is this document signed?']]
) as json;
