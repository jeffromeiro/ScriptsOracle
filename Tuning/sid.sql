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
       a.sid=&sid and status='ACTIVE'
ORDER  BY 6, 7, 3, 4
/
