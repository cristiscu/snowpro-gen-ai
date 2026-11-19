-- Token Generation Functions
use SNOWFLAKE.CORTEX;

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    'This is a wonderful day indeed!',
    'none', 15) txt;

-- def separators = ['\n\n', '\n', ' ', ''] 
SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15) txt;

-- with overlap
SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 3) txt;

-- overwrite separators 
SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 0, ['#', '\n']) txt;

-- markdown format (instead of text)
SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'markdown', 15) txt;

-- based on markdown headers
SELECT SPLIT_TEXT_MARKDOWN_HEADER(
    '# This is\na wonderful day\n## indeed!',
    OBJECT_CONSTRUCT('#', 'H1', '##', 'H2', '###', 'H3'),
    15) txt;
