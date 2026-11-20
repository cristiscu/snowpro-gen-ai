-- Query a service with managed vector embeddings
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#query-a-service-with-managed-vector-embeddings
USE test.public;

CREATE OR REPLACE TABLE business_dir(name TEXT, address TEXT, descr TEXT);
INSERT INTO business_dir VALUES
    ('Joe''s Coffee', '123 Bean St, Brewtown','A cozy café known for artisan espresso and baked goods.'),
    ('Sparkle Wash', '456 Clean Ave, Sudsville', 'Eco-friendly car wash with free vacuum service.'),
    ('Tech Haven', '789 Circuit Blvd, Siliconia', 'Computer store offering the latest gadgets and tech repair services.'),
    ('Joe''s Wash n'' Fold', '456 Apple Ct, Sudsville', 'Laundromat offering coin laundry and premium wash and fold services.'),
    ('Circuit Town', '459 Electron Dr, Sudsville', 'Technology store selling used computer parts at discounted prices.');
SELECT * FROM business_dir;

CREATE OR REPLACE CORTEX SEARCH SERVICE search_dir
    TEXT INDEXES name, address
    VECTOR INDEXES descr (model='snowflake-arctic-embed-m-v1.5')
    WAREHOUSE = compute_wh
    TARGET_LAG = '1 hour'
AS SELECT * FROM business_dir;

SELECT value['name']::text as name,
    value['address']::text as address,
    value['descr']::text as descr
FROM TABLE(FLATTEN(PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'search_dir',
      '{
            "query": "tech repair shop",
            "columns": ["name", "descr"],
            "limit": 2
      }'
  ))['results']));

SELECT value['name']::text as name,
    value['address']::text as address,
    value['descr']::text as descr
FROM TABLE(FLATTEN(PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'search_dir',
        '{
          "multi_index_query": {"descr": [{"text": "refurbished components for PCs"}]},
          "columns": ["name", "address", "descr"],
          "limit": 5
        }'
    )
)['results']));

SELECT value['name']::text as name,
    value['address']::text as address,
    value['descr']::text as descr
FROM TABLE(FLATTEN(PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'search_dir',
        '{
            "multi_index_query": {
                "name": [{"text": "sparkle"}],
                "descr": [{"text": "clothing washing"}]
            },
            "scoring_config": {
                "weights": {
                    "texts": 1,
                    "vectors": 4,
                    "reranker": 1
                }
            },
          "columns": ["name", "address", "descr"],
          "limit": 2
        }'
    )
)['results']));

SELECT value['name']::text as name,
    value['address']::text as address,
    value['descr']::text as descr
FROM TABLE(FLATTEN(PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'search_dir',
        '{
            "multi_index_query": {
                "name":     [ {"text": "circuit"} ],
                "address":  [ {"text": "circuit"} ],
                "descr":    [ {"text": "circuit"} ]
            },
            "scoring_config": {
                "functions": {
                    "text_boosts": [
                        {"column":"name", "weight": 2}, 
                        {"column":"address", "weight": 1}
                    ]
                }
            },
            "columns": ["name", "address", "descr"],
            "limit": 3
        }'
    )
)['results']));

ALTER CORTEX SEARCH SERVICE search_dir SUSPEND;
