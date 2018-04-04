clear breaks
col file_name  format a70
col member     format a70
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
     , b.status tbs_status
     , a.file_name 
     , round(sum(a.bytes)/1024/1024,0) as MB
  from dba_data_files a
     , dba_tablespaces b
 where a.tablespace_name = b.tablespace_name
 group by a.tablespace_name 
     , b.status
     , a.file_name
 order by filesystem, tbs_name;

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
 
  select a.group#
      , a.THREAD#
      , a.SEQUENCE#
      , a.ARCHIVED
      , b.member
      , b.status
      , round(sum(a.bytes)/1024/1024,0) as mb
   from v$log a
      , v$logfile b
  group by a.group#
         , a.THREAD#
         , a.SEQUENCE#
         , a.ARCHIVED
         , b.member
         , b.status
  order by a.group#
         , b.member;
         
  col name form a70
  
  select *
    from v$controlfile;
 
 clear breaks

 
 
 