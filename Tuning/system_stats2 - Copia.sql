accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
col snapshot form a20
SET PAGES 5000

SELECT TO_CHAR((begin_interval_time), 'YYYY/MM/DD HH24:MI') AS SNAPSHOT, e.resource_name,
 CURRENT_UTILIZATION,
  MAX_UTILIZATION,
 LIMIT_VALUE
  FROM 
   dba_hist_snapshot s, DBA_HIST_RESOURCE_LIMIT e
 WHERE S.SNAP_ID = E.SNAP_ID
 AND S.BEGIN_INTERVAL_TIME BETWEEN to_date('&p_btime','yyyymmddhh24mi') AND to_date('&p_etime','yyyymmddhh24mi')
 AND e.RESOURCE_NAME IN
 ('processes','sessions')
 AND e.dbid = s.dbid
 and e.instance_number = s.instance_number
 and s.instance_number = 1
 order by snapshot,e.resource_name;

