-- Multimodal AI_COMPLETE
use test.public;

-- single-string input
SELECT AI_COMPLETE('mistral-7b', 'President of Egypt') AS response;

-- single-string input, but on tabular data
SELECT N_NAME AS country,
    AI_COMPLETE('llama3.3-70b', 'President of ' || N_NAME) AS president
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
LIMIT 5;

-- single-string input with model options/parameters (eventually truncated!)
SELECT AI_COMPLETE(
    model => 'openai-gpt-5.4',
    prompt => 'President of Egypt',
    model_parameters => { 'temperature': 0.7, 'max_tokens': 10, 'guardrails': true }
) as json;

-- ====================================================================
-- Structured Outputs
-- https://docs.snowflake.com/en/sql-reference/functions/ai_complete-structured-outputs

-- show_details=true
SELECT AI_COMPLETE(
    model => 'openai-gpt-5.4',
    prompt => 'President of Egypt',
    model_parameters => { 'temperature': 0.7, 'max_tokens': 10, 'guardrails': true },
    show_details => true
) as json;
/*
{
  "choices": [{ "messages": "..." }],
  "created": 1794998668,
  "model": "openai-gpt-5.4",
  "usage": {
    "completion_tokens": 10,
    "prompt_tokens": 9,
    "total_tokens": 19
  }
}
*/

-- show_details=false + response_format as SQL type literal
SELECT AI_COMPLETE(
    model => 'gemini-3.1-pro',
    prompt => 'Extract structured data from this customer interaction note: Sarah Jones complained about the mobile app crashing during checkout. She tried to purchase 3 items: a red XL jacket ($89.99), blue running shoes ($129.50), and a fitness tracker ($199.00). She has been a premium member since January 2024.',
    model_parameters => { 'temperature': 0, 'max_tokens': 4096 },
    response_format => TYPE OBJECT(note OBJECT(price ARRAY(STRING), member_date STRING))
) as json;
/*
{
  "note": {
    "member_date": "January 2024",
    "price": [ "89.99", "129.50", "199.00" ]
  }
}
*/

-- show_details=true + response_format as JSON schema --> "structured_output"
SELECT AI_COMPLETE(
    model => 'gemini-3.1-pro',
    prompt => 'Extract structured data from this customer interaction note: Sarah Jones complained about the mobile app crashing during checkout. She tried to purchase 3 items: a red XL jacket ($89.99), blue running shoes ($129.50), and a fitness tracker ($199.00). She has been a premium member since January 2024.',
    model_parameters => { 'temperature': 0, 'max_tokens': 4096 },
    response_format => TYPE OBJECT(note OBJECT(price ARRAY(STRING), member_date STRING))
) as json;

SELECT AI_COMPLETE(
    model => 'claude-haiku-4-5',
    prompt => 'Extract structured data from this customer interaction note: Sarah Jones complained about the mobile app crashing during checkout. She tried to purchase 3 items: a red XL jacket ($89.99), blue running shoes ($129.50), and a fitness tracker ($199.00). She has been a premium member since January 2024.',
    model_parameters => { 'temperature': 0, 'max_tokens': 4096 },
    response_format => {
        'type': 'json',
        'schema': {
            'type': 'object',
            'properties': {'note': {
                'type':'object','properties': {
                    'price': {'type':'array', 'items': {'type':'string'}},
                    'member_date': {'type': 'string'}
                }, 'required':['price', 'member_date']}}}},
    show_details => true
);
/*
{
  "created": 1794999440,
  "model": "claude-haiku-4-5",
  "structured_output": [{
      "type": "json",
      "raw_message": {
        "note": {
          "member_date": "January 2024",
          "price": [ "$89.99", "$129.50", "$199.00" ]
        }}}],
  "usage": {
    "completion_tokens": 68,
    "prompt_tokens": 752,
    "total_tokens": 820
  }
}
*/

-- ====================================================================
-- multimodal AI_COMPLETE (on files)

