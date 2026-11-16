-- Stage SQL statements & File Staging commands

create database if not exists test;
use test.public;

create stage if not exists stage1
    ENCRYPTION=(TYPE='SNOWFLAKE_SSE')
    DIRECTORY=(ENABLE=true);

show stages;
desc stage stage1;

list @stage1;
remove @stage1;

show workspaces in account;

-- "Copy full path" of a file from /.spool and replace below
list snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/.spool/;
copy files into @stage1/spool/
    from snow://workspace/USER$CRISTISCU.PUBLIC."snowpro-gen-ai"/versions/head/.spool/;
list @stage1;

