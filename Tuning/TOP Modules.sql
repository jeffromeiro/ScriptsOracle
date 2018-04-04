SET VERIFY OFF
SET FEEDBACK OFF
SET TIMI OFF

COL module FOR a15
COL rank HEAD "RANK MODULE" FOR 999
COL percentage HEAD "% Top" FOR 990d00
COL percentage2 HEAD "% Total" FOR 990d00
COL interval_per_execution HEAD "Interval per Exec" FOR a16
COL interval_total FOR a16
COL interval_instance FOR a16
COMPUTE SUM OF percentage ON report
COMPUTE SUM OF percentage2 ON report
BREAK ON report SKIP PAGE

ACCEPT pBegin PROMPT "Type begin date (ddmmyyyy): "

ACCEPT pEnd   PROMPT "Type end date (ddmmyyyy) [NULL]: "

ACCEPT pLike  PROMPT "Module like: "


REPHEADER LEFT COL 2 '********************************************************' SKIP 1 -
               COL 2 '* ' _date ' TOP MODULES PER INTERVAL *' SKIP 1 -
               COL 2 '********************************************************' SKIP 2

SELECT module
,      rank
,      ROUND(RATIO_TO_REPORT (time_partial) OVER (PARTITION BY time_total) * 100,2) percentage
,      ROUND(((time_partial*100)/time_total),2) percentage2
,      interval_total
,      interval_instance
,      executions
  FROM (
SELECT cd_programa AS module
,      RANK() OVER (ORDER BY CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) DESC NULLS LAST) RANK
,      SUM(dh_fim_proces-dh_inicio_proces) AS time_partial
,      COUNT(1) AS executions
,      CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) as INTERVAL_TOTAL
  FROM dw.tbdwr_log_programa lps
 WHERE lps.dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
   AND cd_programa LIKE ('%&&pLike%')
 GROUP BY cd_programa
),
(
SELECT CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) AS INTERVAL_INSTANCE
,      SUM(dh_fim_proces-dh_inicio_proces) AS time_total
  FROM dw.tbdwr_log_programa lps
 WHERE lps.dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
)
 GROUP BY module, rank, interval_total, interval_instance, time_partial, time_total, executions
 HAVING rank < 11
 ORDER BY 2
/

REPHEADER LEFT COL 2 '********************************************************************' SKIP 1 -
               COL 2 '* ' _date ' TOP MODULES PER (INTERVAL/EXECUTION) *' SKIP 1 -
               COL 2 '********************************************************************' SKIP 2

SELECT module
,      rank
,      ROUND(RATIO_TO_REPORT (time_partial) OVER (PARTITION BY time_total) * 100,2) percentage
,      ROUND(((time_partial*100)/time_total),2) percentage2
--,      time_per_execution
,      interval_per_execution
,      interval_total
,      interval_instance
,      executions
  FROM (
SELECT cd_programa AS module
,      RANK() OVER (ORDER BY CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces)/COUNT(1),'day') AS INTERVAL DAY(1) TO SECOND(0)) DESC NULLS LAST) RANK
,      SUM(dh_fim_proces-dh_inicio_proces) AS time_partial
--,      SUM(lps_dat_fim-lps_dat_ini)/COUNT(1) AS time_per_execution      
,      COUNT(1) AS executions
,      CAST(NUMTODSINTERVAL((SUM(dh_fim_proces-dh_inicio_proces)/COUNT(1)),'day') AS INTERVAL DAY(1) TO SECOND(0)) as INTERVAL_PER_EXECUTION
,      CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) as INTERVAL_TOTAL
  FROM dw.tbdwr_log_programa lps
 WHERE dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
   AND cd_programa LIKE ('%&&pLike%')
 GROUP BY cd_programa
),
(
SELECT CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) AS INTERVAL_INSTANCE
,      SUM(dh_fim_proces-dh_inicio_proces) AS time_total
  FROM dw.tbdwr_log_programa lps
 WHERE dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
)
 GROUP BY module, rank, interval_per_execution, interval_total, interval_instance, time_partial, time_total, executions
 HAVING rank < 11
 ORDER BY 2
/


REPHEADER LEFT COL 2 '*********************************************************' SKIP 1 -
               COL 2 '* ' _date ' TOP MODULES PER EXECUTION *' SKIP 1 -
               COL 2 '*********************************************************' SKIP 2

SELECT module
,      rank
,      ROUND(RATIO_TO_REPORT (executions) OVER (PARTITION BY executions_instance) * 100,2) percentage
,      ROUND(((executions*100)/executions_instance),2) percentage2
,      interval_per_execution
,      interval_total
,      executions
,      executions_instance
  FROM (
SELECT cd_programa AS module
,      RANK() OVER (ORDER BY COUNT(1) DESC NULLS LAST) RANK
,      SUM(dh_fim_proces-dh_inicio_proces) AS time_partial    
,      COUNT(1) AS executions
,      CAST(NUMTODSINTERVAL((SUM(dh_fim_proces-dh_inicio_proces)/COUNT(1)),'day') AS INTERVAL DAY(1) TO SECOND(0)) as INTERVAL_PER_EXECUTION
,      CAST(NUMTODSINTERVAL(SUM(dh_fim_proces-dh_inicio_proces),'day') AS INTERVAL DAY(1) TO SECOND(0)) as INTERVAL_TOTAL
  FROM dw.tbdwr_log_programa lps
 WHERE lps.dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
   AND cd_programa LIKE ('%&&pLike%')
 GROUP BY cd_programa
),
(
SELECT COUNT(1) AS executions_instance
  FROM dw.tbdwr_log_programa lps
 WHERE lps.dh_inicio_proces BETWEEN TO_DATE('&&pBegin','DDMMYYYY') 
                           AND NVL(TRUNC(TO_DATE('&&pEnd','DDMMYYYY'))+1,SYSDATE)
)
 GROUP BY module, rank, interval_per_execution, interval_total, executions, executions_instance
 HAVING rank < 11
 ORDER BY 2
/