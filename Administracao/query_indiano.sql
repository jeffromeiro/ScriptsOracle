set pagesize 20000
set linesize 180
set pause off
set serveroutput on
set feedback on
set echo on
set numformat 999999999999999


select substr(name, 1, 50), status from v$datafile; 

select substr(name,1,50), recover, fuzzy, checkpoint_change# from v$datafile_header; 

select * from v$backup; 

select name, open_mode, checkpoint_change#, ARCHIVE_CHANGE# from v$database; 

select GROUP#,THREAD#,SEQUENCE#,MEMBERS,ARCHIVED,STATUS,FIRST_CHANGE# from v$log; 

select GROUP#,substr(member,1,60) from v$logfile; 

select * from v$log_history; 

select * from v$recover_file; 

select * from v$recovery_log; 

select HXFIL File_num,substr(HXFNM,1,40) File_name,FHTYP Type,HXERR Validity, 
       FHSCN SCN, FHTNM TABLESPACE_NAME,FHSTA status ,FHRBA_SEQ Sequence 
from   X$KCVFH; 



