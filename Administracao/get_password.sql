set pages 10000
set head off
set feed off
set severoutput on
set line 300

spool alter_passwords.txt
select 'alter user ' || username || ' identified by values ''' || password || ''';' from dba_users;
spool off;

set head on
set feed on

