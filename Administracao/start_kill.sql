col username form a30
col col1 form a50
set lines 200
select 'alter system kill session '||''''||s.sid||','||s.serial#||''''||';' col1, s.username, s.status, 'kill -9 '||p.spid PID
from      v$session s, v$process p
where s.username is not null
and   s.paddr=p.addr
and s.username is not null 
and s.username not in ( 'SYS', 'SYSTEM')
and s.username like upper('&username'||'%')
/
