set serveroutput on
set feed off
set head off
set pages 1000
set lines 105


spool drop_tempfiles.txt
select 'alter database tempfile ' || name || ' drop including datafiles;' from v$tempfile;
spool off;

set feed on
set head on

