set colsep "  "
clear breaks 
clear computes 
clear columns
col file_name format a50
col tablespace_name format a30
col mb   form 999g999g999g999
col free form 999g999g999g999
set pages 1200 lin 350

compute sum of mb   tablespace_name on report
compute sum of free tablespace_name on report

break on tablespace_name skip 1 on report

select tablespace_name
     , file_name
     , ROUND(sum(bytes)/1024/1024,0) as MB
     , ROUND(sum(maxbytes)/1024/1204,0) as maxMB
     , decode(maxbytes,0,0,ROUND(sum(maxbytes-bytes)/1024/1204,0)) free
     , AUTOEXTENSIBLE
  from dba_data_files
 where tablespace_name IN(&tablespaces)
 group by tablespace_name, file_name, AUTOEXTENSIBLE,maxbytes
 order by tablespace_name, file_name
/
