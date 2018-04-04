set lines 150 pages 50000
set head off trim off term off feed off tab off


spool /tmp/log_saida.txt append

SELECT to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||','||to_char(a.logon_time,'dd/mm/yyyy hh24:mi:ss')||','|| a.inst_id||','||a.sid||','||
       a.sql_id||','||
       a.username||','||
       --a.machine||','||
       a.program||','||
       CASE a.state
         WHEN 'WAITING' THEN a.event
         ELSE 'On CPU / runqueue'
       END||','||
       a.blocking_session||','||
       a.seconds_in_wait||','||a.osuser
FROM   gv$session a                       -- , v$session b
WHERE                                     -- a.blocking_session = b.sid (+) AND
       a.status = 'ACTIVE'     AND
       a.module like '%rjolnx775%'
ORDER  BY 1;

spool off
exit;
