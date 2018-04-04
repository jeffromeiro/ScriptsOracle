-- script para compilar um owner específica, é gerado um spool na pasta atual
-- Jefferson Romeiro
-- 13/07/10


set head off
set feed off
set term off
set echo off
set timing off
set verify off

undef OWNER 

select '&&OWNER' FROM DUAL;

spool compila2.sql



select 'ALTER '||DECODE(OBJECT_TYPE,'PACKAGE BODY','PACKAGE',OBJECT_TYPE)||' '||OWNER||'.'||OBJECT_NAME||
' COMPILE '||DECODE(OBJECT_TYPE,'PACKAGE BODY','BODY;',';')||'                                                                                                                                                                                                                                                                                           show errors; '
FROM DBA_OBJECTS
WHERE STATUS ='INVALID'
AND OWNER = '&OWNER'
order by object_name desc , object_type;

spool off

set echo on
set feed on
set term on
set echo on

spool compila_&OWNER..log
@compila2.sql

set head on
set echo off
!rm compila2.sql 


SELECT OBJECT_NAME, OBJECT_TYPE, TO_CHAR(LAST_DDL_TIME,'dd-mm-yy hh24:mi:ss'), STATUS
from DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER = '&OWNER'
/


spool off
set head on
set feed on
set term on
set echo on
set timing on
set verify on
