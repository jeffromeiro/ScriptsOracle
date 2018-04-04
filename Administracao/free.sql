set pagesize 500 echo on termout on
set lines 1000
column dummy noprint
column pct_used format 999.9 heading "%|Used" 
column name format a36 heading "Tablespace Name" 
column bytes format 999,999,999,999,999 heading "Total Bytes" 
column used format 999,999,999,999,999 heading "Used" 
column free format 999,999,999,999,999 heading "Free" 
break on report 
compute sum of bytes on report 
compute sum of used on report 
compute sum of free on report 
select a.tablespace_name name,
b.tablespace_name dummy,
sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id ) bytes,
sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id ) -
sum(a.bytes)/count( distinct b.file_id ) used,
sum(a.bytes)/count( distinct b.file_id ) free,
100 * ( (sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )) -
 (sum(a.bytes)/count( distinct b.file_id ) )) /
(sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )) pct_used
from sys.dba_free_space a, sys.dba_data_files b
where a.tablespace_name = b.tablespace_name
group by a.tablespace_name, b.tablespace_name
order by 6
/
