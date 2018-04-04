-----------------------------------------------------------
select sql.sql_id,
       SUM(sql.executions_delta) "EXECUTIONS",
        sum(sql.elapsed_time_delta / 1000000) /
             sum(CASE
                   WHEN sql.executions_delta = 0 THEN
                    1
                   ELSE
                    sql.executions_delta
                 END) as "ELAP_PER_EXEC"
  from dba_hist_sqlstat sql
 WHERE sql.DBID = 1714303173  
 and sql.snap_id = 24274
 GROUP BY sql.sql_id
 order by 1;
----------------------------------------------------------- 

----------------------------------------------------------- 
 select *
   from dba_hist_sqlstat SQL
--  where SQL.dbid = 1714303173
    where sql.snap_id between  16218 and  17349
    and sql.sql_id = 'ayhyghwjp82au'
    order by sql.snap_id
-----------------------------------------------------------
select *
  from dba_hist_sqltext txt
-- where txt.dbid = 1714303173
      -- AND txt. .snap_id = 21013
   where txt.sql_id = '4sbnsrcq6hf8d'
----------------------------------------------------------- 
SELECT *
  FROM DBA_HIST_SQLBIND bin
 where bin.snap_id = 25132
   and bin.sql_id = '4sbnsrcq6hf8d';
----------------------------------------------------------- 
select pl.id,
       pl.operation,
       pl.options,
       pl.object_owner,
       pl.object_name,
       pl.object_type,
       pl.cost
  from dba_hist_sql_plan pl
-- where plan.dbid = 1714303173
 where pl.plan_hash_value = 1387430700
   and pl.sql_id = '54zwtfw02fra0'
----------------------------------------------------------
 SELECT SQL.snap_id,
        SN.begin_interval_time,
        SQL.sql_id,
        SQL.plan_hash_value,
        SQL.executions_delta AS EXECS,
        SQL.buffer_gets_delta BUFFER,
        SQL.disk_reads_delta DSK_READS,
        SQL.rows_processed_delta row_prc,
        round(SQL.elapsed_time_delta / 1000000, 2) AS ELAPSED_TOTAL,
        round(SQL.elapsed_time_delta / 1000000/sql.executions_delta, 4) AS ELAP_EXEC
   FROM DBA_HIST_SQLSTAT SQL, DBA_HIST_SNAPSHOT SN
  WHERE SQL.dbid = SN.dbid
    AND SQL.snap_id = SN.snap_id
    AND SQL.sql_id = '4vy9pv7ffdnnm'
    and sql.executions_delta > 0
    and sql.instance_number=1
    and SQL.instance_number = sn.instance_number
--    AND SQL.dbid = 1714303173
  ORDER BY SQL.snap_id;
-----------------------------------------------------------

4vy9pv7ffdnnm||493276797||a19hgghp4cp3g||
4sbnsrcq6hf8d||1204675665||bx9xh9hfcgn3r||
54zwtfw02fra0||1400429544||1387430700