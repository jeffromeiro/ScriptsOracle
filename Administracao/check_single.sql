prompt ===============================================================================
prompt  STATUS DA INSTANCE
prompt ===============================================================================
SET ECHO OFF
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YY HH24:MI';
ALTER SYSTEM CHECKPOINT;
ALTER SYSTEM SWITCH LOGFILE;
set linesize 300
col host_name for a14
SELECT
instance_name inst_name
, host_name
, parallel
, status
, database_status db_status
, active_state state
, open_mode
, startup_time
FROM v$instance, v$database ;

prompt ===============================================================================
prompt  QUANTIDADE DE SESSOES
prompt ===============================================================================
prompt
select status,  count(*) sessions from v$session where username is not null group by status;
prompt
prompt ===============================================================================
prompt  TABLESPACES
prompt ===============================================================================
Clear Columns Computes Breaks
set lines 200
set pages 200
col file_name for a50
col tablespace_name for a30
col status for a21
compute sum of "Total(Mb)" on report
compute sum of "Free(Mb)" on report
break on report
SELECT  t.tablespace_name,
        ts.contents,
        ts.status,
        round(nvl(t.bytes,0)/1024/1024,1) "Total(Mb)",
        round((nvl(nvl(f.free,ft.free),0)/1024/1024),1) "Free(Mb)",
        round((nvl(nvl(f.free,ft.free),0)*100/t.bytes),1) "% Free",
        decode((case when round((nvl(nvl(f.free,ft.free),0)/1024/1024/1024))>=5 then 'OK' else 'NOK' end),'OK','OK',decode(contents,'UNDO','OK - UNDO TABLESPACE',decode(contents,'TEMPORARY','OK - TEMP TABLESPACE',decode(round((nvl(nvl(f.free,ft.free),0)*100)/t.bytes) ,'0','CRITICAL','1','CRITICAL','2','CRITICAL','3','CRITICAL','4','CRITICAL','5','WARNING','6','WARNING','7','WARNING','8','WARNING','9','WARNING','OK'))))
         STATUS
FROM                    (SELECT d.tablespace_name,
                                sum(d.bytes) bytes
                        FROM    dba_data_files d
                        GROUP BY tablespace_name
                        UNION
                        SELECT  d.tablespace_name,
                                sum(d.bytes) bytes
                        FROM    dba_TEMP_files d
                        GROUP BY tablespace_name) t,
                        (SELECT tablespace_name,
                                sum(bytes) free
                        FROM    dba_free_space
                        GROUP BY tablespace_name) f,
                        (select TABLESPACE_NAME,
                                sum(bytes_free) free
                        from    V$TEMP_SPACE_HEADER
                        group by tablespace_name) ft,
                        dba_tablespaces ts
WHERE   t.tablespace_name = f.tablespace_name(+)
AND     t.tablespace_name = ft.tablespace_name(+)
AND     t.tablespace_name = ts.tablespace_name
ORDER BY 5;
prompt
prompt ===============================================================================
prompt  TAMANHO DO BANCO
prompt ===============================================================================
clear columns
col dados for a10
col undo  for a12
col redo  for a12
col temp  for a12
col livre for a12
col total for a12

select to_char(sum(dados) / 1048576, 'fm99g999g990') dados,
       to_char(sum(undo) / 1048576, 'fm99g999g990') undo,
       to_char(sum(redo) / 1048576, 'fm99g999g990') redo,
       to_char(sum(temp) / 1048576, 'fm99g999g990') temp,
       to_char(sum(free) / 1048576, 'fm99g999g990') livre,
       to_char(sum(dados + undo + redo + temp) / 1048576, 'fm99g999g990') total
