col texto form a70
select 'exec sys.dbms_system.set_ev('||s.sid||','||s.serial#||',10046,12,'||''''||''''||');' TEXTO, s.sid, p.spid, substr(OSUSER,1,10) osuser, substr(s.username,1,20) username
from v$session s, v$process p
where s.paddr=p.addr
AND S.USERNAME= UPPER('&USERNAME')
/

