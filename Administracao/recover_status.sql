set pagesize 20000
set linesize 500
set trimspool on
set pause off
set serveroutput on
set feedback on
set echo off
set numformat 999999999999999
set colsep "|"

prompt -- **************************************************************
prompt -- INSTANCE
prompt -- **************************************************************
select host_name
    , instance_name
    , version
    , status
    , logins
    , USER
    , to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') data  
 from v$instance;

prompt -- **************************************************************
prompt -- DATABASE
prompt -- **************************************************************
select NAME
     , LOG_MODE
     , to_char(RESETLOGS_TIME,'dd-mm-yyyy hh24:mi:ss') RESETLOGS_TIME
     , OPEN_MODE
     , PROTECTION_MODE
     , PROTECTION_LEVEL
     , DB_UNIQUE_NAME 
  from v$database;

prompt -- **************************************************************
prompt -- DATAFILES
prompt -- **************************************************************
select substr(name, 1, 50), status 
  from v$datafile; 

prompt -- **************************************************************
prompt -- HEADER
prompt -- **************************************************************
select file#
     , substr(name,1,50)
     , tablespace_name
     , recover
     , fuzzy
     , checkpoint_change# 
  from v$datafile_header 
 order by recover; 

prompt -- **************************************************************
prompt -- BACKUP
prompt -- **************************************************************
select * 
  from v$backup; 
  
select name
     , open_mode
     , checkpoint_change#
     , ARCHIVE_CHANGE# 
  from v$database; 

prompt -- **************************************************************
prompt -- LOG
prompt -- **************************************************************
select GROUP#
     , THREAD#
     , SEQUENCE#
     , MEMBERS
     , ARCHIVED
     , STATUS
     , FIRST_CHANGE# 
  from v$log; 

prompt -- **************************************************************
prompt -- LOGFILE
prompt -- **************************************************************
select GROUP#
     , substr(member,1,60) 
  from v$logfile; 

prompt -- **************************************************************
prompt -- LOGHISTORY
prompt -- **************************************************************
select * 
  from v$log_history; 

prompt -- **************************************************************
prompt -- RECOVER FILE
prompt -- **************************************************************
select * 
  from v$recover_file; 
  
prompt -- **************************************************************
prompt -- RECOVER LOG
prompt -- **************************************************************
select * 
  from v$recovery_log; 

prompt -- **************************************************************
prompt -- X$KCVFH
prompt -- **************************************************************
select HXFIL File_num
     , substr(HXFNM,1,40) File_name
     , FHTYP Type
     , HXERR Validity
     , FHSCN SCN
     , FHTNM TABLESPACE_NAME
     , FHSTA status
     , FHRBA_SEQ Sequence 
  from X$KCVFH; 
  
prompt -- **************************************************************
prompt -- INSTANCE RECOVER
prompt -- **************************************************************
SELECT * 
  FROM  SYS.GV_$INSTANCE_RECOVERY;
  
prompt -- **************************************************************
prompt -- RECOVER FILE STATUS
prompt -- **************************************************************
select INST_ID
     , FILENUM
     , FILENAME
     , STATUS
  from SYS.GV_$RECOVERY_FILE_STATUS;

prompt -- **************************************************************
prompt -- RECOVER PROGRESS
prompt -- **************************************************************
select INST_ID
     , START_TIME
     , TYPE
     , ITEM
     , UNITS
     , SOFAR
     , TOTAL
     , TIMESTAMP
 from SYS.GV_$RECOVERY_PROGRESS;

prompt -- **************************************************************
prompt -- RECOVERY STATUS
prompt -- **************************************************************
select INST_ID
     , RECOVERY_CHECKPOINT
     , THREAD
     , SEQUENCE_NEEDED
     , SCN_NEEDED
     , TIME_NEEDED
     , PREVIOUS_LOG_NAME
     , PREVIOUS_LOG_STATUS
     , REASON
  from SYS.GV_$RECOVERY_STATUS;

prompt -- **************************************************************
prompt -- RECOVER LOG
prompt -- **************************************************************
select *
  from SYS.GV_$RECOVER_FILE;
  
