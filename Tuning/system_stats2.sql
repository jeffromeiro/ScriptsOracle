accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
col snapshot form a20

SELECT SNAPSHOT,
 SUM(DECODE(STAT_NAME, 'physical reads', AVG_TOTAL, 0)) physical_reads,
 SUM(DECODE(STAT_NAME, 'physical writes', AVG_TOTAL, 0)) physical_writes,
 SUM(DECODE(STAT_NAME, 'user commits', AVG_TOTAL, 0)) user_commits
 FROM (SELECT TO_CHAR((btime), 'YYYY/MM/DD HH24:MI') AS SNAPSHOT,
 STAT_NAME,
 round(AVG( NULLIF(count_end - count_beg, 0)),
 2) avg_total
 FROM (SELECT e.STAT_name,
 s.begin_interval_time btime,
 VALUE count_end,
   LAG(e.VALUE) OVER(PARTITION BY e.stat_name ORDER BY s.snap_id) count_beg
 FROM dba_hist_snapshot s, DBA_HIST_SYSSTAT e
 WHERE S.SNAP_ID = E.SNAP_ID
 AND S.BEGIN_INTERVAL_TIME BETWEEN to_date('&p_btime','yyyymmddhh24mi') AND to_date('&p_etime','yyyymmddhh24mi')
 AND e.stat_name IN
 ('physical reads', 'physical writes', 'user commits')
 AND e.dbid = s.dbid
 and e.instance_number = s.instance_number
 and s.instance_number = 1
 ORDER BY e.STAT_NAME, BEGIN_INTERVAL_TIME)
 group by TO_CHAR((btime), 'YYYY/MM/DD HH24:MI'), stat_name
 having AVG( NULLIF(count_end - count_beg, 0)) > 0)
 group by snapshot
 order by snapshot;

