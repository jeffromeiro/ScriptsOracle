accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
col snapshot form a20

SELECT SNAPSHOT,
 SUM(DECODE(EVENT_NAME, 'db file sequential read', AVG_MS, 0)) Single_Read,
 SUM(DECODE(EVENT_NAME, 'db file scattered read', AVG_MS, 0)) Scattered_Read,
 SUM(DECODE(EVENT_NAME, 'log file sync', AVG_MS, 0)) Redo_Write
 FROM (SELECT TO_CHAR((btime), 'YYYY/MM/DD HH24:MI') AS SNAPSHOT,
 EVENT_NAME,
 round(AVG((time_ms_end - time_ms_beg) /
 NULLIF(count_end - count_beg, 0)),
 2) avg_ms
 FROM (SELECT e.event_name,
 s.begin_interval_time btime,
 total_waits count_end,
 time_waited_micro / 1000 time_ms_end,
 LAG(e.time_waited_micro / 1000) OVER(PARTITION BY e.event_name ORDER BY s.snap_id) time_ms_beg,
 LAG(e.total_waits) OVER(PARTITION BY e.event_name ORDER BY s.snap_id) count_beg
 FROM dba_hist_snapshot s, dba_hist_system_event e
 WHERE S.SNAP_ID = E.SNAP_ID
 AND S.BEGIN_INTERVAL_TIME BETWEEN to_date('&p_btime','yyyymmddhh24mi') AND to_date('&p_etime','yyyymmddhh24mi')
 AND e.event_name IN
 ('db file scattered read', 'db file sequential read', 'log file sync')
 AND e.dbid = s.dbid
 and e.instance_number = s.instance_number
 and s.instance_number = 1
 ORDER BY e.event_name, BEGIN_INTERVAL_TIME)
 group by TO_CHAR((btime), 'YYYY/MM/DD HH24:MI'), event_name
 having AVG((time_ms_end - time_ms_beg) / NULLIF(count_end - count_beg, 0)) > 0)
 group by snapshot
 order by snapshot;
