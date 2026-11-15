-- Value Extraction with AI_EXTRACT
-- for PNG/PDF staged docs with tables/forms
use test.public;

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
    file => TO_FILE('@db.schema.stage','document.pdf'),
    responseFormat => [['signature', 'Is this document signed?']]
);

-- Extraction using a fine-tuned arctic-extract model
-- https://docs.snowflake.com/en/sql-reference/functions/ai_extract#extraction-using-a-fine-tuned-arctic-extract-model
SELECT AI_EXTRACT(
  model => 'db.schema.my_tuned_model',
  file => TO_FILE('@db.schema.files','document.pdf')
);

SELECT AI_EXTRACT(
  model => 'db.schema.my_tuned_model',
  file => TO_FILE('@db.schema.files','document.pdf'),
  responseFormat => [['name', 'What is the first name of the employee?'], ['city', 'Where does the employee live?']]
);
