
SET VERIFY   OFF
SET FEEDBACK OFF

COL time  FOR a18
COL event FOR a30

ACCEPT pBegin PROMPT "Type begin date (ddmmyyyy): "

ACCEPT pEnd   PROMPT "Type end date (ddmmyyyy)[SYSDATE]:"

ACCEPT pSql  PROMPT "Type sql_id: "

SELECT a.snap_id
,      a.instance_number
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
,      b.sql_id
,      b.event
,      count(1)
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id          = '&&pSQL'
   AND a.begin_interval_time BETWEEN TO_DATE('&&pBegin','DD-MM-YYYY') 
                                 AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
 GROUP BY a.snap_id
,         a.instance_number
,         TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI')
,         b.sql_id
,         b.event
 ORDER BY 1,2,6 DESC
/

SET VERIFY   ON
SET FEEDBACK ON

