

Análise de Performance de Instância

-Ultima meia-hora
   TOP 10 EVENTOS DE ESPERA POR INSTANCIA
   - query 1
   TOP 10 SQL_ID POR TEMPO DE ESPERA POR INSTANCIA 
   - query 2
   TOP 10 SQL_ID DADO UM EVENT POR INSTANCIA
   - query 3



-Com período definido   

Análise de Performance de Consulta



QUERY 1.

		REPHEADER LEFT COL 9 '***************************************************************' SKIP 1 -
					   COL 9 '* TOP 10 EVENTOS DE x NA ULTIMA MEIA HORA, POR INSTANCIA *' SKIP 1 -
					   COL 9 '***************************************************************' SKIP 2
		COL inst_id FOR 99
		COL event   FOR A60
		COL wait    HEAD "WAIT (s)" 
		COL dummy NOPRINT
		COMPUTE SUM OF wait ON dummy
		BREAK ON dummy SKIP PAGE

		SELECT inst_id dummy
		,      inst_id
		,      event
		,      wait 
		  FROM (
				SELECT inst_id
				,      NVL(event,'CPU') EVENT
				,      TRUNC(SUM(wait_time + time_waited)/1000000) WAIT
				,      RANK() OVER (PARTITION BY inst_id ORDER BY SUM(wait_time + time_waited) DESC) RANK
				  FROM gv$active_session_history
				 WHERE sample_time --BETWEEN to_date('04/03/2015 18:50:00','DD/MM/YYYY HH24:MI:SS') and to_date('04/03/2015 22:30:00','DD/MM/YYYY HH24:MI:SS')
				 BETWEEN SYSDATE - 60/2880 AND SYSDATE
				 GROUP BY inst_id, NVL(event,'CPU')
				 ORDER BY 1,3 DESC
			   )
		 WHERE rank < 11
		 ORDER BY 1,rank
		/

		REPHEADER OFF

QUERY 1.

REPHEADER LEFT COL 9 '***************************************************************' SKIP 1 -
               COL 9 '* TOP 10 EVENTOS DE ESPERA NA ULTIMA HORA, POR INSTANCIA *' SKIP 1 -
               COL 9 '***************************************************************' SKIP 2
COL inst_id FOR 99
COL event   FOR A60
COL wait    HEAD "WAIT (s)" 
COL dummy NOPRINT
COMPUTE SUM OF wait ON dummy
BREAK ON dummy SKIP PAGE

SELECT inst_id dummy
,      inst_id
,      event
,      wait 
  FROM (
        SELECT inst_id
        ,      NVL(event,'CPU') EVENT
        ,      TRUNC(SUM(wait_time + time_waited)/1000000) WAIT
        ,      RANK() OVER (PARTITION BY inst_id ORDER BY SUM(wait_time + time_waited) DESC) RANK
          FROM gv$active_session_history
         WHERE sample_time BETWEEN SYSDATE - 60/2880 AND SYSDATE
         GROUP BY inst_id, NVL(event,'CPU')
         ORDER BY 1,3 DESC
       )
 WHERE rank < 11
 ORDER BY 1,rank
/

REPHEADER OFF


REPHEADER LEFT COL 9 '***************************************************************' SKIP 1 -
               COL 9 '* TOP 10 EVENTOS DE ESPERA NAS ULTIMAS 2 HORAS, POR INSTANCIA *' SKIP 1 -
               COL 9 '***************************************************************' SKIP 2
COL inst_id FOR 99
COL event   FOR A60
COL wait    HEAD "WAIT (s)" 
COL dummy NOPRINT
COMPUTE SUM OF wait ON dummy
BREAK ON dummy SKIP PAGE

SELECT inst_id dummy
,      inst_id
,      event
,      wait 
  FROM (
        SELECT inst_id
        ,      NVL(event,'CPU') EVENT
        ,      TRUNC(SUM(wait_time + time_waited)/1000000) WAIT
        ,      RANK() OVER (PARTITION BY inst_id ORDER BY SUM(wait_time + time_waited) DESC) RANK
          FROM gv$active_session_history
         WHERE sample_time BETWEEN SYSDATE - 1/24 AND SYSDATE 
         GROUP BY inst_id, NVL(event,'CPU')
         ORDER BY 1,3 DESC
       )
 WHERE rank < 11
 ORDER BY 1,rank
/

REPHEADER OFF


QUERY 2.

REPHEADER LEFT COL 2 '************************************************************************' SKIP 1 -
               COL 2 '* TOP 10 SQL_ID POR TEMPO DE ESPERA NA ULTIMA MEIA HORA, POR INSTANCIA *' SKIP 1 -
               COL 2 '************************************************************************' SKIP 2
COL inst_id  FOR 99 HEAD 'INST'
COL program  FOR A30
COL module   FOR A30
COL username FOR A20
COL event    FOR A30
COL wait     HEAD "WAIT (s)" 
COL dummy NOPRINT
COMPUTE SUM OF wait ON dummy
BREAK ON dummy SKIP PAGE

SELECT inst_id dummy
,      inst_id
,      sql_id
,      module
,      program
,      username
,      NVL(event,'CPU') AS event
,      wait
  FROM (
         SELECT inst_id
         ,      sql_id
         ,      program
         ,      module
         ,      username
         ,      event
         ,      TRUNC(SUM(wait_time + time_waited)/1000000) AS wait
         ,      RANK() OVER (PARTITION BY inst_id ORDER BY SUM(wait_time + time_waited) DESC) RANK
           FROM gv$active_session_history ash
          ,     dba_users u
          WHERE sample_time --BETWEEN to_date('04/03/2015 18:50:00','DD/MM/YYYY HH24:MI:SS') and to_date('04/03/2015 22:30:00','DD/MM/YYYY HH24:MI:SS')
		  BETWEEN SYSDATE - 60/2880 AND SYSDATE
            AND ash.user_id = u.user_id
            AND u.username = 'SDBANCO'
          GROUP BY inst_id
          ,        sql_id
          ,        program
          ,        module
          ,        username
          ,        event
          ORDER BY 1,5 DESC
        )
 WHERE rank < 11
 ORDER BY 1,rank
/

REPHEADER OFF


QUERY 3.

REPHEADER LEFT COL 2 '******************************************************************' SKIP 1 -
               COL 2 '* TOP 10 SQL_ID DADO UM EVENT NA ULTIMA MEIA HORA, POR INSTANCIA *' SKIP 1 -
               COL 2 '******************************************************************' SKIP 2
COL inst_id  FOR 99
COL username FOR A15
COL module   FOR A45
COL event    FOR A50
COL wait     HEAD "WAIT (s)" 
COL dummy    NOPRINT
COMPUTE SUM OF wait ON dummy
BREAK ON dummy SKIP PAGE

