SET LINES 200 PAGES 50000
col BF_EXEC FORM 999,999,999
col DR_EXEC FORM 999,999,999
col TOTAL_IO FORM 999,999,999,999
col BUFFER_GETS FORM 999,999,999,999
col DISK_READS FORM 999,999,999,999
col rows_por_exec FORM 999,999,999
col usuario form a15

REPHEADER LEFT COL 9 '**************************************************************************************' SKIP 1 -
               COL 9 '* TOP 10 COMANDOS ORDENADOS POR LEITURAS FÍSICAS E LÓGICAS NOS ULTIMOS 30 MINUTOS    *' SKIP 1 -
               COL 9 '**************************************************************************************' SKIP 2

			   
select * from
(
SELECT INST_ID DUMMY, SQL_ID, 
		parsing_schema_name usuario,
		round(buffer_gets+disk_reads,2) total_io, 
		RANK() OVER (PARTITION BY INST_ID ORDER BY (buffer_gets+disk_reads) DESC) RANK,
		round(BUFFER_GETS, 2) buffer_gets,
        round(DISK_READS, 2) disk_reads, 
	    round(buffer_gets/decode(executions,0,1,executions),5) BF_EXEC 
	   ,round(disk_reads/decode(executions,0,1,executions),5) DR_EXEC,
	    round(ROWS_PROCESSED/decode(executions,0,1,executions),2) rows_por_exec,
       to_char(LAST_ACTIVE_TIME,'dd/mm hh24:mi:ss') last_active,
	   EXECUTIONS EXEC
  FROM gV$SQLAREA
  where last_active_time BETWEEN SYSDATE - 1/24/2 AND SYSDATE and executions > 0
  order by total_io desc
  ) t
 where rownum < 11;
 
REPHEADER OFF