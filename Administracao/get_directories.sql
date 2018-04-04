set feed off
set head off
set pages 1000
set lines 300
set timing off

spool create_directories.txt

select 'create or replace directory ''' || directory_name || ''' as ''' || directory_path || ''';' from dba_directories;

spool off

set feed on
set head on
set timing on
