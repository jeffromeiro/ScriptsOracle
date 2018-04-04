col event form a20 trunc
col action form a20
select inst_id,username, sid, serial#, to_char(logon_time,'ddmmyyyy hh24:mi:ss') logon_time,sql_id, event, status , action, module
from gv$session 
where status='ACTIVE' and username is not null order by 1
/
