column sql format a100
set linesize 155
set pagesize 200
 
prompt This script shows SQL statement that account for more than
prompt a certain percentage of disk reads.
prompt
 
column executes format 9999999
break on load on executes
 
select
substr(
to_char(
100 * s.disk_reads / t.total_disk_reads,
'99.00'
),
2
) ||
'%' load,
s.executions executes,
p.sql_text sql
from
( 
select
sum(disk_reads) total_disk_reads
from
sys.v_$sql
where
command_type != 47
) t,
sys.v_$sql s,
sys.v_$sqltext p
where
100 * s.disk_reads / t.total_disk_reads > 2.5 and
s.disk_reads > 50 * s.executions and
s.command_type != 47 and
p.address = s.address
order by
1, s.address, p.piece
;