-- Text Value Extraction with AI_EXTRACT
use test.public;

-- entity extraction (individual key values) from text
select AI_EXTRACT(
    text => 'John Smith lives in San Francisco and works for Snowflake',
    responseFormat => [
        'What is the first name of the employee?',
        'What is the address of the employee?' ]
) as json;
/*
{
  "response": {
    "What is the address of the employee?": "San Francisco",
    "What is the first name of the employee?": "John"
  },
  "error": null
}
*/

select AI_EXTRACT(
    text => 'John Smith lives in San Francisco and works for Snowflake',
    responseFormat => {
        'name': 'What is the first name of the employee?',
        'city': 'What is the address of the employee?'}
) as json;
/*
{
  "response": {
    "city": "San Francisco",
    "name": "John"
  },
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
  "response": { "serial": "SGMM-12345", "grade": "PASS" },
  "scoring": { "scores": {
    "grade": { "score": 0.95 },
    "serial": { "score": 0.95 }
  } },
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

-- ==============================================================================
-- SNOWFLAKE.CORTEX.EXTRACT_ANSWER (legacy function, you may get an error!)

select SNOWFLAKE.CORTEX.EXTRACT_ANSWER($$ I am a new customer for less than a year and I have never had to visit a branch this much in my lifetime. I've had my banking card locked THREE times for fraud. No fraudulent payments were made, nor anything else beside trying to put my card in my wallet on my phone. Since I live over an hour away from the nearest branch, they gave me a virtual appointment to unlock my card, and never gave my the joining code so I couldn't access it. I can't make any payments on my credit card because I can't access my online banking, so now they're adding interest to it. And as this is the third time my account was frozen for fraud, it has also been going on for TWO MONTHS. I'm canceling both my debit and credit cards ASAP when I can access a branch which I'll either have to miss work for as a contract worker, or go to my nearest city, carless, which is again over an hour away, 2 hours by bus, on the weekend.$$, 
    'why is this customer not paying his bills?') as json;
/*
[{
  "answer": "i can ' t make any payments on my credit card because i can ' t access my online banking",
  "score": 0.41426617
}]
*/

select SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    'John Smith lives in San Francisco and works for Snowflake',
    'What is the first name of the employee?') as json;
/*
[{
  "answer": "snowflake",
  "score": 4.310699700000000e-11
}]
*/

select SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    'John Smith lives in San Francisco and works for Snowflake',
    'What is the address of the employee?') as json;
/*
[{
  "answer": "san francisco",
  "score": 0.0000016968828
}]*/
