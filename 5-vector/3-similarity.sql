-- https://docs.snowflake.com/en/sql-reference/functions/vector_cosine_similarity

SELECT a, VECTOR_COSINE_SIMILARITY(a, [1,2,3]::VECTOR(FLOAT, 3)) AS similarity
  FROM vectors
  ORDER BY similarity DESC
  LIMIT 1;

-- https://docs.snowflake.com/en/sql-reference/functions/vector_inner_product

CREATE TABLE vectors (a VECTOR(FLOAT, 3), b VECTOR(FLOAT, 3));
INSERT INTO vectors SELECT [1.1,2.2,3]::VECTOR(FLOAT,3), [1,1,1]::VECTOR(FLOAT,3);
INSERT INTO vectors SELECT [1,2.2,3]::VECTOR(FLOAT,3), [4,6,8]::VECTOR(FLOAT,3);

-- Compute the pairwise inner product between columns a and b
SELECT VECTOR_INNER_PRODUCT(a, b) FROM vectors;

-- https://docs.snowflake.com/en/sql-reference/functions/vector_l1_distance

CREATE TABLE vectors (a VECTOR(FLOAT, 3), b VECTOR(FLOAT, 3));
INSERT INTO vectors SELECT [1.1,2.2,3]::VECTOR(FLOAT,3), [1,1,1]::VECTOR(FLOAT,3);
INSERT INTO vectors SELECT [1,2.2,3]::VECTOR(FLOAT,3), [4,6,8]::VECTOR(FLOAT,3);

SELECT VECTOR_L1_DISTANCE(a, b) FROM vectors;

-- https://docs.snowflake.com/en/sql-reference/functions/vector_l2_distance

CREATE TABLE vectors (a VECTOR(FLOAT, 3), b VECTOR(FLOAT, 3));
INSERT INTO vectors SELECT [1.1,2.2,3]::VECTOR(FLOAT,3), [1,1,1]::VECTOR(FLOAT,3);
INSERT INTO vectors SELECT [1,2.2,3]::VECTOR(FLOAT,3), [4,6,8]::VECTOR(FLOAT,3);

-- Compute the pairwise inner product between columns a and b
SELECT VECTOR_L2_DISTANCE(a, b) FROM vectors;
