set serveroutput on
set feed off
set head off
set pages 1000
set lines 105


spool alter_redologs.txt
select 'alter database rename file ''' || member || ''' to ''' || member  || ''';' from v$logfile;
spool off;

set feed on
set head on

