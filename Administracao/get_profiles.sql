set serverouput on
set feed off
set head off
set pages 1000
set lines 300

spool alter_profiles.txt

select 'alter profile ' || profile || ' limit ' || resource_name || ' ' || limit || ';' from dba_profiles;

spool off

set feed on
set head on
