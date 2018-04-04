select 'alter system kill session '||''''||s.sid||','||s.serial#||''''||' IMMEDIATE;' 
from      v$session s
where s.username='&USER'
/
