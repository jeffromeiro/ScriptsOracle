
 SELECT DATA,
   NVL (MAX (DECODE (INSTANCE_NUMBER,1, Cursor)), NULL) MIPPNP1,
   NVL (MAX (DECODE (INSTANCE_NUMBER,2, Cursor)), NULL) MIPPNP2
   FROM (    
  SELECT TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY') DATA,
    sys.INSTANCE_NUMBER,
   MAX(sys.value) Cursor
    FROM  dba_hist_sysstat sys,
    DBA_HIST_SNAPSHOT SNAP
  WHERE sys.DBID                = SNAP.DBID
  AND sys.SNAP_ID               = SNAP.SNAP_ID
  AND sys.INSTANCE_NUMBER       = SNAP.INSTANCE_NUMBER
  AND SNAP.BEGIN_INTERVAL_TIME >= SYSDATE -30
-- AND SNAP.BEGIN_INTERVAL_TIME >= TRUNC(ADD_MONTHS(SYSDATE,   -0),'MM')
--  AND SNAP.END_INTERVAL_TIME   <= LAST_DAY(ADD_MONTHS(SYSDATE,-0))
  AND sys.stat_name = 'opened cursors current'
 GROUP BY TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY'),sys.INSTANCE_NUMBER
 ORDER BY TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY')
 )
 GROUP BY DATA
 ORDER BY DATA desc



 
 
 SELECT DATA,
   NVL (MAX (DECODE (INSTANCE_NUMBER,1, Cursor)), NULL) MIPPNP1,
   NVL (MAX (DECODE (INSTANCE_NUMBER,2, Cursor)), NULL) MIPPNP2
   FROM (    
  SELECT TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY') DATA,
    sys.INSTANCE_NUMBER,
   MAX(sys.value) Cursor
    FROM  dba_hist_sysstat sys,
    DBA_HIST_SNAPSHOT SNAP
  WHERE sys.DBID                = SNAP.DBID
  AND sys.SNAP_ID               = SNAP.SNAP_ID
  AND sys.INSTANCE_NUMBER       = SNAP.INSTANCE_NUMBER
  AND SNAP.BEGIN_INTERVAL_TIME >= SYSDATE -30
-- AND SNAP.BEGIN_INTERVAL_TIME >= TRUNC(ADD_MONTHS(SYSDATE,   -0),'MM')
--  AND SNAP.END_INTERVAL_TIME   <= LAST_DAY(ADD_MONTHS(SYSDATE,-0))
  AND sys.stat_name = 'opened cursors current'
 GROUP BY TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY'),sys.INSTANCE_NUMBER
 ORDER BY TO_CHAR(SNAP.END_INTERVAL_TIME, 'DD/MM/YYYY')
 )
 GROUP BY DATA
 ORDER BY DATA desc

 
  select max(a.value) as highest_open_cur, p.value as max_open_cur
   from v$sesstat a, v$statname b, v$parameter p
   where a.statistic# = b.statistic# 
   and b.name = 'opened cursors current'
   and p.name= 'open_cursors'
   group by p.value;
   
   
   
   
SELECT 'Mês;Instance Name;Estimated MB;Size Factor;Min Objects;Max Objects' AS CSV FROM DUAL;

SELECT TO_CHAR(snap.end_interval_time, 'mon/yyyy') ||';'||
  i.instance_name||';'||
  MAX(shared.shared_pool_size_for_estimate)||';'||
  trim(TO_CHAR(TRUNC(shared.shared_pool_size_factor,1))) ||';'||
  MIN(shared.ESTD_LC_MEMORY_OBJECTS) ||';'||
  MAX(shared.ESTD_LC_MEMORY_OBJECTS) as dados
FROM sys.dba_hist_shared_pool_advice shared,
  sys.dba_hist_snapshot snap,
  gv$instance i
WHERE shared.dbid                  = snap.dbid
AND shared.snap_id                 = snap.snap_id
AND shared.instance_number         = snap.instance_number
and i.instance_number              = snap.instance_number
AND TRUNC(snap.end_interval_time) >= to_date('20151115','yyyymmdd')
AND TRUNC(snap.end_interval_time) <= to_date('20151215','yyyymmdd')
GROUP BY TO_CHAR(snap.end_interval_time, 'mon/yyyy'),
  i.instance_name,
  TRUNC(shared.shared_pool_size_factor,1)
ORDER BY i.instance_name,to_date(TO_CHAR(snap.end_interval_time, 'mon/yyyy'),'mon/yyyy'), trim(TO_CHAR(TRUNC(shared.shared_pool_size_factor,1),'999990.00'));

		