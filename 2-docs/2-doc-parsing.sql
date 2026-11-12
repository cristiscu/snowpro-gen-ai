-- Document Parsing Functions
use test.public;

list @stage1;

SELECT AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'docs/research-paper-example.pdf'),
    {'mode': 'LAYOUT' , 'page_split': true}) AS doc;