SELECT inst_id dummy
,      inst_id
,      username
,      module
,      sql_id
,      event
,      count
  FROM (
	SELECT ash.inst_id
	,      users.username
	,      ash.module
	,      ash.sql_id
	,      ash.event
	,      COUNT(ash.event) count
	,      RANK() OVER (PARTITION BY inst_id ORDER BY COUNT(ash.event) DESC) rank
	  FROM gv$active_session_history ash
	,      dba_users users
	 WHERE ash.user_id = users.user_id
	   AND ash.sample_time /* ULTIMA MEIA-HORA */ --BETWEEN SYSDATE - 60/2880 AND SYSDATE
	   BETWEEN SYSDATE - 1/24/10 AND SYSDATE
	   --AND event = 'direct path read'
	   --AND event = 'read by other session'
	   --OR event = 'db file sequential read'
	   --OR event = 'db file scattered read'
	   --AND event = 'db file parallel read'
	   --AND event = 'library cache lock'
	   --AND event = 'enq: TX - row lock contention'
	   --AND event = 'PX Deq Credit: send blkd'
	   --AND event = 'latch: library cache'
	   --AND event = 'latch: cache buffers chains'
	   --AND event IS NULL
	   --AND event = 'enq: TM - contention'
	   --AND event = 'SQL*Net more data from dblink'
	   --OR event = 'log file sync'
	   --AND event = 'TCP Socket (KGAS)'
--	   AND event = 'CPU'
	   AND users.USERNAME='SDBANCO'
	 GROUP BY ash.inst_id
	,         users.username
	,         ash.module
	,         ash.sql_id
	,         ash.event
	 ORDER BY 1,6 DESC
        )
  WHERE rank < 11
  ORDER BY 1, rank
/

REPHEADER OFF


/**********************************************************/  
/* Eventos de espera, dado um SQL_ID, na ultima meia hora */
/**********************************************************/

SELECT inst_id, sql_id, event, COUNT(1) 
  FROM gv$active_session_history
 WHERE sql_id = '&sql_id' 
   AND sample_time /* ULTIMA MEIA-HORA */ BETWEEN SYSDATE - 10 AND SYSDATE
 GROUP BY inst_id
,         sql_id
,         event 
 ORDER BY 1, 4 DESC
 
 


7hzddw6azmr2w




TOP ACTIVE SQL

select sql_id, count(*), 
round(count(*)
/sum(count(*)) over (), 2) pctload
from v$active_session_history
where sample_time > sysdate - 30/24/60
and session_type <> 'BACKGROUND'
group by sql_id
order by count(*) ;


TOP IO SQL

select ash.sql_id, count(*) 
from v$active_session_history ash, 
v$event_name evt
where ash.sample_time > sysdate - 30/24/60
and ash.session_state = 'WAITING'
and ash.event_id = evt.event_id
and evt.wait_class = 'User I/O'
group by sql_id
order by count(*);





    AAA    WW       WW  RRRRR
   AA AA   WW   W   WW  RR  RR
  AA   AA   WW  W  WW   RR  RR 
  AAAAAAA   WW  W  WW   RRRR
  AA   AA    WWW WWW    RR RR
  AA   AA     W   W     RR  RR
 
 
 /************************************/
 /* Encontra snap_id para o dia dado */
 /************************************/
 
COL end_interval_time FOR A30 
 
SELECT snap_id
,      instance_number
,      end_interval_time 
  FROM dba_hist_snapshot 
 WHERE 1=1
   --AND TRUNC(end_interval_time) = TRUNC(SYSDATE)
   --AND TRUNC(end_interval_time) = TRUNC(SYSDATE)  - 1
   AND TRUNC(end_interval_time) = TO_DATE('24/10/2012','DD-MM-YYYY')
 ORDER BY 1, 2
 
 /*****************************************/
  /* Encontra snap_id para o período dado */
  /****************************************/
 
 
COL inst FOR 99999
COL min  FOR a50
COL max  FOR a50

SELECT 'Min Snap: ' || MIN(snap_id || ' - ' || end_interval_time) "MIN"
,      'Max Snap: ' || MAX(snap_id || ' - ' || end_interval_time) "MAX"
,      'Inst_id:' || instance_number INST
  FROM dba_hist_snapshot 
 WHERE 1=1
   AND TRUNC(end_interval_time) = TRUNC(SYSDATE)
   --AND TRUNC(end_interval_time) = TRUNC(SYSDATE)  - 1
   --AND TRUNC(end_interval_time) BETWEEN TO_DATE('24/04/2012','DD-MM-YYYY') AND TO_DATE('24/04/2012','DD-MM-YYYY')
GROUP BY instance_number
ORDER BY 1, 2
/
 
/**********************************************/
/* Encontra o snap_id contendo o select dado. */
/**********************************************/

COL end_interval_time FOR A25
COL startup_time      FOR A25

SELECT DISTINCT a.instance_number
--,      a.snap_id
,      b.sql_id
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
,      dba_hist_sqltext c
 WHERE a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND b.dbid            = c.dbid
   AND a.snap_id         = b.snap_id   
   AND b.sql_id          = c.sql_id
   --AND a.end_interval_time >= TRUNC(SYSDATE) - 30
   --AND TRUNC(a.end_interval_time) BETWEEN TO_DATE('01/05/2011','DD/MM/YYYY') AND TO_DATE('10/05/2011','DD/MM/YYYY')
   --AND a.snap_id in ('22434','22435')
   AND a.snap_id BETWEEN 65596 AND 65669
   AND UPPER(c.sql_text) LIKE UPPER('%@araras_prod%')
 ORDER BY 1,2


SELECT DISTINCT b.sql_id
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
,      dba_hist_sqltext c
 WHERE a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND a.snap_id         = b.snap_id
   AND b.dbid            = c.dbid
   AND b.sql_id          = c.sql_id
   AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE)
   AND c.sql_text LIKE '%REF_ACCT_CSA%'
  

/*********************************************/
/* Encontra o SNAP_ID contendo o SQL_ID dado */
/*********************************************/

COL end_interval_time FOR A25
COL startup_time        FOR A25
COL event               FOR A45

SELECT a.dbid
,      a.instance_number
,      a.startup_time
,      a.end_interval_time
,      a.snap_id
,      a.sql_id
,      b.plan_hash_value
,      b.rows_processed_delta "Rows"
,      b.executions_delta "Executions"
  FROM ( SELECT DISTINCT a.dbid
	 ,      a.instance_number
	 ,      a.startup_time
	 ,      a.end_interval_time
	 ,      a.snap_id
	 ,      b.sql_id
	   FROM dba_hist_snapshot a
	 ,      dba_hist_active_sess_history b
	  WHERE a.dbid            = b.dbid
	    AND a.instance_number = b.instance_number
	    AND a.snap_id         = b.snap_id
	    AND b.sql_id          = '&SQL_ID'
	    --AND a.end_interval_time >= TRUNC(SYSDATE) - 1 /* ONTEM */ 
	    AND a.end_interval_time   >= TRUNC(SYSDATE) /* HOJE */ 
	    --AND a.end_interval_time BETWEEN TO_DATE('01/11/2010','DD/MM/YYYY') AND TO_DATE('04/11/2010','DD/MM/YYYY')
	    --AND a.snap_id           IN ('22434','22435') 
	    --AND a.end_interval_time = TO_DATE('18/10/2010','DD/MM/YYYY')
       ) a
,      dba_hist_sqlstat b
 WHERE a.dbid            = b.dbid(+)
   AND a.instance_number = b.instance_number(+)
   AND a.snap_id         = b.snap_id(+) 
   AND a.sql_id          = b.sql_id
   --AND b.executions_delta > 0
 ORDER BY 1,2,3,5,6,7
 



/********************/
/* ANALISES POR SID */
/********************/

SELECT *
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN 44322 AND 44324
   AND session_id IN (9848,9721)




