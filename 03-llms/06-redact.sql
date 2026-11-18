-- AI_REDACT
use test.public;

-- don't stop on first error on multi-rows processing
-- ALTER SESSION SET AI_SQL_ERROR_HANDLING_USE_FAIL_ON_ERROR=FALSE;

-- redact mode (default) --> text
SELECT AI_REDACT('My name is William and I live in San Francisco. You can reach me at (415).450.0973') as txt;
/*
"My name is [NAME] and I live in [ADDRESS]. You can reach me at [PHONE_NUMBER]"
*/
-- detect mode --> JSON
SELECT AI_REDACT(
    input => 'My name is William and I live in San Francisco. You can reach me at (415).450.0973',
    mode => 'detect'
) AS json;
/*
[
  { "text": "William", "category": "NAME", "start": 11, "end": 18 },
  { "text": "San Francisco", "category": "ADDRESS", "start": 33, "end": 46 },
  { "text": "(415).450.0973", "category": "PHONE_NUMBER", "start": 68, "end": 82 }
]
*/

-- on tabular data, w/ sepected categories
WITH cte AS (
    SELECT 'My previous manager, Washington, used to live in Kirkland. His first name was Mike.' AS txt
    UNION ALL SELECT 'My name is William and I live in San Francisco. You can reach me at (415).450.0973')
SELECT AI_REDACT(txt, ['NAME', 'EMAIL', 'ADDRESS']) AS redact
FROM cte;
/*
"My previous manager, [NAME], used to live in [ADDRESS]. His first name was [NAME]."
"My name is [NAME] and I live in [ADDRESS]. You can reach me at (415).450.0973"
*/

-- returns detailed error, for unknown category ('ttt')
-- (use return_error_details => true, as last param for most AI functions)
WITH cte AS (
    SELECT 'My previous manager, Washington, used to live in Kirkland. His first name was Mike.' AS txt
    UNION ALL SELECT 'My name is William and I live in San Francisco. You can reach me at (415).450.0973')
SELECT AI_REDACT(txt, ['NAME', 'EMAIL', 'ADDRESS', 'ttt'], return_error_details => true) AS redact
FROM cte;
/*
{
  "value": null,
  "error": "Unsupported categories: TTT. Supported categories are: ADDRESS, AGE, DATE_OF_BIRTH, DRIVERS_LICENSE, EMAIL, GENDER, IP_ADDRESS, NAME, NATIONAL_ID, PASSPORT, PAYMENT_CARD_DATA, PHONE_NUMBER, TAX_IDENTIFIER."
}
*/
