col username format a12
col sid      format 9999
col serial#  format 99999
col machine  format a25 trunc
col program  format a30 trunc
col type     format a5
col Hold     format a10
col object   format a25


prompt Locks
SELECT a.username
     , a.sid
     , a.serial#
     , b.lock_type as Type
     , b.mode_held as Hold
     , c.owner || '.' || c.object_name as Object
     , a.program as Program
     , substr(a.machine, 1, 22) as Machine
     , ROUND(d.seconds_in_wait/60,2) as WaitMin
  FROM v$session       a
     , sys.dba_lock    b
     , sys.dba_objects c
     , v$session_wait  d
 WHERE a.sid        =  b.session_id
   AND b.lock_type IN ('DML','DDL')
   AND b.lock_id1   =  c.object_id
   AND b.session_id =  d.sid
 ORDER BY a.sid;


prompt Active Table Locks

SELECT SUBSTR(a.object,1,25) TABLENAME,
SUBSTR(s.username,1,15) USERNAME,
SUBSTR(p.pid,1,5) PID,
SUBSTR(p.spid,1,10) SYSTEM_ID,
DECODE(l.type,
'RT','Redo Log Buffer',
'TD','Dictionary',
'TM','DML',
'TS','Temp Segments',
'TX','Transaction',
'UL','User',
'RW','Row Wait',
l.type) LOCK_TYPE
FROM gv$access a, gv$process p, gv$session s, gv$lock l
WHERE s.sid = a.sid
AND s.paddr = p.addr
AND l.sid = p.pid
GROUP BY a.object, s.username, p.pid, l.type, p.spid
ORDER BY a.object, s.username;

prompt Active locks > 2 min

SELECT SUBSTR(TO_CHAR(w.session_id),1,5) WSID
     , p1.spid WPID
     , SUBSTR(s1.username,1,12) "WAITING User"
     , SUBSTR(s1.osuser,1,8) "OS User"
     , SUBSTR(s1.program,1,20) "WAITING Program"
     , s1.client_info "WAITING Client"
     , SUBSTR(TO_CHAR(h.session_id),1,5) HSID
     , p2.spid HPID
     , SUBSTR(s2.username,1,12) "HOLDING User"
     , SUBSTR(s2.osuser,1,8) "OS User"
     , SUBSTR(s2.program,1,20) "HOLDING Program"
     , s2.client_info "HOLDING Client"
     , o.object_name "HOLDING Object"
  FROM gv$process p1
     , gv$process p2
     , gv$session s1
     , gv$session s2
     , dba_locks w
     , dba_locks h
     , dba_objects o
 WHERE w.last_convert > 120
   AND h.mode_held != 'None'
   AND h.mode_held != 'Null'
   AND w.mode_requested != 'None'
   AND s1.row_wait_obj# = o.object_id
   AND w.lock_type(+) = h.lock_type
   AND w.lock_id1(+) = h.lock_id1
   AND w.lock_id2 (+) = h.lock_id2
   AND w.session_id = s1.sid (+)
   AND h.session_id = s2.sid (+)
   AND s1.paddr = p1.addr (+)
   AND s2.paddr = p2.addr (+)
 ORDER BY w.last_convert desc;
