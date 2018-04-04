accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
accept p_offender_type          number prompt 'Ordenar por (1-BufGets, 2-DiskRds, 3-CPU, 4-Elap, 5-Parses, 6-Execs): '
accept p_inst_id    number prompt '        Instance ID: '
accept top_statements          number prompt ' Top-N Statements: ' 

spool top_commands_9i.txt

SELECT -1 
       qtd, 
       -1 
       peak_id, 
       Round(pct, 2) 
       pct, 
       MODULE, 
       parsing_schema_name, 
       To_char(hash_value) 
       sql_id, 
       buffer_gets, 
       Round(buffer_gets / execs, 2) 
       buffer_gets_by_exec, 
       disk_reads, 
       Round(disk_reads / execs, 2) 
       disk_reads_by_exec, 
       Round(cpu_time_s, 2) 
       cpu_time_s, 
       Round(Decode(execs, 0, 0, 
                           cpu_time_s / execs), 2) 
       cpu_time_by_exec_s, 
       Round(elap_time_s, 2) 
       elap_time_s, 
       Round(Decode(execs, 0, 0, 
                           elap_time_s / execs), 2) 
       elap_time_by_exec_s, 
       parses, 
       execs, 
       Replace(Replace(Substr(sql_text, 1, 32), Chr(13), NULL), Chr(10), NULL) 
       sql_text 
FROM   (SELECT CASE 
                 WHEN &p_offender_type = 1 THEN Ratio_to_report(buffer_gets) 
                                                over () * 100 
                 WHEN &p_offender_type = 2 THEN Ratio_to_report(disk_reads) 
                                                over () * 100 
                 WHEN &p_offender_type = 3 THEN Ratio_to_report( 
                                              To_number(cpu_time_s)) 
                                                over () * 100 
                 WHEN &p_offender_type = 4 THEN Ratio_to_report( 
                                              To_number(elap_time_s)) 
                                                over () * 100 
                 WHEN &p_offender_type = 5 THEN Ratio_to_report(parses) 
                                                over () * 100 
                 WHEN &p_offender_type = 6 THEN Ratio_to_report(execs) 
                                                over () * 100 
               END PCT, 
               t.* 
        FROM   (SELECT e.MODULE, 
                       NULL 
                               parsing_schema_name, 
                       st.hash_value 
                       hash_value 
               /* -> GAMBIARRA de 10g pra 9i: st.OLD_HASH_VALUE HASH_VALUE*/, 
                       e.buffer_gets - Nvl(b.buffer_gets, 0) 
                       BUFFER_GETS, 
                       e.disk_reads - Nvl(b.disk_reads, 0) 
                       disk_reads 
                       , 
                       ( e.cpu_time - Nvl(b.cpu_time, 0) ) / 1000000 
                       CPU_TIME_s, 
                       ( e.elapsed_time - Nvl(b.elapsed_time, 0) ) / 1000000 
                       elap_time_s, 
                       e.parse_calls - Nvl(b.parse_calls, 0) 
                       parses, 
                       e.executions - Nvl(b.executions, 0) 
                       execs, 
                       Substr(Trim(st.sql_text), 1, 64) 
                       sql_text 
                FROM   stats$sql_summary e, 
                       stats$sql_summary b, 
                       stats$sqltext st 
                WHERE  e.instance_number = &p_inst_id 
                       AND b.snap_id(+) = (select min(snap_id) from stats$snapshot where SNAP_TIME = to_date('&p_btime','yyyymmddhh24mi') ) 
                       AND b.dbid(+) = e.dbid 
                       AND b.instance_number(+) = e.instance_number 
                       AND b.hash_value(+) = e.hash_value 
                       AND b.address(+) = e.address 
                       AND b.text_subset(+) = e.text_subset 
                       AND e.snap_id = (select max(snap_id) from stats$snapshot where SNAP_TIME = to_date('&p_etime','yyyymmddhh24mi') ) 
                       AND e.hash_value = st.hash_value 
                       AND e.text_subset = st.text_subset 
                       AND e.executions > Nvl(b.executions, 0) 
                       AND st.piece = 0 
                       /* garante apenas uma linha da sqltext por hash*/ 
                       AND st.command_type IN ( 3, 2, 6, 7, 
                                                42, 47 ) 
                       AND 1 = 1 
                       AND 1 = 1) t 
        ORDER  BY pct DESC) 
WHERE  ROWNUM <= &top_statements ;

spool off