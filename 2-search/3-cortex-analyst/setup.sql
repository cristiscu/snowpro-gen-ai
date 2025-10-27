-- create/select database objects
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.ts;
USE WAREHOUSE compute_wh;

CREATE OR REPLACE STAGE stage1
    DIRECTORY = (ENABLE = TRUE);

-- create tables
CREATE OR REPLACE TABLE daily_revenue (
    date DATE,
    revenue FLOAT,
    cogs FLOAT,
    forecasted_revenue FLOAT,
    product_id INT,
    region_id INT
);
CREATE OR REPLACE TABLE product_dim (
    product_id INT,
    product_line VARCHAR(16777216)
);
CREATE OR REPLACE TABLE region_dim (
    region_id INT,
    sales_region VARCHAR(16777216),
    state VARCHAR(16777216)
);

-- manually upload YAML + .data/ts/ CSV files into the new stage --> copy into tables
COPY INTO daily_revenue
FROM @stage1
FILES = ('daily_revenue.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY=NONE,
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
    EMPTY_FIELD_AS_NULL = FALSE
    error_on_column_count_mismatch=false
)
ON_ERROR=CONTINUE
FORCE=TRUE;

COPY INTO product_dim
FROM @stage1
FILES = ('product.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY=NONE,
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
    EMPTY_FIELD_AS_NULL = FALSE
    error_on_column_count_mismatch=false
)
ON_ERROR=CONTINUE
FORCE=TRUE;

COPY INTO region_dim
FROM @stage1
FILES = ('region.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY=NONE,
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
    EMPTY_FIELD_AS_NULL = FALSE
    error_on_column_count_mismatch=false
)
ON_ERROR=CONTINUE
FORCE=TRUE;

-- create a search service
CREATE OR REPLACE CORTEX SEARCH SERVICE ts_search
ON product_dimension
WAREHOUSE = compute_wh
TARGET_LAG = '1 hour'
AS (SELECT DISTINCT product_line AS product_dimension FROM product_dim);