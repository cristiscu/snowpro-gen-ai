-- Token Generation Functions
use SNOWFLAKE.CORTEX;

-- ============================================================
-- SPLIT_TEXT_RECURSIVE_CHARACTER

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    'This is a wonderful day indeed!',
    'none', 15) txt;

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15) txt;

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 3) txt;

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'none', 15, 0, ['#', '\n']) txt;

SELECT SPLIT_TEXT_RECURSIVE_CHARACTER(
    '# This is\na wonderful day\n## indeed!',
    'markdown', 15) txt;

-- ============================================================
-- SPLIT_TEXT_MARKDOWN_HEADER

SELECT SPLIT_TEXT_MARKDOWN_HEADER(
    '# This is\na wonderful day\n## indeed!',
    OBJECT_CONSTRUCT('#', 'H1', '##', 'H2', '###', 'H3'),
    15) txt;
