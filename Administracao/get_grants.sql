
set feed off
set head off
set pages 0
set lines 105

spool grants.txt

select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ';' from dba_tab_privs;

select 'grant ' || granted_role || ' to ' || grantee || ';' from dba_role_privs;

select 'grant ' || privilege || ' to ' || grantee || ';' from dba_sys_privs;

spool off;



set feed on
set head on
