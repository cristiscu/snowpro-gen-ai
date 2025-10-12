-- Snowflake Copilot AI assistant

-- set db+schema in worksheet
-- https://docs.snowflake.com/en/user-guide/sample-data-tpch
use schema snowflake_sample_data.tpch_sf1;

/*
Generate a query that "lists totals for extended price, discounted extended price,
discounted extended price plus tax, average quantity, average extended price,
and average discount. These aggregates are grouped by RETURNFLAG and LINESTATUS,
and listed in ascending order of RETURNFLAG and LINESTATUS.
A count of the number of line items in each group is included."
*/

-- can you explain this query? can you optimize this query? 
-- add follow-up questions. thumb up/down
select
       l_returnflag,
       l_linestatus,
       sum(l_quantity) as sum_qty,
       sum(l_extendedprice) as sum_base_price,
       sum(l_extendedprice * (1-l_discount)) as sum_disc_price,
       sum(l_extendedprice * (1-l_discount) * (1+l_tax)) as sum_charge,
       avg(l_quantity) as avg_qty,
       avg(l_extendedprice) as avg_price,
       avg(l_discount) as avg_disc,
       count(*) as count_order
 from
       lineitem
 where
       l_shipdate <= dateadd(day, -90, to_date('1998-12-01'))
 group by
       l_returnflag,
       l_linestatus
 order by
       l_returnflag,
       l_linestatus;

-- give me the top 10 @name fields of the suppliers.
-- give me the top 10 @name fields of the suppliers by @nationkey.
-- give me a list of all @region names, with a comma-separated list of their @nation names.

-- give me an example of using the CUBE keyword in a Snowflake SQL query.
-- what is a clustering key in Snowflake?

-- how many tables are in the current schema?
-- how many columns are in the table with the @extendedprice column?

-- add custom instructions