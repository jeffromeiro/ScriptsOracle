
Qual o primeiro snap_id para o dia de hoje?

SELECT MIN(snap_id)
  FROM dba_hist_snapshot
 WHERE 1=1
   --AND begin_interval_time >= TRUNC(SYSDATE)
   AND begin_interval_time >= TRUNC(SYSDATE)
/

Quais os 10 principais eventos de espera por instância, para um determinado período?

BREAK     ON instance_number
COL event FOR a80

SELECT * FROM
(
SELECT ash.instance_number
,      NVL(ash.event,'CPU') as event
,      COUNT(1)
  FROM dba_hist_active_sess_history ash
,      dba_hist_snapshot snap
 WHERE 1 = 1
   AND snap.snap_id         = ash.snap_id
   AND snap.dbid            = ash.dbid
   AND snap.instance_number = ash.instance_number
   AND snap.snap_id         >= 55964
   AND snap.instance_number = &INST_ID
 GROUP BY ash.instance_number
,         ash.event
 ORDER BY 1,3 DESC
) 
WHERE ROWNUM < 11


Evento snap a snap, para um determinado período

COL time FOR A25
SELECT a.snap_id
,      a.instance_number AS inst_id
,      b.event
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
,      COUNT(1)
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND a.snap_id         >= 40880
   AND a.instance_number = &INST_ID
   AND b.event           = 'log file sync'
 GROUP BY a.snap_id
,      a.instance_number
,      b.event
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI')
   ORDER BY 1



Quais os 10 principais sql_ids por evento e por instancia, para um determinado periodo?




COL event FOR a30
COL command_type FOR a15
COL user_id FOR 999
COL module FOR a20

SELECT * FROM
(
WITH TOTAL AS
(SELECT COUNT(1) TOTAL FROM dba_hist_active_sess_history)
SELECT ash.instance_number
,      NVL(ash.event,'CPU') as event
,      DECODE (txt.command_type,
                          1, 'Create Table',
                          2, 'Insert',
                          3, 'Select',
                          6, 'Update',
                          7, 'Delete',
                          26, 'Lock Table',
                          35, 'Alter Database',
                          42, 'Alter Session',
                          44, 'Commit',
                          45, 'Rollback',
                          46, 'Savepoint',
                          47, 'Begin/Declare',
                          170, 'call',
                          txt.command_type) command_type
,      ash.user_id
,      ash.module
,      ash.sql_id
,      ROUND(RATIO_TO_REPORT (SUM(total.total)) OVER () * 100,2) percentage
,      COUNT(1)
  FROM dba_hist_active_sess_history ash
,      dba_hist_snapshot snap
,      dba_hist_sqltext txt
,      total
 WHERE 1 = 1
   AND snap.snap_id         = ash.snap_id
   AND snap.dbid            = ash.dbid
   AND snap.instance_number = ash.instance_number
   AND ash.dbid             = txt.dbid
   AND ash.sql_id           = txt.sql_id
   AND snap.snap_id         >= 55964
   AND snap.instance_number = 1
   AND ash.sql_id           IS NOT NULL
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
   --AND event = 'log file parallel write'
   --AND NVL(ash.event,'CPU') = 'CPU'
   --AND ash.sql_id = '0x73dfn8aw85n'
   --AND ash.sql_id = '39wxmbukyv6dr'
   --AND ash.sql_id = '5za27f5vs6ct6'
 GROUP BY ash.instance_number
,         txt.command_type
,         ash.user_id
,         ash.module
,         ash.event
,         ash.sql_id
 ORDER BY 1,2,8 DESC
) 
WHERE ROWNUM < 11