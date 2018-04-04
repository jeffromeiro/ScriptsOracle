ttitle off
set verify off
set lines 200
set pages 200
col sql_text format a250
col sql_address new_value aa
select sid,serial#, username, osuser , status, to_char(logon_time, 'dd.mm.yyyy hh24:mi:ss') , sql_address, sql_hash_value 
from gv$session where sid='&sid'
/
select sql_text from gv$sqltext 
where address='&aa'
order by piece
/
undef aa