-- Script utilizado para gerar backup de objetos

set head off
set pages 200
set long 2000000000 

accept OBJECT_NAME char prompt 'Nome do Objeto: '

spool &OBJECT_NAME..bkp

SELECT TEXT
FROM USER_SOURCE
WHERE NAME=UPPER('&OBJECT_NAME')
ORDER BY TYPE, LINE;

set head on
spool off
