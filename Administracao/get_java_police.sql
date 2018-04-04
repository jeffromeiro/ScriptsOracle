set head off
set feed off
set pages 0
set lines 105

spool grant_java_policie.txt

select 'exec dbms_java.grant_permission('''||grantee||''','''||type_name||''','''||name||''','''||action||''');' from dba_java_policy;

spool off

set head on
set feed on
