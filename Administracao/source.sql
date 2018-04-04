--
-- source
--

set echo off
accept name  prompt "Enter the name of the PACKAGE, FUNCTION, or PROCEDURE: "
accept owner prompt "Enter the OWNER: "
set pages 0 lines 500  set long 10000 feedback off verify off trimspool on termout off 

select text
  from dba_source
 where name like upper('&&name')
   and owner like upper('&&owner')
order by type, line

spool &&name..sql
/
spool off
set feedback on verify on termout on

ed &&name
