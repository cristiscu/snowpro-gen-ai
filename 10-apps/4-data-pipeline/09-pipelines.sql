use test.public;

-- ===================================================================
-- Classify multiple documents
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document#classify-multiple-documents
CREATE TABLE documents_table AS
(SELECT TO_FILE('@my_documents', RELATIVE_PATH) AS docs 
FROM DIRECTORY(@my_documents));
    
WITH single_page_extraction as (
    SELECT TO_VARCHAR (AI_PARSE_DOCUMENT(
        FL_FILTER_PAGES(docs, [{'end': 1}]),
        {'mode': 'LAYOUT', 'page_split': TRUE})
    ) AS first_page FROM documents_table)
SELECT AI_CLASSIFY(first_page,
  ['health', 'fitness','economics', 'science', 'psychology' ,
  'sociology','statistics', 'finance', 'Artificial Intelligence', 'Analytics'],
  {'output_mode': 'multi'}) as article_classification
FROM single_page_extraction;

-- ===================================================================
-- Extract and describe images
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document#extract-and-describe-images
SELECT AI_PARSE_DOCUMENT(
    TO_FILE('@my_stage', 'my_document.pdf'),
    {'mode': 'LAYOUT', 'extract_images': true})
AS layout_with_images;

SELECT AI_EXTRACT(
    file_data => BASE64_DECODE_BINARY(
        REGEXP_REPLACE((SELECT (AI_PARSE_DOCUMENT(
            TO_FILE('@image_docs', 'my_document.pdf'),
            {'mode': 'LAYOUT', 'extract_images': true}
        ):images[0]['image_base64']
    )::STRING),
    '^data:image/[^;]+;base64,', '')),
    responseFormat => {'Image Name': 'Describe the image'}
);

-- ===================================================================
CREATE OR REPLACE PROCEDURE SAVE_EXTRACTED_IMAGES(r VARIANT)
    RETURNS ARRAY
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    PACKAGES = ('pillow', 'snowflake-snowpark-python')
    HANDLER = 'run'
AS $$
import base64
import io
import os
import tempfile
from PIL import Image

def process_parse_document_result(data: dict) -> tuple[str, str, str]:
    images = data["images"]
    for image in images:
        id = image["id"]
        data, image_base64 = image["image_base64"].split(";", 1)
        extension = data.split("/")[1]
        base64 = image_base64.split(",")[1]
        yield id, extension, base64

def decode_base64(encoded_image: str) -> bytes:
    return base64.b64decode(encoded_image)

def run(session, r):
    destination_path = r["DESTINATION_PATH"]
    parse_document_result = r["PARSE_DOCUMENT_RESULT"]

    if not destination_path:
        return ["Error: destination_path parameter is required"]
    if not destination_path.startswith("@"):
        return ["Error: destination_path must start with @ (e.g. @output_stage/path"]
    if destination_path == "@":
        return ["Error: destination_path must include a stage name after @"]

    # Clean the result directory
    session.sql(f"RM destination_path")

    uploaded_files = []
    with tempfile.TemporaryDirectory() as temp_dir:
        for image_id, extension, encoded_image in process_parse_document_result(parse_document_result):
            image_bytes = decode_base64(encoded_image)
            image: Image = Image.open(io.BytesIO(image_bytes))

            image_path = os.path.join(temp_dir, image_id)
            image.save(image_path)

            session.file.put(
                image_path, destination_path, auto_compress=False, overwrite=True
            )
            uploaded_files.append(f"{destination_path}/{image_id}")

            os.remove(image_path)
    return uploaded_files
$$;

CALL SAVE_EXTRACTED_IMAGES((
    SELECT OBJECT_CONSTRUCT(*)
    FROM ( SELECT
        '@image_docs/output' as destination_path,
        AI_PARSE_DOCUMENT(
            TO_FILE('@image_docs/my_document.pdf'),
            {'mode': 'LAYOUT', 'extract_images': true}
        ) as parse_document_result
    ) LIMIT 1
));

SELECT AI_COMPLETE(
    'pixtral-large',
    'Describe the image in 10 words.',
    TO_FILE('@image_docs/output/img-0.jpeg')
);

-- ===================================================================
-- Call transcript analysis
-- AI_TRANSCRIBE --> AI_SENTIMENT/AI_COMPLETE
-- https://docs.snowflake.com/en/sql-reference/functions/ai_transcribe#call-transcript-analysis
WITH transcriptions AS
    (SELECT TO_VARCHAR(AI_TRANSCRIBE(
        TO_FILE('@financial_consultation', 'consultation_1.wav'))) AS transcribed_call )
SELECT
    AI_SENTIMENT(transcribed_call,
        ['Professionalism', 'Resolution', 'Wait Time', 'Market Conditions']) AS call_sentiment,
    AI_COMPLETE('claude-sonnet-5',
        CONCAT('Summarize how the agent can improve in 50 words', transcribed_call)) AS agent_assessment
FROM transcriptions;
