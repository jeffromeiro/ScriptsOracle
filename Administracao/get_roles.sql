col text for a100 wrap
set feed off
set head off
set pages 0
set lines 300

spool create_role.txt

--SELECT DBMS_METADATA.GET_DDL('ROLE', role)||';' text FROM dba_roles;
SELECT 'CREATE ROLE '||ROLE|| ' ;' FROM dba_roles;

spool off

set head on
set feed on
