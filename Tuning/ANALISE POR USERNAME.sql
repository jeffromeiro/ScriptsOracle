



Quais os 10 principais usuários que mais consomem CPU por período?

PROMPT
ACCEPT pBegin PROMPT "Type begin date (ddmmyyyy): "
ACCEPT pEnd   PROMPT "Type end date (ddmmyyyy) [NULL]:   "



WITH 
snaps AS
(
SELECT MIN(snap_id)
,      MAX(snap_id)
  FROM dba_hist_snapshot
 WHERE begin_interval_time BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                               AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
)
SELECT active_session_history.user_id,
         dba_users.username,
          sqlarea.sql_id,
          sum(active_session_history.wait_time +
              active_session_history.time_waited) ttl_wait_time
     from DBA_HIST_ACTIVE_SESS_HISTORY active_session_history,
          DBA_HIST_SQLTEXT sqlarea,
          dba_users
    where active_session_history.sql_id = sqlarea.sql_id
      and active_session_history.user_id = dba_users.user_id
      AND active_session_history.snap_id >= 3012
      
   group by active_session_history.user_id,sqlarea.sql_id, dba_users.username
  order by 4