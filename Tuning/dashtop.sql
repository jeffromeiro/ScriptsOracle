--------------------------------------------------------------------------------
--
-- File name:   dashtop.sql
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @dashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @dashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--     @dashtop sql_id,event machine='kepler002' "to_date('2016/01/22 00:20:00', 'YYYY/MM/DD HH24:MI:SS')" "to_date('2016/01/22 00:35:00', 'YYYY/MM/DD HH24:MI:SS')"
--     @dashtop sql_id,event,session_state 1=1 "to_date('2016/01/22 00:20:00', 'YYYY/MM/DD HH24:MI:SS')" "to_date('2016/01/22 00:35:00', 'YYYY/MM/DD HH24:MI:SS')"
--     @dashtop event,Current_obj# sql_id='9jfpmqkfn11nc' "to_date('2016/01/22 11:00:00', 'YYYY/MM/DD HH24:MI:SS')" "to_date('2016/01/22 12:30:00', 'YYYY/MM/DD HH24:MI:SS')"
-- Other:
--     This script uses only the AWR's DBA_HIST_ACTIVE_SESS_HISTORY, use
--     @dashtop.sql for accessiong the V$ ASH view
--              
--------------------------------------------------------------------------------
COL "%This" FOR A6
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text FOR A20 word_wrap
COL p2text FOR A20 word_wrap
COL p3text FOR A20 word_wrap
col SQL_PLAN_OPERATION for a20 word_wrap
COL OBJECT_NAME  FOR A15 word_wrap
COL OBJECT_TYPE  FOR A10 word_wrap
COL EVENT  	FOR A20 word_wrap
COL SQL_ID  FOR A20 word_wrap
COL first_seen  FOR A20 word_wrap
COL last_seen  FOR A20 word_wrap
COL username  FOR A25 word_wrap
COL p1hex  FOR A17
COL p2hex  FOR A17
COL p3hex  FOR A17
COL event  FOR A30
COL sql_opname FOR A15
COL top_level_call_name FOR A25
COL module FOR A20
set verify off

SELECT * FROM (
    SELECT /*+ LEADING(a) USE_HASH(u) */
        LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
	  , ROUND(10 * COUNT(*) / ((select TRUNC((CAST(max(end_interval_time) as date)-CAST(min(begin_interval_time) as date))*24*60*60) from dba_hist_snapshot where snap_id between &3 AND &4 )), 1) AAS
      , &1
      , 10 * COUNT(*)                                                      "TotalSeconds"
--      , 10 * SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
--      , 10 * SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
--      , 10 * SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
--      , 10 * SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
--      , 10 * SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
--      , 10 * SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
--      , 10 * SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
--      , 10 * SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
--      , 10 * SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
--      , 10 * SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
--      , 10 * SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
--      , 10 * SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM dba_hist_active_sess_history a) a
      , dba_users u
	  , dba_objects o
    WHERE
        a.user_id = u.user_id (+)
    AND &2
    --AND sample_time BETWEEN &3 AND &4
    --AND snap_id IN (SELECT snap_id FROM dba_hist_snapshot WHERE sample_time BETWEEN &3 AND &4) -- for partition pruning
    AND snap_id BETWEEN &3 AND &4
	AND o.object_id(+) = a.Current_obj#
	GROUP BY
        &1
    ORDER BY
        "TotalSeconds" DESC
       , &1
)
WHERE
    ROWNUM <= 30
/

UNDEFINE &1
UNDEFINE &2
UNDEFINE &3
UNDEFINE &4
