SELECT SQL_ID,
       (SUM(b.elapsed_time_delta)) / 1000000 AS ELAPSED_TIME,
       SUM(b.executions_delta) AS EXECUTIONS,
       SUM(b.buffer_gets_delta) AS BUFFER_GETS,
       (SUM(b.cpu_time_delta)) / 1000000 AS CPU_TIME,
       SUM(b.disk_reads_delta) AS DISK_READS,
       SUM(b.fetches_delta) AS FETCHES,
       SUM(b.rows_processed_delta) AS ROWS_PROCESSED
  FROM dba_hist_snapshot A, dba_hist_sqlstat B
 WHERE A.SNAP_ID BETWEEN
       (SELECT MIN(snap_id)
          FROM dba_hist_snapshot
         WHERE begin_interval_time >=
               to_date('&data_inicial', 'dd/mm/yyyy hh24:mi:ss')) AND
       (SELECT MAX(snap_id)
          FROM dba_hist_snapshot
         WHERE begin_interval_time <=
               to_date('&data_final', 'dd/mm/yyyy hh24:mi:ss'))
   AND A.SNAP_ID = B.SNAP_ID
   AND A.DBID = B.DBID
   AND A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
   AND B.plan_hash_value <> 0
   AND UPPER(B.MODULE) = '&MODULE'
 GROUP BY SQL_ID
 ORDER BY 2 DESC;