/***********************/
/* ANALISES POR SQL_ID */
/***********************/

/****************************************************************************************/ 
/* Encontra as execuções por SQL_ID, SNAP e PLAN_HASH_VALUE dado um end_interval_time */
/****************************************************************************************/

COL end_interval_time FOR A25
 
 SELECT --a.dbid,
        a.instance_number
--,       b.startup_time
,       b.end_interval_time
,       a.snap_id
,       a.sql_id
,       a.plan_hash_value
,       a.executions_delta "Executions"
   FROM dba_hist_sqlstat a
,       dba_hist_snapshot b
  WHERE a.dbid            = b.dbid
    AND a.instance_number = b.instance_number
    AND a.snap_id         = b.snap_id
    AND a.sql_id          = '&SQL_ID'
    --AND TRUNC(a.end_interval_time) >= TRUNC(SYSDATE) - 1 /* ONTEM */ 
    AND TRUNC(b.end_interval_time) = TRUNC(SYSDATE) /* HOJE */ 
    --AND TRUNC(b.end_interval_time) BETWEEN TO_DATE('26/03/2011','DD-MM-YYYY') AND TO_DATE('26/04/2011','DD-MM-YYYY')
    --AND a.snap_id in ('22434','22435') 
    --AND b.executions_delta > 0
 ORDER BY 1,2,3  
 
  
  
/*************************************************/
/* Agrupa as execuções de um dado SQL_ID por DIA */
/*************************************************/
 
 COL startup_time FOR A25
 
  SELECT a.instance_number AS "INST#"
 ,       TRUNC(b.end_interval_time) AS "DATE"
 ,       a.sql_id
 ,       SUM(a.executions_delta) "EXECUTIONS"
    FROM dba_hist_sqlstat a
 ,       dba_hist_snapshot b
   WHERE a.dbid            = b.dbid
     AND a.instance_number = b.instance_number
     AND a.snap_id         = b.snap_id
     --AND a.instance_number = 3
     AND a.sql_id          = '&SQL_ID'
     --AND TRUNC(b.end_interval_time) >= TRUNC(SYSDATE) - 1 /* ONTEM */ 
     AND b.end_interval_time >= TRUNC(SYSDATE) /* HOJE */ 
     --AND TRUNC(b.end_interval_time) BETWEEN TO_DATE('01/02/2011','DD-MM-YYYY') AND TO_DATE('03/03/2011','DD-MM-YYYY')
     --AND TRUNC(b.end_interval_time) >= TRUNC(TO_DATE('13/12/2010','DD-MM-YYYY'))
     --AND a.snap_id in ('22434','22435') 
 GROUP BY a.instance_number, TRUNC(b.end_interval_time), a.sql_id
 ORDER BY a.instance_number, TRUNC(b.end_interval_time), a.sql_id



/*******************************************************************/
/* Agrupa as execuções de um dado SQL_ID por DIA e PLAN_HASH_VALUE */
/*******************************************************************/
 
COL startup_time FOR A25
 
  SELECT a.instance_number AS "INST#"
 --,       b.startup_time
 ,       TRUNC(b.end_interval_time) AS "DATE"
 ,       a.sql_id
 ,       a.plan_hash_value
 ,       SUM(a.executions_delta) "EXECUTIONS"
    FROM dba_hist_sqlstat a
 ,       dba_hist_snapshot b
   WHERE a.dbid            = b.dbid
     AND a.instance_number = b.instance_number
     AND a.snap_id         = b.snap_id
     AND a.sql_id          = '&SQL_ID'
     --AND b.end_interval_time >= TRUNC(SYSDATE) - 1 /* ONTEM */ 
     --AND b.end_interval_time >= TRUNC(SYSDATE) - 7 /* SEMANA PASSADA */ 
     --AND b.end_interval_time >= TRUNC(SYSDATE) /* HOJE */ 
     --AND b.end_interval_time BETWEEN TO_DATE('28/03/2011','DD-MM-YYYY') AND TO_DATE('01/04/2011','DD-MM-YYYY')
     AND b.end_interval_time >= TRUNC(TO_DATE('20/12/2011','DD-MM-YYYY'))
     --AND a.snap_id in ('22434','22435') 
 GROUP BY a.instance_number, /*b.startup_time,*/ TRUNC(b.end_interval_time), a.sql_id, a.plan_hash_value
 ORDER BY a.instance_number, /*b.startup_time,*/ TRUNC(b.end_interval_time), a.sql_id, a.plan_hash_value
 
 
 
/*****************************************************************/
/* Encontra o SNAP_ID contendo o SQL_ID dado, agrupado por EVENT */
/*****************************************************************/

COL end_interval_time FOR A25
COL startup_time        FOR A25
COL event               FOR A45

SELECT DISTINCT a.instance_number
,      a.snap_id
,      a.end_interval_time
,      a.startup_time
,      b.sql_id
,      NVL(b.event,'ON CPU') event
,      COUNT(1) "#"
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
 WHERE --a.dbid            = b.dbid
   --AND a.instance_number = b.instance_number
   --AND 
   a.snap_id         = b.snap_id
   --AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE) - 100 /* ONTEM */ 
   --AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE)     /* HOJE */ 
   --AND a.snap_id in ('15016','15022')
   AND b.sql_id = '7hzddw6azmr2w'
 GROUP BY a.instance_number
,         a.snap_id
,         a.end_interval_time
,         a.startup_time
,         b.sql_id
,         NVL(b.event,'ON CPU')
 ORDER BY 3,1,4,5,7

7hzddw6azmr2w
/***********************************************************/
/* Encontra o snapshot e o plan_hash_value do sql_id dado. */
/***********************************************************/

COL end_interval_time FOR A25
COL startup_time        FOR A25
COL event               FOR A45

SELECT DISTINCT a.instance_number
,      a.snap_id
,      a.end_interval_time
,      a.startup_time
,      b.sql_id
,      b.sql_plan_hash_value
  FROM dba_hist_snapshot a
,      dba_hist_active_sess_history b
,      dba_hist_sqltext c
 WHERE a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   AND a.snap_id         = b.snap_id
   AND b.dbid            = c.dbid
   AND b.sql_id          = c.sql_id
   --AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE) - 1 /* ONTEM */ 
   AND a.end_interval_time >= TRUNC(SYSDATE) /* HOJE */
   --AND TRUNC(a.end_interval_time) = TO_DATE('01/04/2011','DD/MM/YYYY') 
   --AND TRUNC(a.end_interval_time) BETWEEN TO_DATE('10/10/2010','DD/MM/YYYY') AND TO_DATE('16/10/2010','DD/MM/YYYY')
   --AND a.snap_id in ('22434','22435')
   AND c.sql_id = '&SQL_ID'
 ORDER BY 1,4,5,3
 


/**************************************/
/* Encontra as binds dado um sql_id . */
/**************************************/

 SELECT sql_id, name, last_captured, value_string
   FROM dba_hist_sqlbind
  WHERE sql_id='1xwzjfbfhyu5q'
    AND last_captured IN (SELECT DISTINCT last_captured 
                            FROM dba_hist_sqlbind 
                           WHERE sql_id='1xwzjfbfhyu5q') 
  ORDER BY 1 ,3,position



/*************************************************/
/* Média de ELAPSED_TIME e BUFFER_GETS por dia, dado um SQL_ID */
/*************************************************/

