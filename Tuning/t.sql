select * from (
select /*+ ordered use_nl (b st) */
       ratio_to_report(nvl(parses,0)) over ()*100 pct,
        t.* from (
          select sq.*,
                 substr(trim(st.sql_text), 1, 30) sql_text
            from
               ( SELECT SQL_ID                      ,
                        SUM(BUFFER_GETS_DELTA) buffer_gets,
                        SUM(DISK_READS_DELTA) disk_reads,
                        to_char(SUM(CPU_TIME_DELTA)/1000000,'9999990,9') cpu_time_s,
                        to_char(SUM(ELAPSED_TIME_DELTA)/1000000,'9999990,9') ELAP_time_s,
                        SUM(PARSE_CALLS_DELTA) parses,
                        SUM(EXECUTIONS_DELTA) execs
                FROM    DBA_HIST_SQLSTAT
                WHERE   INSTANCE_NUMBER =  &p_inst_id
                    AND &snap_inicial   <  SNAP_ID
                    AND SNAP_ID         <= &snap_final
                GROUP BY SQL_ID ) sq,
                DBA_HIST_SQLTEXT st
           WHERE SQ.SQL_ID = ST.SQL_ID
           AND      ST.COMMAND_TYPE <> 47
         ) t
  order by pct desc
) where rownum <= 10