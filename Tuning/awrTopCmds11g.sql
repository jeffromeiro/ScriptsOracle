accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
accept topn         number prompt ' Top-N (default 25): '
accept p_inst_id    number prompt '        Instance ID: '
accept opt          number prompt 'Ordenar por (1-BufGets, 2-DiskRds, 3-CPU, 4-Elap, 5-Parses, 6-Execs): '


set pages 1000 lines 250 verify off
column cpu_time_s format a12
column elap_time_s format a12
column elap_exec format a12
column bg_exec format a12
column rows_exec format a12
column parses format 9999999999
column execs format 9999999999
column pct format 90.99
column sql_text format a31


select * from (
select /*+ ordered use_nl (b st) */
       case
         when &opt=1 then ratio_to_report(nvl(buffer_gets,0)) over ()*100
         when &opt=2 then ratio_to_report(nvl(disk_reads,0)) over ()*100
         when &opt=3 then ratio_to_report(nvl(to_number(CPU_TIME_s),0)) over ()*100
         when &opt=4 then ratio_to_report(nvl(to_number(elap_time_s),0)) over ()*100
         when &opt=5 then ratio_to_report(nvl(parses,0)) over ()*100
         when &opt=6 then ratio_to_report(nvl(execs,0)) over ()*100
       end PCT,
      t.* from (
          select sq.*,
                 substr(trim(st.sql_text), 1, 30) sql_text
            from
               ( SELECT SQL_ID                      ,
                        SUM(BUFFER_GETS_DELTA) buffer_gets,
                        SUM(DISK_READS_DELTA) disk_reads,
                        to_char(SUM(BUFFER_GETS_DELTA)/1000000,'9999999D99') BG_EXEC,
                        to_char(SUM(CPU_TIME_DELTA)/1000000,'9999999D99') cpu_time_s,
                     to_char(SUM(ELAPSED_TIME_DELTA)/sum(EXECUTIONS_DELTA)/1000000,'9999999D99') elap_exec,
                     to_char(SUM(ROWS_PROCESSED_DELTA)/sum(EXECUTIONS_DELTA),'9999999D99') rows_exec,
                        to_char(sum(ELAPSED_TIME_delta/1000000),'9999999D99') ELAP_time_s,
                        SUM(PARSE_CALLS_DELTA) parses,
                        SUM(EXECUTIONS_DELTA) execs
                FROM    DBA_HIST_SQLSTAT, DBA_HIST_SNAPSHOT
                WHERE   executions_delta> 0 and DBA_HIST_SNAPSHOT.SNAP_ID = DBA_HIST_SQLSTAT.SNAP_ID and 
			DBA_HIST_SNAPSHOT.instance_number = DBA_HIST_SQLSTAT.instance_number
					AND BEGIN_INTERVAL_TIME BETWEEN to_date('&p_btime','yyyymmddhh24mi') AND to_date('&p_etime','yyyymmddhh24mi')
   				    AND DBA_HIST_SQLSTAT.INSTANCE_NUMBER =  &p_inst_id
                GROUP BY SQL_ID) sq,
                DBA_HIST_SQLTEXT st
           WHERE SQ.SQL_ID = ST.SQL_ID
           AND   ST.COMMAND_TYPE <> 47
         ) t
  order by pct desc
) where rownum <= decode(&topn,0,25,&topn);

undef topn opt p_inst_id
undef p_btime p_etime
