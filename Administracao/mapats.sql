set pause off
set lines 200
set pages 20000
set trimspool 	on
set trimout 	on

break on file_id skip page duplicate

col segment_name format a30
col bytes format 999,999,999,999
col col1 new_value sp

set feed off
set term off
select upper(instance_name)||'_TSmapa'||to_char(sysdate,'ddmmyyyy_hh24mi')  col1
from v$instance
/
set feed on
set trimspool 	on
set trimout 	on
spool &sp


select tablespace_name,file_id,'FREE >->->->->->->-> ' segment_name , block_id,bytes
from dba_free_space
union
select tablespace_name,file_id,segment_name            segment_name ,block_id,bytes
from dba_extents
order by tablespace_name,file_id,block_id asc
/
spool off
set pages 90
set pause off

-- exit
