set echo off
set verify off
set markup html on
set lines 250 pages 5000
set arraysize 5000
accept dt_inicio char prompt 'Data inicial yyyymmddhh24mi: '
accept dt_fim   char prompt 'Data final yyyymmddhh24mi: '
accept offender_type          number prompt 'Ordenar por (1-BufGets, 2-DiskRds, 3-CPU, 4-Elap, 5-Parses, 6-Execs): '
set term off
set feed off
spool sql_by_metrics.xls

select round(pct,2) pct,
       module,
       parsing_schema_name username,
       sql_id,
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
       replace(replace(to_char(substr(sql_text,1,32)),chr(13),null),chr(10),null) sql_text
  from (
select /*+ ordered use_nl (b st) */
       case
         when &&offender_type=1 then ratio_to_report(nvl(buffer_gets,0)) over ()*100
         when &&offender_type=2 then ratio_to_report(nvl(disk_reads,0)) over ()*100
         when &&offender_type=3 then ratio_to_report(nvl(to_number(CPU_TIME_s),0)) over ()*100
         when &&offender_type=4 then ratio_to_report(nvl(to_number(elap_time_s),0)) over ()*100
         when &&offender_type=5 then ratio_to_report(nvl(parses,0)) over ()*100
         when &&offender_type=6 then ratio_to_report(nvl(execs,0)) over ()*100
         when &&offender_type=7 then ratio_to_report(nvl(cc_time_s,0)) over ()*100
       end PCT,
      t.* from (
          select sq.*,
                 trim(st.sql_text) sql_text
            from
               ( SELECT module,
                        NVL(username,a.parsing_schema_id) parsing_schema_name,
                        SQL_ID                      ,
                        SUM(BUFFER_GETS_DELTA) buffer_gets,
                        SUM(DISK_READS_DELTA) disk_reads,
                        SUM(CPU_TIME_DELTA)/1000000 cpu_time_s,
                        SUM(ELAPSED_TIME_DELTA)/1000000 ELAP_time_s,
                        SUM(ccwait_delta)/1000000 cc_time_s,
                        SUM(PARSE_CALLS_DELTA) parses,
                        SUM(EXECUTIONS_DELTA) execs
                FROM    DBA_HIST_SQLSTAT a,
                        dba_users b,
						dba_hist_snapshot c
                WHERE   c.INSTANCE_NUMBER = 1 and
                     to_date('&dt_inicio','yyyymmddhh24mi') <  c.BEGIN_INTERVAL_TIME
                    AND c.BEGIN_INTERVAL_TIME         <= to_date('&dt_fim','yyyymmddhh24mi')
                    AND 1=1
                    AND 1=1
                    AND a.parsing_schema_id = b.user_id(+)
					and a.snap_id=c.snap_id
                GROUP BY module, NVL(username,a.parsing_schema_id), SQL_ID ) sq,
                DBA_HIST_SQLTEXT st
           WHERE SQ.SQL_ID = ST.SQL_ID
             AND st.command_type IN (3, 2, 6, 7) 
         ) t
  order by pct desc
) where rownum <= 25;

spool off
set markup html off
set term on
set echo off
set feed on
set verify off

