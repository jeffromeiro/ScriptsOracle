COLUMN EVENT FORMAT A30
-- COLUMN MODULE FORMAT A30
--COLUMN MACHINE FORMAT A15
COLUMN STATUS FORMAT A10
COLUMN USERNAME FORMAT A15
COLUMN OSUSER FORMAT A15
set pages 999
set lines 155

SELECT 
  S.SID,
  s.sql_id,
  S.SERIAL#,
  W.EVENT, 
  W.SECONDS_IN_WAIT as "SEC_WAIT", 
--  S.MACHINE, 
--  S.OSUSER, 
  S.USERNAME, 
--  S.MODULE, 
  S.STATUS, 
  W.STATE--, 
--  W.P1, 
--  W.P1TEXT,
--  W.P2, 
--  W.P2TEXT,
--  W.P3
--  W.P3TEXT
FROM 
  V$SESSION_WAIT  W, V$SESSION S 
WHERE 
  W.SID=S.SID 
AND 
  W.EVENT NOT IN ('SQL*Net message from client', 'SQL*Net message to client', 'rdbms ipc message', 
  'smon timer', 'pmon timer', 'SQL*Net more data from client', 'SQL*Net more data to client', 'rdbms ipc reply', 
  'single-task message', 'jobq slave wait', 'PX Deq: Execution Msg', 'PX Deq: Execute Reply', 'PX Deq: Table Q Normal', 
  'Streams AQ: qmn slave idle wait', 'EMON idle wait', 'Streams AQ: waiting for time management or cleanup tasks', 
  'ASM background timer', 'class slave wait', 'Streams AQ: qmn coordinator idle wait', 'DIAG idle wait', 
  'Streams AQ: waiting for messages in the queue') 
ORDER BY SEC_WAIT, EVENT, osuser
/