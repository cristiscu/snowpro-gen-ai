-- Tutorial 1 (inspired from): Build a simple search application with Cortex Search
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/tutorials/cortex-search-tutorial-1-search
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.airbnb;

-- download https://huggingface.co/datasets/MongoDB/airbnb_embeddings/blob/main/airbnb_embeddings.json
-- manually upload JSON file into a new airbnb_listings table, using the Snowsight wizard:
--    uncheck Load as a single variant column
--    uncheck the image_embeddings, images, and text_embeddings columns
--    change datatype of the amenities field to be ARRAY type

CREATE OR REPLACE CORTEX SEARCH SERVICE search
    ON listing_text
    ATTRIBUTES room_type, amenities
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 hour'
AS
    SELECT room_type, amenities, price, cancellation_policy,
        ('Summary\n\n' || summary || '\n\n\nDescription\n\n'
            || description || '\n\n\nSpace\n\n' || space) as listing_text
    FROM airbnb_listings;
DESC CORTEX SEARCH SERVICE search;

SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW('search',
    '{
        "query": "test query",
        "columns": ["listing_text"],
        "limit": 3
    }');
