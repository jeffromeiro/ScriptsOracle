-- sess time model

WITH
 db_time AS (SELECT sid, value
 FROM v$sess_time_model
 WHERE sid = &SID
 AND stat_name = 'DB time')
 SELECT stm.stat_name AS statistic,
 ROUND(trunc(stm.value/1000000,3),2) AS seconds,
 trunc(stm.value/tot.value*100,1) AS "%"
 FROM v$sess_time_model stm, db_time tot
 WHERE stm.sid = tot.sid
 AND stm.stat_name <> 'DB time'
 AND stm.value > 0
 ORDER BY stm.value DESC;
 
 UNDEF SID