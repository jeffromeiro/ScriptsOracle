clear columns
clear breaks
clear computes
set lines 200
col username form a10 trunc
col osuser form   a10 trunc 
col event form    a40  trunc
col p1text form   a20 trunc
col p2text form   a20 trunc
col p3text form   a20 trunc

select 
      a.sid,
      b.serial#,
      b.username,
      b.osuser,
      b.status,
      a.event,
      c.disk_reads,
      c.buffer_gets,
      a.P1TEXT,
      a.P2TEXT,
      a.P3TEXT
 from v$session_wait a,
      v$session b, 
      v$sqlarea c
 WHERE a.EVENT NOT LIKE 'SQL%' 
   and a.sid=b.sid 
   and b.sql_hash_value=c.hash_value 
   and b.sql_address=c.address
   and a.EVENT NOT LIKE '%rdbms ipc%'
 ORDER BY 6,5;

select w.event
       , w.seconds_in_wait as wait_secs
       , w.p1text || decode(w.p1text, null, null, ': ' || w.p1) as p1value
       , w.p2text || decode(w.p2text, null, null, ': ' || w.p2) as p2value
       , w.p3text || decode(w.p3text, null, null, ': ' || w.p3) as p3value
   from v$session_wait w, v$session s
   where s.sid = w.sid
     and s.sid in(114)
     and w.state = 'WAITING'
   order by w.seconds_in_wait desc, s.username;
   
   
--select * from dba_queues where qid in (377643, 377667);
rem select * from dba_queues where qid in (&qid1, &qid2);

col owner form a20
col name  form a30
col QUEUE_TABLE form a40
col QUEUE_TYPE  form a15
col RETENTION   form a7
col NETWORK_NAME form a20

rem select OWNER, NAME, QUEUE_TABLE, QUEUE_TYPE, RETENTION, NETWORK_NAME from dba_queues;



