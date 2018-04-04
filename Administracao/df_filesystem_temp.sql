clear breaks
col file_name  format a70
col filesystem format a20
col tbs_name   format a30
col mb form    999g999g999
set pages 1200 lin 350
set colsep '|'
compute sum of mb on filesystem
compute sum of mb on report 
break on filesystem skip 2 on MB on report

select substr(a.file_name,1,19) filesystem
     , a.tablespace_name tbs_name
     , a.status tbs_status
     , a.file_name 
     , round(sum(a.bytes)/1024/1024,0) as MB
  from dba_temp_files a
 group by a.tablespace_name 
     , a.status
     , a.file_name
 order by filesystem, tbs_name;

