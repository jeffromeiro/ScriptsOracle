col inst form 99 
col child# form 99
SELECT a.sql_id , a.child_number child#,A.EXECUTIONS exec, plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / a.EXECUTIONS, 4) elap_exec,
       round(A.CPU_TIME / 1000000 / a.EXECUTIONS, 4) cpu_seg,
       round(a.BUFFER_GETS / a.EXECUTIONS, 4) bg_exec,
       round(a.DISK_READS / a.EXECUTIONS, 4) dr_exec, A.ROWS_PROCESSED/A.EXECUTIONS rows_exec,
       A.LAST_LOAD_TIME,
       a.LAST_ACTIVE_TIME 
  FROM gV$SQL A 
WHERE SQL_ID in (select sql_id from v$session where status = 'ACTIVE' and username is not null and username not in ('SYS','SYSTEM','MITOPER'))
order by bg_exec desc,a.sql_id,a.plan_hash_value;

undef sql_id