-- with FILE (from TO_FILE call) --> markdown!
SELECT AI_COMPLETE(
    'pixtral-large',
    'Is this document signed?',
    TO_FILE('@stage1', 'spool/inspection.png')
)::STRING AS response;
/*
Yes, the document is signed by Emily Johnson. The signature is located at the bottom left of the document, next to the printed name "Emily Johnson." The date of the inspection, "2022-11-01," is also noted next to the signature.
 */

-- with PROMPT (for 1+ FILE objects) --> markdown!
SELECT AI_COMPLETE(
    'pixtral-large',
    PROMPT('Are these two documents {0} and {1} signed?',
        TO_FILE('@stage1', 'spool/inspection.png'),
        TO_FILE('@stage1', 'spool/inspection.png'))
)::STRING AS response;
/*
The two documents appear to be identical and both have a signature at the bottom. The name "Emily Johnson" is written in cursive, and there is a date "2022-11-01" next to the signature. This indicates that both documents have been signed by Emily Johnson.

However, it's important to note that without additional context or verification, it's impossible to confirm the authenticity of the signature or the identity of the signer. If you need to verify the authenticity of the signature, you may need to compare it with a known sample of Emily Johnson's signature or use other verification methods.
*/

-- on multiple files/tabular data
SELECT RELATIVE_PATH, AI_COMPLETE(
    'gemini-3.1-pro',
    PROMPT('Classify the input image {0} in no more than 2 words.',
        TO_FILE('@stage1', RELATIVE_PATH)))::STRING as category
FROM DIRECTORY(@stage1)
WHERE RELATIVE_PATH like '%.png';

-- ====================================================================
-- legacy SNOWFLAKE.CORTEX.COMPLETE (may not work on some accounts)

-- simple model+prompt (question) --> text answer
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
    'President of Egypt'
) AS response;

-- simple question-answer, but on tabular data
SELECT N_NAME AS country,
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.3-70b', 
        'President of ' || N_NAME
) AS president
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
LIMIT 5;

-- complex history(array) + options (required) format
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
    [{ 'role': 'user', 'content': 'President of Egypt' }],
    { }
) AS json;
/*
{
  "choices": [{ "messages": "..." } ],
  "created": 1794997117,
  "model": "mistral-7b",
  "usage": {
    "completion_tokens": 234,
    "prompt_tokens": 15,
    "total_tokens": 249
  }
}
*/

-- a more complex history+options example
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', [
        { 'role': 'system', 'content': 'You are a concise Snowflake SQL assistant.' },
        { 'role': 'user', 'content': 'How do I list all warehouses?' },
        { 'role': 'assistant', 'content': 'Run SHOW WAREHOUSES; in your worksheet.' },
        { 'role': 'user', 'content': 'How do I filter that to only active ones?' }
    ], { 'temperature': 0.2, 'max_tokens': 500, 'guardrails': true }
) AS response;
/*
{
  "choices": [ { "messages": "..." } ],
  "created": 1794996912,
  "model": "mistral-7b",
  "usage": {
    "completion_tokens": 25,
    "prompt_tokens": 62,
    "total_tokens": 87
  }
}*/

-- multimodal COMPLETE with FILE
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'pixtral-large',
    'Is this document signed?',
    TO_FILE('@stage1', 'spool/inspection.png')
) AS response;
/*
Yes, the document is signed by Emily Johnson. The signature is located at the bottom left of the document, next to the printed name "Emily Johnson." The date of the inspection, "2022-11-01," is also noted next to the signature.
*/

-- multimodal COMPLETE with PROMPT
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'pixtral-large',
    PROMPT('Are these two documents {0} and {1} signed?',
        TO_FILE('@stage1', 'spool/inspection.png'),
        TO_FILE('@stage1', 'spool/inspection.png'))
) AS response;
/*
The two documents appear to be identical and are both signed. The signature is located at the bottom left of each document, with the name "Emily Johnson" written in cursive. The date of inspection is also handwritten next to the signature, reading "2022-11-01." Both the signature and the date indicate that the documents have been signed and dated by the inspector.
*/
