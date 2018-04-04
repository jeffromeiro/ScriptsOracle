col name format a40 
select name, bytes/1024/1024 as MB 
from v$sgastat 
order by bytes
/ 
 
set head off
select 'total of SGA MB  '||sum(bytes)/1024/1024 
from v$sgastat ;