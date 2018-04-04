ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ', .';
set echo off
set verify off
set markup html on
set lines 250 pages 5000
set arraysize 5000
accept dt_inicio char prompt 'Data inicial yyyymmddhh24mi: '
accept dt_fim   char prompt 'Data final yyyymmddhh24mi: '
accept evento  char prompt 'Evento: '
set term off
set feed off
spool sql_by_events.xls 
WITH
  t_ AS (
    SELECT COUNT(*) cnt,
           a.user_id,
           a.sql_id,
           a.module
      FROM dba_hist_active_sess_history a,
           dba_hist_snapshot b
     WHERE b.instance_number = 1
       AND  to_date('&&dt_inicio','yyyymmddhh24mi') <  b.BEGIN_INTERVAL_TIME
              AND b.BEGIN_INTERVAL_TIME         <= to_date('&&dt_fim','yyyymmddhh24mi')
	          AND a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id       
       AND a.sql_id IS NOT NULL
       AND a.session_state = 'WAITING' AND a.event = '&evento'       
       AND 1=1
     GROUP BY a.user_id, a.sql_id, a.module
     ORDER BY COUNT(*) DESC),
  t0 AS (
    SELECT cnt,
           a.sql_id,
           a.module,
           NVL(c.username,a.user_id) username,
           SUM(d.buffer_gets_delta) buffer_gets,
           SUM(d.disk_reads_delta) disk_reads,
           SUM(d.cpu_time_delta)/1000000 cpu_time_s,
           SUM(d.elapsed_time_delta)/1000000 elap_time_s,
           SUM(d.ccwait_delta)/1000000 cc_time_s,
           SUM(d.parse_calls_delta) parses,
           SUM(d.executions_delta) execs
      FROM t_ a,
           dba_hist_snapshot b,
           dba_users c,
           dba_hist_sqlstat d,
           dba_hist_sqltext e
     WHERE b.instance_number = 1
       AND  to_date('&dt_inicio','yyyymmddhh24mi') <  b.BEGIN_INTERVAL_TIME
                    AND b.BEGIN_INTERVAL_TIME         <= to_date('&dt_fim','yyyymmddhh24mi')
	          AND a.user_id = c.user_id(+)
       AND d.dbid = b.dbid
       AND d.instance_number = b.instance_number
       AND d.sql_id = a.sql_id
       AND d.snap_id = b.snap_id
       AND e.dbid = b.dbid
       AND e.sql_id = a.sql_id
       AND 1=1
       /*AND e.command_type IN (comm_type) */
     GROUP BY cnt, a.sql_id, a.module, NVL(c.username,a.user_id)
     ORDER BY COUNT(*) DESC),
  t1 AS (
    SELECT *
      FROM t0
     WHERE ROWNUM <= 50)   
SELECT ---1 qtd,
       ---1 peak_id,
       ROUND(ratio_to_report(t1.cnt) over() * 100,2) pct,              
       t1.module,
       t1.username,
       t1.sql_id,
       buffer_gets,
       decode(execs,0,0,buffer_gets/execs) buffer_gets_by_exec,
       disk_reads,
       decode(execs,0,0,disk_reads/execs) disk_reads_by_exec,
       round(cpu_time_s,2) cpu_time_s,
       round(decode(execs,0,0,cpu_time_s/execs),2) cpu_time_by_exec_s,
       round(elap_time_s,2) elap_time_s,
       round(decode(execs,0,0,elap_time_s/execs),2) elap_time_by_exec_s,
       round(cc_time_s,2) cc_time_s,
       round(decode(execs,0,0,cc_time_s/execs),2) cc_time_by_exec_s,
       parses,
       execs,
       replace(replace(to_char(substr(t2.sql_text,1,32)),chr(13),null),chr(10),null) sql_text                
  FROM t1,
       dba_hist_sqltext t2 
 WHERE t1.sql_id = t2.sql_id
 ORDER BY pct DESC;
spool off
set markup html off
set term on
set echo off
set feed on
set verify off
