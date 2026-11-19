use test.public;

-- (re)create tables & copy data from stage
CREATE OR REPLACE TABLE daily_revenue (
    date DATE,
    revenue FLOAT,
    cogs FLOAT,
    forecasted_revenue FLOAT,
    product_id INT,
    region_id INT);
COPY INTO daily_revenue FROM @stage1
    FILES = ('spool/csv/daily_revenue.csv')
    FILE_FORMAT = (TYPE=CSV, SKIP_HEADER=1)
    FORCE=TRUE;

CREATE OR REPLACE TABLE region_dim (
    region_id INT,
    sales_region VARCHAR,
    state VARCHAR);
COPY INTO region_dim FROM @stage1
    FILES = ('spool/csv/region.csv')
    FILE_FORMAT = (TYPE=CSV, SKIP_HEADER=1)
    FORCE=TRUE;

CREATE OR REPLACE TABLE product_dim (
    product_id INT,
    product_line VARCHAR);
COPY INTO product_dim FROM @stage1
    FILES = ('spool/csv/product.csv')
    FILE_FORMAT = (TYPE=CSV, SKIP_HEADER=1)
    FORCE=TRUE;

CREATE OR REPLACE CORTEX SEARCH SERVICE search_analyst
    ON product_dimension
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 hour'
AS (SELECT DISTINCT product_line AS product_dimension
    FROM product_dim);