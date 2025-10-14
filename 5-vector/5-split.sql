-- https://docs.snowflake.com/en/sql-reference/functions/split_text_recursive_character-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER (
   'hello world are you here',
   'none',
   15,
   10
);

-- Create sample markdown data table
CREATE OR REPLACE TABLE sample_documents (
   doc_id INT AUTOINCREMENT, -- Monotonically increasing integer
   document STRING
);

-- Insert sample data
INSERT INTO sample_documents (document)
VALUES
   ('### Heading 1\\nThis is a sample markdown document. It contains a list:\\n- Item 1\\n- Item 2\\n- Item 3\\n'),
   ('## Subheading\\nThis markdown contains a link [example](http://example.com) and some \**bold*\* text.'),
   ('### Heading 2\\nHere is a code snippet:\\n```\\ncode_block_here()\\n```\\nAnd some more regular text.'),
   ('## Another Subheading\\nMarkdown example with \_italic\_ text and a [second link](http://example.com).'),
   ('### Heading 3\\nText with an ordered list:\\n1. First item\\n2. Second item\\n3. Third item\\nMore text follows here.');

-- split text
SELECT
   doc_id,
   c.value
FROM
   sample_documents,
   LATERAL FLATTEN( input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER (
      document,
      'markdown',
      25,
      10
   )) c;

-- https://docs.snowflake.com/en/sql-reference/functions/split_text_markdown_header-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
  '# HEADER 1\nthis is text in header 1\n## HEADER 2\nthis is a subheading',
  OBJECT_CONSTRUCT('#', 'header_1', '##', 'header_2'),
  12,
  5
);

CREATE OR REPLACE TABLE markdown_docs (doc VARCHAR);

INSERT INTO markdown_docs VALUES
('# Product Overview\nOur system is a high-performance data processing engine.\n\n## Architecture\nIt uses a distributed design optimized for analytics.\n\n## Key Benefits\n- Scalable\n- Cost-efficient\n- Secure'),
('# User Guide\nThis guide describes how to install and use the product.\n\n## Installation\nFollow the steps below to install.\n\n## Usage\nOnce installed, use the CLI or UI for operations.'),
('# FAQ\nHere are answers to commonly asked questions.\n\n## Pricing\nWe offer flexible pricing models.\n\n## Support\nContact our 24/7 support team anytime.');


SELECT
    c.value['chunk']::varchar as chunk,
    c.value['headers']::object as headers,
FROM
    markdown_docs,
    LATERAL FLATTEN(
        SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
        doc,
        OBJECT_CONSTRUCT('#', 'header_1', '##', 'header_2'),
        20,
        5
    )
    ) c;
