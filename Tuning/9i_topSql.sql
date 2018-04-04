--------------------------------------------------------------------------------
-- File name:   9i_topSql.sql
-- Purpose:     Get the top 10 sql based on a criterion specified by the user
-- Author:      Guilherme Botelho Diniz Junqueira
-- Usage:       Run @9i_topSql.sql
--------------------------------------------------------------------------------

SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on

col partial_sql_text format a50
prompt "Pick one of the following for the ordering of the results: elapsed_time, executions, cpu_time or disk_reads"

SELECT hash_value,
       child_number,
	   substr(sql_text, 1, 50) as partial_sql_text,
	   elapsed_time,
	   executions,
	   cpu_time,
	   disk_reads
FROM (SELECT hash_value,
             child_number,
			 sql_text,
			 elapsed_time,
			 executions,
			 cpu_time,
             disk_reads,
      RANK () OVER (ORDER BY &criterion DESC) AS elapsed_rank
      FROM v$sql)
WHERE elapsed_rank <= 10;