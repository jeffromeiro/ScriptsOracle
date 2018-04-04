set linesize 1000 longchunksize 1000 long 10000000
set serveroutput ON size 1000000 format WORD_WRAPPED
set trimout ON trimspool ON newpage 1 underline "-"
set autotrace OFF flush OFF verify OFF
set pause OFF pause Continua...
set markup HTML OFF
set colsep "  "
set sqlprompt "_date '['_user']' '['_connect_identifier']' >"  
set time on
set timing on

column seq              noprint
column host_name        format a12
column instance_name    format a15
column version          format a12
column status           format a10
column logins           format a12
column user             format a12
column qtde             format 999g999g999g999
column linhas           format 999g999g999g999
column num_rows         format 999g999g999
column extents          format 99g999g999
column mbytes           format 999g990
column mb               format 999g999g999g999
column owner            format a25
column table_name       format a12
column index_name       format a20
column object_name      format a30
column segment_name     format a20
column partition_name   format a16
column tablespace_name  format a16
column object_type      format a20
column segment_type     format a20
column last_analyzed    format a20
column name             format a20

set heading ON time ON timing ON feedback 6 pagesize 10000
set echo OFF termout ON trimspool on

prompt 
prompt ***********************************************************
prompt Informacoes da instancia
prompt ***********************************************************
select host_name, instance_name, version, status, logins, USER, to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') data
  from v$instance
/

prompt 
prompt ***********************************************************
prompt Informacoes do banco de dados
prompt ***********************************************************
select NAME, LOG_MODE, to_char(RESETLOGS_TIME,'dd-mm-yyyy hh24:mi:ss') RESETLOGS_TIME, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, DB_UNIQUE_NAME 
from v$database
/

rem prompt 
rem prompt ***********************************************************
rem prompt Contagem de objetos invalidos
rem prompt ***********************************************************
rem break on owner skip 1 on report
rem select owner
rem      , object_type
rem      , count(*) as qtde
rem   from dba_objects
rem  where status = 'INVALID'
rem  group by owner, object_type
rem  order by owner, object_type
rem /

rem select owner
rem      , object_type
rem      , object_name
rem      , status
rem   from dba_objects 
rem  where status  = 'INVALID'
rem    and owner not in ('OLAPSYS', 'PUBLIC');

clear breaks
clear computes