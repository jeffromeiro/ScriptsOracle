--------------------------------------------------------------------------------
-- File name:   10g_ad.sql
-- Purpose:     Display detailed active sessions' info
--              
-- Usage:       @10g_ad
--------------------------------------------------------------------------------
col sid                     format 99999
col blocking_sql_id         format a14        heading "Blocking|SQL ID"
col blocking_sid            format 99999      heading "Blocking|SID"
col state                   format a10
col machine                 format a20
col username                format a15
col program                 format a17
col event                   format a15
col sql_id                  format a14
set lines 250

select sysdate || '> Active sessions detailed.' as header from dual;
 
SELECT a.inst_id,a.sid,
       a.sql_id,
       a.username || '/' || a.client_identifier as username,
       a.machine,
       a.program,
       CASE a.state
         WHEN 'WAITING' THEN a.event
         ELSE 'On CPU / runqueue'
       END event,
       a.blocking_session blocking_sid,
       a.seconds_in_wait
                                         -- , b.sql_id blocking_sql_id
FROM   gv$session a                       -- , v$session b
WHERE                                     -- a.blocking_session = b.sid (+) AND
       a.status = 'ACTIVE'     AND
       a.wait_class != 'Idle'
and a.seconds_in_wait > 0
ORDER  BY 6, 7, 3, 4;

SELECT a.inst_id,a.sid,
       a.sql_id,
       a.username || '/' || a.client_identifier as username,
       a.machine,
       a.program,
       CASE a.state
         WHEN 'WAITING' THEN a.event
         ELSE 'On CPU / runqueue'
       END event,
       a.blocking_session blocking_sid,
       a.seconds_in_wait, a.last_call_et lastcall
                                         -- , b.sql_id blocking_sql_id
FROM   gv$session a                       -- , v$session b
WHERE                                     -- a.blocking_session = b.sid (+) AND
       a.status = 'ACTIVE'     AND
       a.wait_class != 'Idle'
ORDER  BY 6, 7, 3, 4;

