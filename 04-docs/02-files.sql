-- Unstructured Data Files
use test.public;

-- ==================================================
-- File Functions & file URLs

select GET_STAGE_LOCATION(@stage1);
select GET_RELATIVE_PATH(@stage1,
    GET_STAGE_LOCATION(@stage1) || 'research-paper-example.pdf');
select GET_ABSOLUTE_PATH(@stage1, 'spool/research-paper-example.pdf');

select BUILD_STAGE_FILE_URL(@stage1, 'spool/research-paper-example.pdf');
select BUILD_SCOPED_FILE_URL(@stage1, 'spool/research-paper-example.pdf');
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
