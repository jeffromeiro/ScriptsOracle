col texto form a50
col osuser form a10
col username form a20
col event form a27
select substr(sw.event,1,27) event, 'exec sys.dbms_system.set_ev('||s.sid||','||s.serial#||',10046,8,'||''''||''''||');' TEXTO, s.sid, p.spid, substr(OSUSER,1,10) osuser, substr(s.username,1,20) username
from v$session s, v$process p, V$SESSION_WAIT SW
where s.paddr=p.addr
and s.username is not null
AND S.SID=SW.SID
AND SW.EVENT not like 'SQL%'
and sw.event not like '%timer'
order by 1
/

