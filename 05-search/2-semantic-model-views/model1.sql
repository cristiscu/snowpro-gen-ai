-- SEMANTIC_VIEW
-- https://docs.snowflake.com/en/sql-reference/constructs/semantic_view

CREATE SEMANTIC VIEW tpch_rev_analysis

  TABLES (
    orders AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
      PRIMARY KEY (o_orderkey)
      WITH SYNONYMS ('sales orders')
      COMMENT = 'All orders table for the sales domain',
    customers AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
      PRIMARY KEY (c_custkey)
      COMMENT = 'Main table for customer data',
    line_items AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
      PRIMARY KEY (l_orderkey, l_linenumber)
      COMMENT = 'Line items in orders'
  )

  RELATIONSHIPS (
    orders_to_customers AS
      orders (o_custkey) REFERENCES customers,
    line_item_to_orders AS
      line_items (l_orderkey) REFERENCES orders
  )

  FACTS (
    line_items.line_item_id AS CONCAT(l_orderkey, '-', l_linenumber),
    orders.count_line_items AS COUNT(line_items.line_item_id),
    line_items.discounted_price AS l_extendedprice * (1 - l_discount)
      COMMENT = 'Extended price after discount'
  )

  DIMENSIONS (
    customers.customer_name AS customers.c_name
      WITH SYNONYMS = ('customer name')
      COMMENT = 'Name of the customer',
    orders.order_date AS o_orderdate
      COMMENT = 'Date when the order was placed',
    orders.order_year AS YEAR(o_orderdate)
      COMMENT = 'Year when the order was placed'
  )

  METRICS (
    customers.customer_count AS COUNT(c_custkey)
      COMMENT = 'Count of number of customers',
    orders.order_average_value AS AVG(orders.o_totalprice)
      COMMENT = 'Average order value across all orders',
    orders.average_line_items_per_order AS AVG(orders.count_line_items)
      COMMENT = 'Average number of line items per order'
  )

  COMMENT = 'Semantic view for revenue analysis';

SELECT * FROM SEMANTIC_VIEW(
    tpch_analysis
    DIMENSIONS customer.customer_market_segment
    METRICS orders.order_average_value
  )
  ORDER BY customer_market_segment;
  
-- ===========================================================================

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'my_db.my_schema',
  $$
  name: TPCH_REV_ANALYSIS
  description: Semantic view for revenue analysis
  tables:
    - name: CUSTOMERS
      description: Main table for customer data
      base_table:
        database: SNOWFLAKE_SAMPLE_DATA
        schema: TPCH_SF1
        table: CUSTOMER
      primary_key:
        columns:
          - C_CUSTKEY
      dimensions:
        - name: CUSTOMER_NAME
          synonyms:
            - customer name
          description: Name of the customer
          expr: customers.c_name
          data_type: VARCHAR(25)
        - name: C_CUSTKEY
          expr: C_CUSTKEY
          data_type: VARCHAR(134217728)
      metrics:
        - name: CUSTOMER_COUNT
          description: Count of number of customers
          expr: COUNT(c_custkey)
    - name: LINE_ITEMS
      description: Line items in orders
      base_table:
        database: SNOWFLAKE_SAMPLE_DATA
        schema: TPCH_SF1
        table: LINEITEM
      primary_key:
        columns:
          - L_ORDERKEY
          - L_LINENUMBER
      dimensions:
        - name: L_ORDERKEY
          expr: L_ORDERKEY
          data_type: VARCHAR(134217728)
        - name: L_LINENUMBER
          expr: L_LINENUMBER
          data_type: VARCHAR(134217728)
      facts:
        - name: DISCOUNTED_PRICE
          description: Extended price after discount
          expr: l_extendedprice * (1 - l_discount)
          data_type: "NUMBER(25,4)"
        - name: LINE_ITEM_ID
          expr: "CONCAT(l_orderkey, '-', l_linenumber)"
          data_type: VARCHAR(134217728)
    - name: ORDERS
      synonyms:
        - sales orders
      description: All orders table for the sales domain
      base_table:
        database: SNOWFLAKE_SAMPLE_DATA
        schema: TPCH_SF1
        table: ORDERS
      primary_key:
        columns:
          - O_ORDERKEY
      dimensions:
        - name: ORDER_DATE
          description: Date when the order was placed
          expr: o_orderdate
          data_type: DATE
        - name: ORDER_YEAR
          description: Year when the order was placed
          expr: YEAR(o_orderdate)
          data_type: "NUMBER(4,0)"
        - name: O_ORDERKEY
          expr: O_ORDERKEY
          data_type: VARCHAR(134217728)
        - name: O_CUSTKEY
          expr: O_CUSTKEY
          data_type: VARCHAR(134217728)
      facts:
        - name: COUNT_LINE_ITEMS
          expr: COUNT(line_items.line_item_id)
          data_type: "NUMBER(18,0)"
      metrics:
        - name: AVERAGE_LINE_ITEMS_PER_ORDER
          description: Average number of line items per order
          expr: AVG(orders.count_line_items)
        - name: ORDER_AVERAGE_VALUE
          description: Average order value across all orders
          expr: AVG(orders.o_totalprice)
  relationships:
    - name: LINE_ITEM_TO_ORDERS
      left_table: LINE_ITEMS
      right_table: ORDERS
      relationship_columns:
        - left_column: L_ORDERKEY
          right_column: O_ORDERKEY
      relationship_type: many_to_one
    - name: ORDERS_TO_CUSTOMERS
      left_table: ORDERS
      right_table: CUSTOMERS
      relationship_columns:
        - left_column: O_CUSTKEY
          right_column: C_CUSTKEY
      relationship_type: many_to_one
  $$,
TRUE);