
SET VERIFY   OFF
SET FEEDBACK OFF

COL instance_number HEAD "#" FOR 99
COL event                    FOR a30
COL file_name                FOR a60


ACCEPT pSql    PROMPT "Type sql_id: "
ACCEPT pSnapID PROMPT "Type snap_id: "

SELECT a.snap_id
,      a.instance_number
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
,      b.sql_id
,      NVL(b.event,'CPU') event
,      c.file_name
,      count(1)
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
,      dba_data_files c
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id          = '&&pSQL'
   AND a.snap_id         = '&&pSnapID'
   AND b.event IS NULL --CPU
   AND b.p1              = c.file_id
 GROUP BY a.snap_id
,         a.instance_number
,         TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI')
,         b.sql_id
,         NVL(b.event,'CPU')
,         c.file_name
 ORDER BY 1,2,5,7 DESC
/

SET VERIFY   ON
SET FEEDBACK ON