from (
  select sum(decode(substr(t.contents, 1, 1), 'P', bytes, 0)) dados,
         sum(decode(substr(t.contents, 1, 1), 'U', bytes, 0)) undo,
         0 redo,
         0 temp,
         0 free
  from dba_data_files f, dba_tablespaces t
  where f.tablespace_name = t.tablespace_name
  union all
  select 0 dados,
         0 undo,
         0 redo,
         sum(bytes) temp,
         0 free
  from dba_temp_files f, dba_tablespaces t
  where f.tablespace_name = t.tablespace_name(+)
  union all
  select 0 dados,
         0 undo,
         sum(bytes * members) redo,
         0 temp,
         0 free
  from v$log
  union all
  select 0 dados,
         0 undo,
         0 redo,
         0 temp,
         sum(bytes) free
  from dba_free_space f, dba_tablespaces t
  where f.tablespace_name = t.tablespace_name and
        substr(t.contents, 1, 1) = 'P'
);
prompt
prompt ===============================================================================
prompt  STATUS DOS DATAFILES
prompt ===============================================================================
prompt
set lines 1000
set pages 2000
col tablespace_name for a15
col name for a60
col status1 for a12
col status2 for a12
col status3 for a12
col online_status for a12
col status_backup for a12
col recover for a7
col error for a5
col "FILE#" for 9999
select  df.tablespace_name,
        d.FILE#,
        d.NAME,
        df.autoextensible,
        df.bytes/1024/1024 "Total(Mb)",
        d.status   status1,
        dh.STATUS  status2,
        df.status  status3,
        --df.online_status,
        b.STATUS   status_backup,
        dh.RECOVER,
        dh.ERROR
from    v$datafile d,
        dba_data_files df,
        v$backup b,
        v$datafile_header dh
where   d.FILE# = dh.FILE#(+)
and     d.FILE# = b.FILE#(+)
and     d.FILE# = df.file_id(+)
order by df.tablespace_name,d.NAME;
prompt
prompt ===============================================================================
prompt  CAMINHO DOS ARCHIVES / VALIDAR A AREA DE ARCHIVE
prompt ===============================================================================
archive log list;
prompt
prompt ===============================================================================
prompt  VERIFICACAO DE OBJETOS INVALIDOS
prompt ===============================================================================
clear columns
select owner, object_type , count(*) "QTD_INVALIDOS" from dba_objects where status ='INVALID'
group by owner, object_type;
prompt
prompt ===============================================================================
prompt  ESTATISTICAS DAS TABELAS
prompt ===============================================================================
prompt
SELECT owner, trunc(last_analyzed) LAST_ANALYZED, count(*) FROM DBA_TABLES
GROUP BY owner, trunc(last_analyzed) ORDER BY OWNER, LAST_ANALYZED;
prompt
prompt ===============================================================================
prompt  SESSOES WAIT
prompt ===============================================================================
prompt
clear columns
SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid and sw.event not like 'SQL%' AND sw.event not like 'rdbms%'
ORDER BY sw.seconds_in_wait DESC;
prompt
prompt ===============================================================================
prompt  SESSOES COM MAIOR I/O
prompt ===============================================================================
clear columns
set lines 1000 trims on
set pagesize 5000
col sid            for 9999
col username       for A16             heading 'Username'
col osuser         for A20             heading 'OS user'
col logical_reads  for 999,999,999,990 heading 'Logical reads'
col physical_reads for 999,999,999,990 heading 'Physical reads'
col hr             for A15              heading 'HR'

select s.sid,
s.username,
s.osuser,
i.block_gets + i.consistent_gets logical_reads,
i.physical_reads,
to_char((i.block_gets + i.consistent_gets - i.physical_reads) / (i.block_gets + i.consistent_gets) * 100, '9990') || '%' hr
from v$sess_io i, v$session s
where i.sid = s.sid and
i.block_gets + i.consistent_gets > 200000
order by logical_reads;
prompt
prompt ===============================================================================
prompt  LISTA DE JOBS AGENDADOS NA DBA_JOBS BROKEN = N
prompt ===============================================================================
prompt
set lines 100 pages 999
col     schema_user format a15
col     fails format 999
col job for 999999
select  job
,       schema_user
,       to_char(last_date, 'hh24:mi dd/mm/yy') last_run
,       to_char(next_date, 'hh24:mi dd/mm/yy') next_run
,       failures fails
,       broken
,       substr(what, 1, 15) what
from    dba_jobs WHERE BROKEN='N'
order by 4
/
prompt
prompt ===============================================================================
prompt  JOBS EM EXECUCAO AGENDADOS NA DBA_JOBS
prompt ===============================================================================
prompt
CLEAR COLUMNS
COL job          FORM 999999
COL interval     FORM a40
COL schema_user  FORM a15
COL failures     FORM 9999
ALTER SESSION SET nls_date_format='dd/mm/yyyy hh24:mi:ss';
SELECT  sid,
        job,
        last_date,
        last_sec,
        this_date,
        this_sec,
        failures,
        instance
