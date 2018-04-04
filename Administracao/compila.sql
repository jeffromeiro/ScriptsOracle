set head off
set feed off
set term off
set echo off
set timing off

spool compila2.sql

SELECT COUNT(*) FROM USER_OBJECTS WHERE STATUS ='INVALID';


select 'ALTER '||DECODE(OBJECT_TYPE,'PACKAGE BODY','PACKAGE',OBJECT_TYPE)||' '||OBJECT_NAME||' COMPILE '||DECODE(OBJECT_TYPE,'PACKAGE BODY','BODY;',';')
FROM USER_OBJECTS
WHERE STATUS ='INVALID';

spool off

set echo on
set feed on
set term on
set echo on

@compila2.sql

set head on
set echo off
!rm compila2.sql 

spool compila_&nome..log

SELECT OBJECT_NAME, OBJECT_TYPE, TO_CHAR(LAST_DDL_TIME,'dd-mm-yy hh24:mi:ss'), STATUS
from user_objects
WHERE STATUS='INVALID'
/


spool off
