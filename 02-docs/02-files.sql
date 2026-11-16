-- Unstructured Data Files
use test.public;

-- ==================================================
-- File Functions & file URLs

-- s3://sfc-prod3-ds1-26-customer-stage/vyht0000-s/stages/1865c8c2-0c44-4005-9854-e22cfbb5d673/
select GET_STAGE_LOCATION(@stage1);

-- research-paper-example.pdf
select GET_RELATIVE_PATH(@stage1,
    GET_STAGE_LOCATION(@stage1) || 'research-paper-example.pdf');

-- s3://sfc-prod3-ds1-26-customer-stage/vyht0000-s/stages/1865c8c2-0c44-4005-9854-e22cfbb5d673/spool/research-paper-example.pdf
select GET_ABSOLUTE_PATH(@stage1, 'spool/research-paper-example.pdf');

-- https://vxb96448.snowflakecomputing.com/api/files/TEST/PUBLIC/STAGE1/spool%2fresearch-paper-example.pdf
select BUILD_STAGE_FILE_URL(@stage1, 'spool/research-paper-example.pdf');

-- https://vxb97448.snowflakecomputing.com/api/files/01c87331-010d-49d5-0046-210701079d52/19739562320781322/XujrMnXPJ2TOu0pg6JdLFmafr%2bhdk79xz3FBEKoY%2fCJz0Ve%2fNW8j%2ftRC2ruWNlo0j2Chh0%2fSdobQPSm91nAP7oTesGENUrs4Rwr%2fayg%2bp3%2b%2bKoKS04vzK1%2fnznJadnwPRyBvzIrBNUHX%2fm5UoHCftKCjPn1U3biobBpAYtsbBBqnvT4Ke0WhBAAprK%2fGh2NFK3g18EnvWvKjC2JILSk5Qq%2bm2UKsmvRFrwpS1U11svUnUJHgwx%2b3x9oGg93ktcbUxNtwHYIReqvOWuQJ%2fNx%2bAKvzmnTfEYyFQl4iiREYrAtYombhk58%3d
select BUILD_SCOPED_FILE_URL(@stage1, 'spool/research-paper-example.pdf');

-- https://sfc-prod3-ds1-25-customer-stage.s3.us-west-2.amazonaws.com/vyhg0000-s/stages/1865c8c2-0c44-4005-9854-e22cfbb5d673/spool/research-paper-example.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20261116T130628Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAUHYAS4VVBT7UASUM%2F20261116%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=8a3663d3c32e9647663c4bfa22c2e3bdb6ace5158cbe26178d7190ca7f4fb3de
select GET_PRESIGNED_URL(@stage1, 'spool/research-paper-example.pdf');

-- ==================================================
-- FILE data type & directory table

select to_file('@stage1', 'spool/research-paper-example.pdf') f;

SELECT to_file('@stage1', 'spool/research-paper-example.pdf') f,
    OBJECT_CONSTRUCT(
        'STAGE', FL_GET_STAGE(f),
        'RELATIVE_PATH', FL_GET_RELATIVE_PATH(f),
        'CONTENT_TYPE', FL_GET_CONTENT_TYPE(f),
        'SIZE', FL_GET_SIZE(f),
        'ETAG', FL_GET_ETAG(f),
        'LAST_MODIFIED', FL_GET_LAST_MODIFIED(f),
        'SCOPED_URL', FL_GET_SCOPED_FILE_URL(f)
    ) AS o;
  
select to_file('@stage1', 'spool/research-paper-example.pdf') as f,
    fl_get_size(f) size,
    fl_get_file_type(f) type;

with cte as (
    select to_file('@stage1', 'spool/research-paper-example.pdf') as f)
select fl_get_size(f) size,
    fl_get_file_type(f) type
from cte;

-- =============================================================================
-- multiple docs

select * from directory(@stage1);
alter stage stage1 refresh subpath='spool';
select * from directory(@stage1);

select to_file('@stage1', RELATIVE_PATH) as f
from directory(@stage1);
    
create or replace temporary table files1
as select to_file('@stage1', RELATIVE_PATH) as f,
    BUILD_SCOPED_FILE_URL(@stage1, RELATIVE_PATH) as scoped,
    RELATIVE_PATH as path
from directory(@stage1)
where RELATIVE_PATH like '%.pdf'    -- filter by file type
    and SIZE > 0;                   -- skip folder entry

select * from files1;

select fl_get_relative_path(f) as path,
    split_part(path, '/', -1) as name
from files1
where fl_is_document(f);
