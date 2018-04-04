ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ', .';

set echo off
set verify off
set markup html on
set lines 250 pages 5000
set arraysize 5000
accept dt_inicio char prompt 'Data inicial yyyymmddhh24mi: '
accept dt_fim   char prompt 'Data final yyyymmddhh24mi: '
accept sqlid          char prompt 'SQL_ID: '
set term off
set feed off
spool one_sql_breakdown.xls

select to_char(s.end_interval_time,'dd/mm/yyyy hh24:mi') snap_time, 
       d.sql_id || ' - ' || to_char(substr(t.sql_text,1,32)) || '...' sql_id,
       100*(d.buffer_gets_delta-d.disk_reads_delta)/decode(nvl(d.buffer_gets_delta,0),0,1,nvl(d.buffer_gets_delta,1)) sql_bc_hit_ratio,
       d.buffer_gets_delta buffer_gets,  d.buffer_gets_delta/decode(nvl(d.executions_delta,0),0,1,nvl(d.executions_delta,1))bg_per_exec,
       100*(d.executions_delta-d.parse_calls_delta)/decode(nvl(d.executions_delta,0),0,1,nvl(d.executions_delta,1))sql_cache_reuse,
       d.cpu_time_delta/60000000 cpu_time_min, d.cpu_time_delta/1000000/decode(nvl(d.executions_delta,0),0,1,nvl(d.executions_delta,1))cpu_per_exec_s,
       d.disk_reads_delta disk_reads, d.disk_reads_delta/decode(nvl(d.executions_delta,0),0,1,nvl(d.executions_delta,1))dr_per_exec,
       d.elapsed_time_delta/60000000 elap_time_min, d.elapsed_time_delta/1000000/decode(nvl(d.executions_delta,0),0,1,nvl(d.executions_delta,1))elap_per_exec_s,
       d.executions_delta executions,             
       d.parse_calls_delta parses        
  from dba_hist_snapshot s, dba_hist_sqlstat d, dba_hist_sqltext t
 where  to_date('&dt_inicio','yyyymmddhh24mi') <  s.BEGIN_INTERVAL_TIME
                    AND s.BEGIN_INTERVAL_TIME         <= to_date('&dt_fim','yyyymmddhh24mi')
   and s.instance_number = 1
   and s.snap_id = d.snap_id
   and s.instance_number = d.instance_number
   and s.dbid = d.dbid
   and d.sql_id = '&&sqlid'
   and d.sql_id = t.sql_id
 order by s.end_interval_time;
 
 spool off
set markup html off
set term on
set echo off
set feed on
set verify off
