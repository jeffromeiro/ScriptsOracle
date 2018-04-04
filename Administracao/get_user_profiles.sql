
set head off
set feed off
set pages 0
set lines 105

spool alter_user_profiles.txt

select 'alter user ' ||   username ||  ' profile ' || profile || ';' from dba_users;

spool off

set head on
set feed on