FROM    dba_jobs_running
ORDER BY job;
prompt
prompt
prompt ===============================================================================
prompt  LISTA DE JOBS AGENDADOS NA DBA_SCHEDULER_JOBS
prompt ===============================================================================
prompt
SELECT JOB_NAME,ENABLED,TO_CHAR(NEXT_RUN_DATE,'DD-MM-YYHH24:MI:SS') PROXIMA_DATA,RUN_COUNT, FAILURE_COUNT FROM DBA_SCHEDULER_JOBS ;
prompt
prompt ===============================================================================
prompt  JOBS EM EXECUCAO NA V$SCHEDULER_RUNNING_JOBS
prompt ===============================================================================
prompt
CLEAR COLUMNS
set lines 1000 trims on
SELECT * FROM V$SCHEDULER_RUNNING_JOBS ;
prompt
prompt ===============================================================================
prompt  ULTIMOS BACKUPS EXECUTADOS
prompt ===============================================================================
prompt
CLEAR COLUMNS
SELECT substr(OPERATION,1,12) operation
, substr(STATUS,1,10) status
, MBYTES_PROCESSED
--, INPUT_BYTES
--, OUTPUT_BYTES
, substr(OPTIMIZED,1,10) optimized
, substr(OBJECT_TYPE,1,10) object_type
, substr(OUTPUT_DEVICE_TYPE, 1,10) output_device_type
, START_TIME
, END_TIME
, rpad(round ((end_time - start_time) *1440 ,2),8,' ') Minutos
, lpad(round ((end_time - start_time) *1440/60 ,2) ,8,' ') Horas
from V$RMAN_STATUS
where start_time between sysdate-1 and sysdate
order by START_TIME
;
prompt
prompt ===============================================================================
prompt  VERIFICACAO SE OS TABLESPACES ESTAO EM BEGIN BACLKUP
prompt ===============================================================================
prompt
select distinct status from v$backup;
prompt
prompt ===============================================================================
prompt  VERIFICAR SE EXISTE BACKUP EM EXECUCAO E O PROGRESSO
prompt ===============================================================================
prompt
set lines 1000 trims on
select sid, serial#, sofar, totalwork, opname,
       round(sofar/totalwork*100,2) "% completado", round(TIME_REMAINING/60)REMAINING,round(ELAPSED_SECONDS/60)ELAPSED
from   v$session_longops
where  opname like 'RMAN%'
and    opname NOT LIKE '%aggregate%'
and    totalwork != 0
and    sofar <> totalwork;
prompt
prompt ===============================================================================
prompt  TRANSACOES LONGAS
prompt ===============================================================================
prompt
set lines 100
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10
col sid for 99999
SELECT s.sid,
       s.serial#,
       s.machine,
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct
FROM   v$session s,
       v$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial# and sl.time_remaining > 0 ;
prompt
prompt ===============================================================================
prompt  TOP 10 SESSIONS
prompt ===============================================================================
prompt
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20
col osuser for a10

SELECT NVL(a.username, '(oracle)') AS username,
       a.osuser,
       a.sid,
       a.serial#,
       a.lockwait,
       a.status,
       a.machine,
       a.program,
       TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session a,
       v$sesstat c,
       v$statname d
WHERE  a.sid        = c.sid
AND    c.statistic# = d.statistic#
AND    d.name       = DECODE(UPPER('c.value'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
                                                   and rownum < 11
ORDER BY c.value DESC;
prompt
prompt ===============================================================================
prompt  MEMORIA ALOCADA POR SESSAO
prompt ===============================================================================
SET LINESIZE 200

COLUMN username FORMAT A20
COLUMN module FORMAT A30

SELECT NVL(a.username,'(oracle)') AS username,
       a.module,
       A.OSUSER,
       a.program,
       Trunc(b.value/1024/1024) AS memory_MB
FROM   v$session a,
       v$sesstat b,
       v$statname c
WHERE  a.sid = b.sid
AND    b.statistic# = c.statistic#
AND    c.name = 'session pga memory'
AND    a.program IS NOT NULL AND Trunc(b.value/1024/1024) > 0
ORDER BY b.value DESC;
prompt
prompt ===============================================================================
prompt  VERIFICACAO DOS LOGFILES
prompt ===============================================================================
prompt
CLEAR COLUMNS
col member for a60
set pagesize 5000
set lines 1000 trims on
select f.member,f.GROUP#, l.members, l.bytes,l.SEQUENCE#, f.status status_1, l.status status_2, f.IS_RECOVERY_DEST_FILE from v$logfile f join v$log l
on l.group# = f.group#
order by group#;
prompt
prompt ===============================================================================
prompt  FIM DO CHECKLIST
prompt ===============================================================================
