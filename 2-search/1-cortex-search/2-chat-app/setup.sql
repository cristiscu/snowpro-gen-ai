CREATE DATABASE IF NOT EXISTS cortex_search_tutorial_db;

CREATE OR REPLACE WAREHOUSE cortex_search_tutorial_wh WITH
    WAREHOUSE_SIZE='X-SMALL'
    AUTO_SUSPEND = 120
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED=TRUE;

USE WAREHOUSE cortex_search_tutorial_wh;

-- to cleanup at the end
-- DROP DATABASE IF EXISTS cortex_search_tutorial_db;
-- DROP WAREHOUSE IF EXISTS cortex_search_tutorial_wh;

-- upload .data/BooksDatasetClean.csv in the stage below
-- https://www.kaggle.com/datasets/elvinrustam/books-dataset
CREATE OR REPLACE STAGE books_data_stage
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

CREATE TABLE cortex_search_tutorial_db.public.book_description_chunks AS (
    SELECT
        books.title,
        books.authors,
        books.category,
        books.publisher,
        books.title || '\n' || books.authors || '\n' || chunk_value.value AS CHUNK
    FROM cortex_search_tutorial_db.public.books_dataset_raw books,
        LATERAL FLATTEN(
            input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
                books.description,
                'none',
                2000,
                300
            )
        ) AS chunk_value
);

SELECT chunk, * FROM book_description_chunks LIMIT 10;

CREATE CORTEX SEARCH SERVICE cortex_search_tutorial_db.public.books_dataset_service
    ON CHUNK
    WAREHOUSE = cortex_search_tutorial_wh
    TARGET_LAG = '1 hour'
    AS (
        SELECT *
        FROM cortex_search_tutorial_db.public.book_description_chunks
    );

