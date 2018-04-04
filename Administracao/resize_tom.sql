set verify off
set lines 200
col tablespace_name form a14
column file_name format a50 word_wrapped
column smallest format 999,990 heading "Smallest|Size|Poss."
column currsize format 999,990 heading "Current|Size"
column savings  format 999,990 heading "Poss.|Savings"
break on report
compute sum of savings on report

column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

column cmd format a90 word_wrapped

set trimspool on
spool resize.lis

column cmd format a100 word_wrapped

select c.tablespace_name, a.file_id, 'alter database datafile '''||file_name||''' resize ' ||
        ceil( (nvl(hwm,1)*c.block_size )/1024/1024 )  || 'm;' cmd, c.status,
       ceil( blocks*c.block_size/1024/1024) - ceil( (nvl(hwm,1)*c.block_size)/1024/1024 ) savings, 
       a.bytes/1024/1024 bytes
from dba_data_files a, dba_tablespaces c,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b 
where a.file_id = b.file_id(+)
and a.tablespace_name=c.tablespace_name
and ceil( blocks*c.block_size/1024/1024) - ceil( (nvl(hwm,1)*c.block_size)/1024/1024 ) > 0
order by savings
/



spool off