SELECT  a.instance_number AS inst_id
,       b.sql_id
,       TO_CHAR(TRUNC(a.end_interval_time),'DD/MM/YYYY') AS "DAY"
,       ROUND(SUM(b.buffer_gets_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG BGS"
,       ROUND(SUM(b.elapsed_time_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG SECS"
,       TRUNC(SUM(b.executions_delta)) as "EXECS"
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   --AND TRUNC(a.end_interval_time) BETWEEN TO_DATE('01/06/2011','DD-MM-YYYY') AND TO_DATE('21/06/2011','DD-MM-YYYY')
   --AND TRUNC(a.end_interval_time) = TO_DATE('15/12/2010','DD/MM/YYYY') 
   --AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE)
 GROUP BY a.instance_number
,         b.sql_id
,         TRUNC(a.end_interval_time)
 ORDER BY TRUNC(a.end_interval_time)
/ 


PIU

/***************************************************************************/
/* Média de ET, BG, RP and EXEC, por dia e PLAN_HASH_VALUE, dado um SQL_ID */
/***************************************************************************/

COL day FOR a10

BREAK ON REPORT
COMPUTE AVG OF AVG_SECS ON REPORT
COMPUTE AVG OF AVG_BG   ON REPORT

SELECT a.instance_number AS inst_id
,       b.sql_id
,       TO_CHAR(TRUNC(a.end_interval_time),'DD/MM/YYYY') AS "DAY"
,       b.plan_hash_value
,       ROUND(SUM(b.elapsed_time_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as AVG_SECS
,       ROUND(SUM(b.buffer_gets_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))) as AVG_BG
,       ROUND(SUM(b.disk_reads_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))) as AVG_DR
,       ROUND(SUM(b.rows_processed_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))) as "AVG ROWS"
,       TRUNC(SUM(b.executions_delta)) as "EXECS"
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   --AND a.end_interval_time BETWEEN TO_DATE('01/10/2012','DD-MM-YYYY') AND TO_DATE('01/11/2012','DD-MM-YYYY')
   --AND a.end_interval_time = TO_DATE('15/12/2010','DD/MM/YYYY') 
   --AND a.end_interval_time > TRUNC(SYSDATE) /* TODAY */
   --AND a.end_interval_time > TRUNC(SYSDATE) - 1 /* YESTERDAY */
   --AND a.end_interval_time > TRUNC(SYSDATE) - 7 /* LAST WEEK */
   --AND a.end_interval_time > TRUNC(SYSDATE) - 30 /* LAST MOUNTH */
 GROUP BY a.instance_number
,         b.sql_id
,         TRUNC(a.end_interval_time)
,         b.plan_hash_value
 ORDER BY TRUNC(a.end_interval_time), 1
/

COMPUTE AVG OF "AVG TIME" ON sql_id
BREAK ON sql_id SKIP PAGE

SET TAB OFF
SELECT  a.instance_number AS inst_id
,       b.sql_id
,       TO_CHAR(TRUNC(a.end_interval_time),'DD/MM/YYYY') AS "DAY"
,       b.plan_hash_value
,       ROUND(SUM(b.elapsed_time_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG ELAPSED TIME"
,       ROUND(SUM(b.cpu_time_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG CPU TIME"
,       ROUND(SUM(b.iowait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG IOWAIT"
,       ROUND(SUM(b.clwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG CLWAIT"
,       ROUND(SUM(b.apwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG APWAIT"
,       ROUND(SUM(b.ccwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG CCWAIT"
,       ROUND(SUM(b.cpu_time_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))
+             SUM(b.iowait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))
+             SUM(b.clwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))
+             SUM(b.apwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))
+             SUM(b.ccwait_delta/1000000)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta)),3) as "AVG TIME"
--,       ROUND(SUM(b.buffer_gets_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))) as "AVG BG"
--,       ROUND(SUM(b.rows_processed_delta)/DECODE(SUM(b.executions_delta),0,1,SUM(b.executions_delta))) as "AVG ROWS"
,       TRUNC(SUM(b.executions_delta)) as "EXECS"
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   --AND a.end_interval_time BETWEEN TO_DATE('10/11/2012','DD-MM-YYYY') AND TO_DATE('11/11/2012','DD-MM-YYYY')
   AND a.end_interval_time > TRUNC(SYSDATE) - 1/* TODAY */
   --AND a.end_interval_time > TRUNC(SYSDATE) - 7 /* LAST WEEK */
   --AND a.end_interval_time > TRUNC(SYSDATE) - 30 /* LAST MOUNTH */
 GROUP BY a.
 instance_number
,         b.sql_id
,         TRUNC(a.end_interval_time)
,         b.plan_hash_value
 ORDER BY TRUNC(a.end_interval_time), 1
/

cpu_time_delta
iowait_delta
clwait_delta
apwait_delta
ccwait_delta

SET TAB OFF
SELECT inst_id
,      sql_id
,      child_number
,      ROUND(SUM(elapsed_time/1000000)/DECODE(SUM(executions),0,1,SUM(executions)),3) as "AVG SECS"
,      ROUND(SUM(buffer_gets)/DECODE(SUM(executions),0,1,SUM(executions))) as "AVG BG"
,      ROUND(SUM(rows_processed)/DECODE(SUM(executions),0,1,SUM(executions))) as "AVG ROWS"
,      TRUNC(SUM(executions)) as "EXECS"
  FROM gv$sql
 WHERE sql_id = '&SQL_ID'
 GROUP BY inst_id
,         sql_id
,         child_number
 ORDER BY 1, 2
/


 
/***************************************************************************/
/* Média de ET, BG, RP and EXEC, snap a snap, por PLAN_HASH_VALUE, dado um SQL_ID */
/***************************************************************************/

COL time FOR A25

BREAK ON REPORT
COMPUTE AVG OF executions ON REPORT
COMPUTE AVG OF "SEC/exec" ON REPORT

SELECT a.snap_id
,      a.instance_number AS inst_id
,      b.sql_id
,      b.plan_hash_value
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
,      b.executions_delta AS executions
--,      NVL(ROUND(b.elapsed_time_delta/1000000),0) AS seconds
,      ROUND(((b.elapsed_time_delta/1000000)/DECODE(b.executions_delta,0,1,b.executions_delta)),5) AS "SEC/exec"
,      ROUND(b.buffer_gets_delta/DECODE(b.executions_delta,0,1,b.executions_delta),0) "BG/exec"
,      ROUND(b.disk_reads_delta/DECODE(b.executions_delta,0,1,b.executions_delta),0) "DR/exec"
,      ROUND(b.rows_processed_delta/DECODE(b.executions_delta,0,1,b.executions_delta),0) "ROW/exec"
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   --AND a.begin_interval_time BETWEEN TO_DATE('09/05/2013','DD/MM/YYYY') AND TO_DATE('10/05/2013','DD/MM/YYYY')
   --AND a.end_interval_time > TRUNC(SYSDATE)-1
   --AND a.end_interval_time > TRUNC(SYSDATE-7) -- UMA SEMANA
   --AND a.end_interval_time > TRUNC(SYSDATE-30) -- UM MES
   --AND a.end_interval_time BETWEEN TRUNC(SYSDATE)-1 AND TRUNC(SYSDATE) -- ONTEM
   --AND b.executions_delta > 0
   --AND b.executions_delta > 1000000
   --AND plan_hash_value=3665524095
   ORDER BY 1,2,3,4 desc

UNDEF SQL_ID





COL time FOR A25

BREAK ON REPORT
COMPUTE AVG OF executions ON REPORT
COMPUTE AVG OF "SEC/exec" ON REPORT

SELECT b.sql_id
,      TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
,      SUM(b.executions_delta) AS executions
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   AND a.begin_interval_time BETWEEN TO_DATE('08/05/2013','DD/MM/YYYY') AND TO_DATE('09/05/2013','DD/MM/YYYY')
   --AND a.end_interval_time > TRUNC(SYSDATE)-1
   --AND a.end_interval_time > TRUNC(SYSDATE-7) -- UMA SEMANA
   --AND a.end_interval_time > TRUNC(SYSDATE-30) -- UM MES
   --AND a.end_interval_time BETWEEN TRUNC(SYSDATE)-1 AND TRUNC(SYSDATE) -- ONTEM
   --AND b.executions_delta > 0
   --AND b.executions_delta > 1000000
   --AND plan_hash_value=3665524095
   GROUP BY b.sql_id, TO_CHAR(a.end_interval_time,'DD/MM/YYYY HH24:MI')
   ORDER BY 1,2




/***********************************************************/
/* SID,SERIAL# EVENT BREAKDOWN para um determinado período */
/***********************************************************/

COL end_interval_time FOR a21
COL event             FOR a30

SELECT /* parallel (ash,8) */
--       snap.snap_id
--,      snap.end_interval_time
--,
NVL(ash.event,'CPU') as event
,      COUNT(1)
  FROM dba_hist_active_sess_history ash
,      dba_hist_snapshot snap
 WHERE 1 = 1
   AND snap.snap_id                    = ash.snap_id
   AND snap.dbid                       = ash.dbid
   AND snap.instance_number            = ash.instance_number
   AND ( session_id = '1076' AND session_serial# = '13378'
         OR
         session_id = '1011' AND session_serial# = '25658'
         OR
         session_id = '1528' AND session_serial# = '28334'
         OR
         session_id = '1125' AND session_serial# = '27291'
         OR
         session_id = '1402' AND session_serial# = '24352'
       )
   AND snap.snap_id >= 47184
   --AND ash.snap_id BETWEEN 19514 AND 19609
   --AND sample_time BETWEEN TO_DATE('18/04/2013 00:00:00','DD/MM/YYYY HH24:MI:SS') 
   --                    AND TO_DATE('20/04/2013 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND module LIKE 'CACSCrudServer%'
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY 
--snap.snap_id
--,         snap.end_interval_time
--,
ash.event
 ORDER BY 2 DESC



/******************************************************/
/* SQL_ID EVENT BREAKDOWN para um determinado período */
/******************************************************/

COL end_interval_time FOR a21
COL event             FOR a30

SELECT /* parallel (ash,8) */
--       snap.snap_id
--,      snap.end_interval_time
      NVL(ash.event,'CPU') as event
,      COUNT(1)
  FROM dba_hist_active_sess_history ash
,      dba_hist_snapshot snap
 WHERE 1 = 1
   AND snap.snap_id                    = ash.snap_id
   AND snap.dbid                       = ash.dbid
   AND snap.instance_number            = ash.instance_number
   AND sql_id = '&SQL_ID'
   --AND snap.snap_id >= 47184
   --AND ash.snap_id BETWEEN 19514 AND 19609
   AND sample_time BETWEEN TO_DATE('09/05/2013 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                       AND TO_DATE('10/05/2013 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND module LIKE 'CACSCrudServer%'
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY 
 --snap.snap_id
--,         snap.end_interval_time
         ash.event
 ORDER BY 2 DESC


/***********************************************************/
/* Top 10 SQL_ID dado um EVENT para um determinado período */
/***********************************************************/

SELECT *
  FROM (
         SELECT ash.user_id
         ,      ash.sql_id
         ,      event
         --,      session_id
         ,      COUNT(event)
           FROM dba_hist_snapshot snap
         ,      dba_hist_active_sess_history ash
          WHERE 1 = 1
            AND snap.snap_id                    = ash.snap_id
	    AND snap.dbid                       = ash.dbid
            AND snap.instance_number            = ash.instance_number
            --AND snap.end_interval_time >= TRUNC(SYSDATE) -7    /* HOJE */ 
            AND snap.snap_id >= 2988
            --AND ash.snap_id BETWEEN 13367 AND 13391
            --AND event = 'direct path read'
            --AND event = 'read by other session'
            AND event = 'db file sequential read'
            --AND event = 'log file sequential read'
            --AND event = 'log file sync'
            --AND event = 'global cache cr request'
            --AND event = 'enq: TM - contention'
            --AND event = 'enq: UL - contention'
            --AND event = 'enq: TX - row lock contention'
            --AND event LIKE 'enq%'
            --AND event = 'library cache lock'
            --AND event = 'cursor: pin S wait on X'
            --AND event = 'cursor: pin S'
            --AND event = 'os thread startup'
          GROUP BY ash.user_id
         ,         ash.sql_id
         ,         event
         --,         session_id
          ORDER BY 4 DESC,3 DESC
        )
  WHERE ROWNUM < 11
  
/**********************************************************************/
/* Top 10 SQL_ID dado um EVENT para um determinado período por MODULE */
/**********************************************************************/

SELECT *
  FROM (
         SELECT ash.user_id
         ,      ash.sql_id
         ,      module
         ,      event
         ,      program
         --,      client_id
         ,      count(event)
           FROM dba_hist_active_sess_history ash
          WHERE 1 = 1
            AND ash.snap_id BETWEEN 29064 AND 29087
            --AND event = 'direct path read'
            --AND event = 'read by other session'
            --AND event = 'db file sequential read'
            --AND event = 'log file sequential read'
            --AND event = 'log file sync'
            --AND event = 'PX Deq Credit: send blkd'
            AND event = 'latch: cache buffers chains'
            --AND module LIKE '%NULL%'
          GROUP BY ash.user_id
         ,         ash.sql_id
         ,         module
         ,         event
         ,         program
         --,         client_id
          ORDER BY 5 DESC
        )
  WHERE ROWNUM <= 10
 
/***********************************************************/
/* Top 10 MODULE dado um EVENT para um determinado período */
/***********************************************************/

SELECT *
  FROM (
         SELECT ash.user_id
         ,      ash.module
         ,      event
         ,      count(event)
           FROM dba_hist_active_sess_history ash
          WHERE 1 = 1
            --AND ash.snap_id BETWEEN 14845 AND 14851
            AND sample_time BETWEEN TO_DATE('01/03/2012 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                                AND TO_DATE('31/03/2012 00:00:00','DD/MM/YYYY HH24:MI:SS')
            AND module LIKE '%R'
            --AND event = 'direct path read'
            --AND event = 'read by other session'
            --AND event = 'db file sequential read'
            --AND event = 'log file sequential read'
            --AND event = 'log file sync'
          GROUP BY ash.user_id
         ,         ash.module
         ,         event
          ORDER BY 4 DESC
        )
  WHERE ROWNUM <= 10
  
/***********************************************************************/
/* Top 10 MODULE dado um EVENT para um determinado período SNAP a SNAP */
/***********************************************************************/

COL end_interval_time FOR A25

SELECT ranking.snap_id
,      snap.end_interval_time
,      ranking.module
,      ranking.event_count
,      ranking.module_rank
  FROM (
         SELECT snap_id
         ,      module
         ,      COUNT(event) event_count
         ,      DENSE_RANK() OVER (PARTITION BY snap_id ORDER BY COUNT(event) DESC) module_rank
           FROM dba_hist_active_sess_history ash
          WHERE 1 = 1
            AND ash.snap_id BETWEEN 14657 AND 14719
            --AND event = 'db file sequential read'
            AND event = 'cursor: pin S'
            --AND event = 'direct path read'
            --AND event = 'read by other session'
          GROUP BY snap_id
          ,        module
       ) ranking
       , dba_hist_snapshot snap
 WHERE snap.snap_id = ranking.snap_id
   AND ranking.module_rank <= 3
 ORDER BY ranking.snap_id, ranking.module_rank
/


Excel Plotter

SELECT SNAP_ID||';'||module||';'||event_count||';'||module_rank
  FROM (
         SELECT snap_id
         ,      module
         ,      COUNT(event) event_count
         ,      DENSE_RANK() OVER (PARTITION BY snap_id ORDER BY COUNT(event) DESC) module_rank
           FROM dba_hist_active_sess_history ash
          WHERE ash.snap_id BETWEEN 14681 AND 14704
            AND event = 'db file sequential read'
            --AND event = 'direct path read'
            --AND event = 'read by other session'
          GROUP BY snap_id, module
       )
 WHERE module_rank <= 3
 ORDER BY snap_id, module_rank
/


/**************************************************************/
/* SQL_IDs executions per MODULE and EVENT dado um SAMPLE_TIME*/
/**************************************************************/

SELECT /*+ parallel (ash,2) */
       ash.user_id
--,      ash.module
,      sql_id
,      event
,      COUNT(event)
  FROM dba_hist_active_sess_history ash
 WHERE 1 = 1
   AND sql_id = '&SQL_ID'
   --AND ash.snap_id BETWEEN 14845 AND 14851
   AND sample_time BETWEEN TO_DATE('26/03/2012 12:00:00','DD/MM/YYYY HH24:MI:SS') 
                       AND TO_DATE('27/03/2012 12:00:00','DD/MM/YYYY HH24:MI:SS')
   AND module = 'Fechamento.exe'
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY ash.user_id
,         ash.module
,         sql_id
,         event
 ORDER BY 4 DESC

/*************************************************/
/* SQL_IDs EVENT SNAP A SNAP dado um SAMPLE_TIME */
/*************************************************/

COL end_interval_time FOR a21
COL event               FOR a30

SELECT /*+ parallel (ash,8) */
       snap.snap_id
,      snap.end_interval_time
,      NVL(ash.event,'CPU') as event
,      COUNT(ash.event)
  FROM dba_hist_active_sess_history ash
,      dba_hist_snapshot snap
 WHERE 1 = 1
   AND snap.snap_id                    = ash.snap_id
   AND snap.dbid                       = ash.dbid
   AND snap.instance_number            = ash.instance_number
   AND sql_id = '&SQL_ID'
   AND ash.snap_id BETWEEN 19514 AND 19609
   --AND sample_time BETWEEN TO_DATE('19/08/2010 00:00:00','DD/MM/YYYY HH24:MI:SS') 
   --                    AND TO_DATE('20/08/2010 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND module LIKE 'CACSCrudServer%'
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY snap.snap_id
,         snap.end_interval_time
,         ash.event
 ORDER BY 2 DESC



/********************************/
/* EVENTS executions per MODULE */
/********************************/

SELECT /*+ parallel (ash,8) */
       ash.user_id
,      ash.module
,      event
,      COUNT(event)
  FROM dba_hist_active_sess_history ash
 WHERE 1 = 1
   --AND ash.snap_id BETWEEN 44322 AND 44324
   AND sample_time BETWEEN TO_DATE('01/03/2012 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                       AND TO_DATE('31/03/2012 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND module LIKE 'CACSCrudServer%'
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY ash.user_id
,         ash.module
,         event
 ORDER BY 4 DESC

/*********************************/
/* SQL_IDs executions per MODULE */
/*********************************/

SELECT /*+ parallel (ash,8) */
       ash.user_id
,      ash.module
,      sql_id
,      COUNT(event)
  FROM dba_hist_active_sess_history ash
 WHERE 1 = 1
   --AND ash.snap_id BETWEEN 14845 AND 14851
   AND sample_time BETWEEN TO_DATE('19/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                       AND TO_DATE('20/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND module LIKE 'EFSE.RecordsEngine@ipe (TNS V1-V3)'
   AND module IN ('EFSE.RecordsEngine@carijo (TNS V1-V3)','EFSE.RecordsEngine@ipe (TNS V1-V3)')
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   --AND event = 'db file sequential read'
   --AND event = 'log file sequential read'
   --AND event = 'log file sync'
 GROUP BY ash.user_id
,         ash.module
,         sql_id
 ORDER BY 4 DESC,1,2,3



COL module FOR a45
COL time FOR 99999,99 head "Time(s)"
COL time_exec FOR 99999,99 head "Time(s)/Exec"


SELECT /*  */
       sql.module
,      sql.sql_id
,      SUM(buffer_gets_delta) AS BG
,      SUM(disk_reads_delta) AS DR
,      SUM(elapsed_time_delta)/1000000 AS TIME
,      SUM(executions_delta) AS EXEC
,      ROUND(((SUM(elapsed_time_delta)/1000000)/SUM(executions_delta)),2) AS TIME_EXEC
  FROM dba_hist_sqlstat sql
,      dba_hist_snapshot snap
 WHERE 1 = 1
   --AND snap.snap_id BETWEEN 14845 AND 14851
   AND snap.end_interval_time BETWEEN TO_DATE('19/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                                    AND TO_DATE('20/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS')
   AND snap.snap_id = sql.snap_id
   --AND sql.module LIKE 'CACSCrudServer%'
   AND module IN ('EFSE.RecordsEngine@carijo (TNS V1-V3)','EFSE.RecordsEngine@ipe (TNS V1-V3)')
 GROUP BY sql.module
,         sql_id
 ORDER BY 7 DESC


/*********************************************/
/* SQL_IDs executions per MODULE SNAP a SNAP */
/*********************************************/

COL module FOR a45
--COL time FOR 99999,99 HEAD "Time(s)"
COL time_exec FOR 99999,99 HEAD "Time(s)/Exec"
COL end_interval_time FOR a17
COL instance_number FOR 99 HEAD "Inst"

SELECT /*  */
       sql.module
,      TO_CHAR(snap.end_interval_time,'DD/MM/YYYY HH24:MI:SS')
,      sql.instance_number
,      sql.sql_id
,      SUM(executions_delta) AS "Execs"
,      ROUND(SUM(buffer_gets_delta)/SUM(executions_delta)) AS "BG/Exec"
,      ROUND(SUM(disk_reads_delta)/SUM(executions_delta)) AS "DR/Exec"
,      ROUND(SUM(rows_processed_delta)/SUM(executions_delta)) AS "Rows/Exec"
--,      SUM(elapsed_time_delta)/1000000 AS TIME
,      ROUND(((SUM(elapsed_time_delta)/1000000)/SUM(executions_delta)),3) AS TIME_EXEC
  FROM dba_hist_sqlstat sql
,      dba_hist_snapshot snap
 WHERE 1 = 1
   AND snap.snap_id                    = sql.snap_id
   AND snap.dbid                       = sql.dbid
   AND snap.instance_number            = sql.instance_number
   --AND snap.snap_id BETWEEN 14845 AND 14851
   AND snap.end_interval_time BETWEEN TO_DATE('19/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                                    AND TO_DATE('21/07/2011 00:00:00','DD/MM/YYYY HH24:MI:SS')
   --AND sql.module LIKE 'CACSCrudServer%'
   AND module IN ('EFSE.RecordsEngine@carijo (TNS V1-V3)','EFSE.RecordsEngine@ipe (TNS V1-V3)')
   AND executions_delta > 0
 GROUP BY sql.module
,         snap.end_interval_time
,         sql.instance_number
,         sql.sql_id
 ORDER BY 2,1,4,3 DESC





/****************************************************************************************/
/* Retorna o número de parallel servers utilizados por um dado objeto e um dado sql_id. */
/****************************************************************************************/

COL c0 heading 'Begin|Interval|time' format a8
COL c1 heading 'Object|Name'          format a25
COL c2 heading 'px_servers_execs_total'          format 99,999,999
COL c3 heading 'px_servers_execs_delta'      format 99,999,999
 
SELECT TO_CHAR(s.end_interval_time,'mm-dd hh24')  c0
,      p.object_name               c1
,      SUM(t.px_servers_execs_total)     c2
,      SUM(t.px_servers_execs_delta) c3
  FROM dba_hist_sql_plan p
,      dba_hist_sqlstat  t
,      dba_hist_snapshot s
 WHERE p.sql_id = t.sql_id
   AND t.snap_id = s.snap_id
   AND p.object_name LIKE UPPER('%&OBJECT_NAME%')
   AND p.sql_id='&sql_id'
 GROUP BY TO_CHAR(s.end_interval_time,'mm-dd hh24')
,      p.object_name
 ORDER BY c0
,      c1
,      c2 DESC




LOGICAL_READS, PHYSICAL_READS, por dia, dado um segmento.
para tabelas particionadas, agrupa as particoes.

SET VERIFY OFF

COL time             FOR A16
COL owner            FOR A20
COL object_name      FOR A30
COL "Logical Reads"  FOR 999,999,999,999,999
COL "Physical Reads" FOR 999,999,999,999,999

SELECT --c.snap_id
      TO_CHAR(TRUNC(c.end_interval_time),'DD/MM/YYYY') AS time
--,      TO_CHAR(c.end_interval_time,'DD/MM/YYYY HH24:MI') AS time
--,      c.instance_number AS inst_id
,      a.owner
,      a.object_name
,      SUM(b.logical_reads_delta)               AS "Logical Reads"
,      SUM(b.physical_reads_delta)              AS "Physical Reads" 
--,      SUM(b.physical_reads_direct_delta)     AS "Direct Reads"
,      SUM(b.physical_writes_delta)             AS "Writes"
--,      SUM(b.physical_writes_direct_delta)    AS "Direct Writes"
,      TRUNC(SUM(b.space_used_delta)/1024/1024) AS "Space (MB)"
  FROM dba_objects a
,      dba_hist_seg_stat b
,      dba_hist_snapshot c
 WHERE a.object_name     = '&segment_name' --'SEGMENT_NAME'
   AND a.object_id       = b.obj#
   AND a.data_object_id  = b.dataobj#
   AND b.snap_id         = c.snap_id
   AND b.dbid            = c.dbid
   AND b.instance_number = c.instance_number
   --AND TRUNC(c.end_interval_time) = TRUNC(SYSDATE)
   --AND c.snap_id = 8608
 GROUP BY --c.snap_id
      TO_CHAR(TRUNC(c.end_interval_time),'DD/MM/YYYY')
--,         TO_CHAR(c.end_interval_time,'DD/MM/YYYY HH24:MI')
--,         c.instance_number
,         a.owner
,         a.object_name
 ORDER BY TO_DATE(TO_CHAR(TRUNC(c.end_interval_time),'DD/MM/YYYY'),'DD/MM/YYYY')
   


select distinct sql_id
  from gv$sql
 where sql_text like 'SELECT /*+ LEADING(p, st, cl)%'

select distinct sql_id
  from dba_hist_sqltext
 where sql_text like 'SELECT /*+ LEADING(p, st, cl)%'

Execucoes por sql_id por dia.

SELECT TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY') AS time
--,      a.instance_number
,      a.sql_id
,      SUM(a.executions_delta)               AS "Executions"
,      SUM(a.rows_processed_delta)           AS "Rows"
,      SUM(a.elapsed_time_delta/1000000)/SUM(a.executions_delta) AS "AVG Time"
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   --AND TRUNC(b.end_interval_time) = TRUNC(SYSDATE)
   AND TRUNC(b.end_interval_time) BETWEEN TO_DATE('01/04/2011','DD/MM/YYYY') AND TO_DATE('01/05/2011','DD/MM/YYYY')
   AND a.sql_id          = '&sql_id'
 GROUP BY TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY')
--,         a.instance_number
,         a.sql_id
--HAVING SUM(a.executions_delta) > 0
 ORDER BY TO_DATE(TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY'),'DD/MM/YYYY'),3



Execucoes por sql_id por dia, snap a snap.

SELECT a.instance_number
,      b.snap_id
,      TO_CHAR(b.end_interval_time,'DD/MM/YYYY HH24:MI:SS') AS time
,      a.sql_id
,      a.executions_delta               AS "Executions"
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   --AND TRUNC(b.end_interval_time) = TRUNC(SYSDATE)
   AND TRUNC(b.end_interval_time) BETWEEN TO_DATE('01/04/2011','DD/MM/YYYY') AND TO_DATE('14/04/2011','DD/MM/YYYY')
   AND a.sql_id          = '&sql_id'
 ORDER BY 1,2,4




Top Ten Buffer Gets per Executions Today


SELECT * FROM
(
SELECT b.snap_id,
       TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY') AS datee
,      a.sql_id
,      SUM(a.executions_delta)                           AS "Executions"
,      TRUNC(SUM(a.buffer_gets_delta))                          AS "Buffer Gets"
,      TRUNC(SUM(a.disk_reads_delta))                           AS "Disk Reads"
,      TRUNC(SUM(a.disk_reads_delta)/SUM(a.executions_delta))   AS "Disk Reads per Exec"
,      TRUNC(SUM(a.buffer_gets_delta)/SUM(a.executions_delta))  AS "Buffer Gets per Exec"
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.snap_id         = b.snap_id
   AND a.dbid            = b.dbid
   AND a.instance_number = b.instance_number
   --AND TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY') = TO_CHAR(TRUNC(SYSDATE),'DD/MM/YYYY')
   AND TO_DATE(TRUNC(b.end_interval_time),'DD/MM/YYYY') = TO_DATE('01/02/2010','DD/MM/YYYY')
 GROUP BY b.snap_id
,      TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY')
,         a.sql_id
HAVING SUM(a.executions_delta) > 0
 ORDER BY TO_DATE(TO_CHAR(TRUNC(b.end_interval_time),'DD/MM/YYYY'),'DD/MM/YYYY'),7 DESC
)
 WHERE rownum < 11



Dado um segmento, tempo medio de resposta dos datafiles por dia.









 select active_session_history.user_id,
         dba_users.username,
          sqlarea.sql_id,
          sum(active_session_history.wait_time +
              active_session_history.time_waited) ttl_wait_time
     from DBA_HIST_ACTIVE_SESS_HISTORY active_session_history,
          DBA_HIST_SQLTEXT sqlarea,
          dba_users
    where active_session_history.sql_id = sqlarea.sql_id
      and active_session_history.user_id = dba_users.user_id
      AND active_session_history.snap_id between 11005 and 11008
   group by active_session_history.user_id,sqlarea.sql_id, dba_users.username
  order by 4


 select count(1), event
   from DBA_HIST_ACTIVE_SESS_HISTORY
  where snap_id between 8607 and 8632
    and sql_id = '&1'
  group by event
  order by 1
  
  
  
 select count(1), event, SUM(wait_time), SUM(time_waited)
   from DBA_HIST_ACTIVE_SESS_HISTORY
  where snap_id between 10669 and 10672
    and sql_id = '1juf7ztcrsddv'
  group by event
  order by 1
    




What object is currently causing the highest resource waits?


COL object_name FOR a30

select dba_objects.object_name,
         dba_objects.object_type,
         active_session_history.event,
         sum(active_session_history.wait_time +
             active_session_history.time_waited) ttl_wait_time
    from v$active_session_history active_session_history,
         dba_objects
   where active_session_history.sample_time between sysdate - 60/2880 and sysdate
     and active_session_history.current_obj# = dba_objects.object_id
  group by dba_objects.object_name, dba_objects.object_type, active_session_history.event
  order by 4











select dba_objects.object_name,
         dba_objects.object_type,
         active_session_history.event,
         sum(active_session_history.wait_time +
             active_session_history.time_waited) ttl_wait_time
    from DBA_HIST_ACTIVE_SESS_HISTORY active_session_history,
         dba_objects
   where snap_id between 10669 and 10672
     and active_session_history.current_obj# = dba_objects.object_id
     and object_name = 'SVC_AGRMNT_LINE_ITEM'
  group by dba_objects.object_name, dba_objects.object_type, active_session_history.event
  order by 4
 






SELECT ash.sql_id
,      event
,      count(event)
  FROM dba_hist_active_sess_history ash,
       v$sqlarea sqlarea,
       dba_users
 WHERE 1 = 1
   --AND ash.sample_time /* ULTIMA MEIA-HORA */ BETWEEN sysdate - 60/2880 AND sysdate
   AND ash.sql_id = sqlarea.sql_id
   AND ash.user_id = dba_users.user_id
   --AND event = 'direct path read'
   --AND event = 'read by other session'
   AND event = 'db file sequential read'
   AND snap_id IN (14553,14554)
 GROUP BY ash.user_id
,         dba_users.username
--,         sqlarea.sql_text
,         ash.sql_id
,         event
 ORDER BY 3





/***********************************************/
/* */
/***********************************************/

SELECT sql_id
,      module
--,      action
,      executions
,      px_servers_executions
,      parse_calls
,      disk_reads/DECODE(NVL(executions,1),0,1,NVL(executions,1)) "DR/Exe"
,      buffer_gets/DECODE(NVL(executions,1),0,1,NVL(executions,1)) "BG/Exe"
,      cpu_time/DECODE(NVL(executions,1),0,1,NVL(executions,1)) "CPU/Exe"
,      elapsed_time/DECODE(NVL(executions,1),0,1,NVL(executions,1)) "ET/Exe"
,      last_active_time
  FROM v$sql
 WHERE sql_id = '&sql_id'
/




SELECT  SUM(b.executions_delta)
  FROM dba_hist_snapshot a
,      dba_hist_sqlstat b
 WHERE a.snap_id = b.snap_id
   AND a.dbid = b.dbid
   AND a.instance_number = b.instance_number
   AND b.sql_id = '&SQL_ID'
   AND TRUNC(a.end_interval_time) = TRUNC(SYSDATE)
 ORDER BY TRUNC(a.end_interval_time)
/






SELECT inst_id
,      sql_id
,      module
--,      action
,      plan_hash_value
,      executions
  FROM gv$sql
 WHERE sql_id = '0dw3uzd5wqvu6' 
 ORDER BY 1
/

--'&sql_id'






SELECT a.module 
,      ROUND(SUM(a.cpu_time_delta)/1000000) "CPU_TIME(s)"
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.dbid           = b.dbid
   AND a.snap_id        = b.snap_id
   AND a.cpu_time_delta > 0
   AND a.module LIKE '%R'
   AND b.end_interval_time BETWEEN TO_DATE('01/04/2012 00:00','DD/MM/YYYY HH24:MI') 
                               AND TO_DATE('12/04/2012 00:00','DD/MM/YYYY HH24:MI') 
 GROUP BY module
 ORDER BY 2
 


COL module FOR a15

SELECT a.module 
,      ROUND(SUM(a.buffer_gets_delta)/SUM(executions_delta)) "BUFFER GETS/EXEC"
,      ROUND((SUM(a.cpu_time_delta)/SUM(executions_delta))/1000000) "CPU_TIME/EXEC(s)"
,      ROUND(SUM(a.elapsed_time_delta)/1000000) "ELAPSED_TIME/EXEC(s)"
,      SUM(executions_delta) EXECS
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.dbid           = b.dbid
   AND a.snap_id        = b.snap_id
   AND a.cpu_time_delta     > 0
   AND a.executions_delta   > 0
   AND a.elapsed_time_delta > 0
   AND a.module LIKE '%R'
   AND a.module NOT IN ('DBMS_SCHEDULER')
   AND b.end_interval_time BETWEEN TO_DATE('01/04/2012 00:00','DD/MM/YYYY HH24:MI') 
                               AND TO_DATE('12/04/2012 00:00','DD/MM/YYYY HH24:MI') 
 GROUP BY module
 ORDER BY 2
 
 
 
 
MODULE_BG_BREAKDOWN

COL teste FOR 990d00
BREAK ON module SKIP PAGE

SELECT module
,      sql_id
--,      RANK() OVER (PARTITION BY module ORDER BY SUM(buffer_gets_delta)/SUM(executions_delta) DESC) RANK
,      RANK() OVER (PARTITION BY module ORDER BY SUM(buffer_gets_delta) DESC) RANK
--,      ROUND(RATIO_TO_REPORT (SUM(buffer_gets_delta)) OVER (PARTITION BY module) * 100,2) TESTE
,      SUM(buffer_gets_delta) BG
,      ROUND(SUM(buffer_gets_delta)/SUM(executions_delta)) "BG/EXEC"
,      SUM(executions_delta) EXECS
  FROM dba_hist_sqlstat a
,      dba_hist_snapshot b
 WHERE a.dbid           = b.dbid
   AND a.snap_id        = b.snap_id
   AND a.executions_delta   > 0
   AND a.module LIKE '%ccf%'
   --AND a.module NOT IN ('DBMS_SCHEDULER')
   AND b.end_interval_time BETWEEN TO_DATE('01/02/2016 00:00','DD/MM/YYYY HH24:MI') 
                               AND TO_DATE('06/02/2016 00:00','DD/MM/YYYY HH24:MI') 
 GROUP BY module, sql_id
 ORDER BY 1,3