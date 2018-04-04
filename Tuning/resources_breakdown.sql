set echo off
set verify off
set markup html on
set lines 250 pages 5000
set arraysize 5000
accept dt_inicio char prompt 'Data inicial yyyymmddhh24mi: '
accept dt_fim   char prompt 'Data final yyyymmddhh24mi: '
accept resource_name          char prompt 'Resource Name (processes, sessions,parallel_max_servers, transactions, etc...): '
set term off
set feed off
spool resources_breakdown.xls

WITH
  t_raw AS
    (SELECT b.snap_id,TO_CHAR(b.end_interval_time,'DD/MM/YYYY HH24:MI') snap_time,
            resource_name,
            CASE 
              WHEN '#' = '#' THEN a.current_utilization
              ELSE a.current_utilization 
            END value,            
            DECODE(b.startup_time,LAG(b.startup_time) OVER (PARTITION BY b.instance_number ORDER BY b.snap_id),NULL,'X') restart
       FROM dba_hist_resource_limit a,
            dba_hist_snapshot b,
            gv$parameter c
      WHERE a.instance_number = 1
        AND to_date('&dt_inicio','yyyymmddhh24mi') <  b.BEGIN_INTERVAL_TIME
                    AND b.BEGIN_INTERVAL_TIME         <= to_date('&dt_fim','yyyymmddhh24mi')
		AND resource_name = '&&resource_name'
        AND a.instance_number = b.instance_number
        AND a.snap_id = b.snap_id
        AND a.dbid = b.dbid
        AND a.instance_number = c.inst_id
        AND c.name = 'db_block_size'
      ORDER BY a.snap_id)
SELECT snap_id,snap_time,
       resource_name,
       value,
       DECODE(ROWNUM,1,0,delta) delta,
       restart
  FROM (       
SELECT snap_id,snap_time,
       resource_name,
       value,
       DECODE(restart,'X',value,value - LAG(value,1) OVER (ORDER BY snap_time)) delta,
       restart
  FROM t_raw )
 ORDER BY TO_DATE(snap_time,'DD/MM/YYYY HH24:MI');
 
 spool off
set markup html off
set term on
set echo off
set feed on
set verify off
