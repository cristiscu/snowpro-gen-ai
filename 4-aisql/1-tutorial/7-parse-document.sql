-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document

CREATE OR REPLACE STAGE input_stage
    DIRECTORY = ( ENABLE = true )
    ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );

CREATE OR REPLACE STAGE input_stage
    URL='s3://<s3-path>/'
    CREDENTIALS=(AWS_KEY_ID=<aws_key_id>
    AWS_SECRET_KEY=<aws_secret_key>)
    ENCRYPTION=( TYPE = 'AWS_SSE_S3' );

SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@docs.doc_stage','research-paper-example.pdf'),
    {'mode': 'LAYOUT' , 'page_split': true}) AS research_paper_example;

SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@docs.doc_stage','10K-example.pdf'),
    {'mode': 'LAYOUT', 'page_split': true}) AS sec_10k_example;

SELECT AI_PARSE_DOCUMENT (TO_FILE('@docs.doc_stage','presentation.pptx'),
    {'mode': 'LAYOUT' , 'page_split': true}) as presentation_output;

SELECT AI_PARSE_DOCUMENT (TO_FILE('@docs.doc_stage','german_example.pdf'),
    {'mode': 'LAYOUT'}) AS german_article;

SNOWFLAKE.CORTEX.TRANSLATE (ger_example, '', 'en') from german_article;

-- ========================================================================

SELECT TO_VARCHAR(
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        '@PARSE_DOCUMENT.DEMO.documents',
        'document_1.pdf',
        {'mode': 'OCR'})
    ) AS OCR;

SELECT AI_PARSE_DOCUMENT(
  TO_FILE('@my_documents', 'ResearchArticle.pdf'),
  {'mode': 'LAYOUT', 'page_filter': [{'start': 0, 'end': 1}]} );

CREATE TABLE documents_table AS
  (SELECT TO_FILE('@my_documents', RELATIVE_PATH)
    AS docs FROM DIRECTORY(@my_documents));

WITH single_page_extraction as (
  SELECT
  TO_VARCHAR (AI_PARSE_DOCUMENT(docs, {'mode': 'LAYOUT',
    'page_filter': [{'start': 0, 'end': 1}]} )) AS first_page FROM documents_table);
SELECT AI_CLASSIFY(
  first_page,
  ['health', 'fitness','economics', 'science', 'psychology' ,'sociology','statistics', 'finance', 'Artificial Intelligence', 'Analytics'],
  {'output_mode': 'multi'} ) as article_classification
FROM single_page_extraction;