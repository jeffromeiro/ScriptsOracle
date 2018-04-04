set verify off
SELECT TO_CHAR(data,'mm-yyyy') month_year,
  SUM(ROUND(((increase          *8192)/1024/1024/1024),2)) total_incr_month,
  MAX(ROUND(((TABLESPACE_MAXSIZE*8192)/1024/1024/1024),2)) tbs_max_space_month,
  round((SUM(ROUND(((increase          *8192)/1024/1024/1024),2))*100)/(MAX(ROUND(((TABLESPACE_MAXSIZE*8192)/1024/1024/1024),2))),2)"%_INCR"
FROM
  (SELECT TRUNC(b.begin_interval_time) DATA,
    c.name,
    A.TABLESPACE_MAXSIZE,
    A.TABLESPACE_USEDSIZE - lag(A.TABLESPACE_USEDSIZE,1,0) over (PARTITION BY c.name ORDER BY b.begin_interval_time) increase
  FROM dba_hist_tbspc_space_usage a,
    dba_hist_snapshot b,
    v$tablespace c
  WHERE A.TABLESPACE_ID             = C.TS#
  AND c.name                        = '&TABLESPACE_NAME'
  AND a.snap_id                     = b.snap_id
  AND TRUNC(b.begin_interval_time) >= TRUNC(add_months(sysdate,-6))
  ORDER BY 1
  )
GROUP BY TO_CHAR(data,'mm-yyyy')
ORDER BY 1;
set verify on