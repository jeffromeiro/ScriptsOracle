col inst form 99 
col child# form 99
SELECT a.inst_id inst, a.child_number child#,A.EXECUTIONS exec, A.FETCHES/a.EXECUTIONS fetches_exec ,plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / a.EXECUTIONS, 4) elap_exec,
       round(A.CPU_TIME / 1000000 / a.EXECUTIONS, 4) cpu_seg,
       round(a.BUFFER_GETS / a.EXECUTIONS, 4) bg_exec,
       round(a.DISK_READS / a.EXECUTIONS, 4) dr_exec, A.ROWS_PROCESSED/A.EXECUTIONS rows_exec,
       A.LAST_LOAD_TIME,
       a.LAST_ACTIVE_TIME 
  FROM gV$SQL A 
WHERE SQL_ID = '&sql_id'
order by a.plan_hash_value;

undef sql_id
