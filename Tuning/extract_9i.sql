----------------------------------------------------------------------------------------------------------
                                        -- HIT RATIO TIMELINE
----------------------------------------------------------------------------------------------------------
WITH t1 AS
  (SELECT i.instance_name, a.snap_id,
    TO_CHAR(b.snap_time,'DD/MM/YYYY HH24:MI') snap_time,
    a.name stat_name ,
    a.value
  FROM PERFSTAT.stats$sysstat a,
    PERFSTAT.stats$snapshot b,
    gv$instance i
  WHERE a.dbid           = b.dbid
  AND a.instance_number  = b.instance_number
  AND a.snap_id          = b.snap_id
  AND b.instance_number  = i.instance_number
  AND a.instance_number  = i.instance_number
  AND b.instance_number = 1
  AND TRUNC(b.snap_time) >= to_date('20160801','yyyymmdd')
  AND TRUNC(b.snap_time) <= to_date('20160816','yyyymmdd')
  AND name IN ('db block gets','consistent gets','physical reads')
  ),
  t2 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    stat_name,
    value
  FROM t1
  WHERE stat_name = 'db block gets'
  ),
  t3 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    stat_name,
    value
  FROM t1
  WHERE stat_name = 'consistent gets'
  ),
  t4 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    stat_name,
    value
  FROM t1
  WHERE stat_name = 'physical reads'
  ),
  t5 AS
  (SELECT t2.instance_name,
    t2.snap_id,
    t2.snap_time,
    t2.value db_block_gets,
    t3.value consistent_gets,
    t4.value physical_reads
  FROM t2,
    t3,
    t4 WHERE t2.snap_id = t3.snap_id
  AND t3.snap_id = t4.snap_id
  ) ,
  t6 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    db_block_gets,
    consistent_gets,
    physical_reads,
    LAG(db_block_gets,1 ,0) OVER (ORDER BY snap_id) db_block_gets_prev,
    LAG(consistent_gets,1,0) OVER (ORDER BY snap_id) consistent_gets_prev ,
    LAG(physical_reads,1,0) OVER (ORDER BY snap_id) physical_reads_prev
  FROM t5
  ),
  t61 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    db_block_gets,
    consistent_gets,
    physical_reads,
    CASE
      WHEN (db_block_gets < db_block_gets_prev)
      THEN db_block_gets
      ELSE db_block_gets - db_block_gets_prev
    END db_block_gets_delta,
    CASE
      WHEN (consistent_gets < consistent_gets_prev)
      THEN consistent_gets
      ELSE consistent_gets - consistent_gets_prev
    END consistent_gets_delta,
    CASE
      WHEN (physical_reads < physical_reads_prev)
      THEN physical_reads
      ELSE physical_reads - physical_reads_prev
    END physical_reads_delta FROM t6
  ),
  t7 AS
  (SELECT ROWNUM rn,
    t61.*,
    ROUND((db_block_gets_delta + consistent_gets_delta - physical_reads_delta) / DECODE((db_block_gets_delta + consistent_gets_delta ),0,1,(db_block_gets_delta + consistent_gets_delta)) * 100,2) value
  FROM t61
  ORDER BY TO_DATE(snap_time,'DD/MM/YYYY HH24:MI')
  )
SELECT instance_name,TO_DATE(snap_time,'DD/MM/YYYY HH24:MI') snap_time,
  value
FROM t7
WHERE rn > 1
and value > 0
UNION ALL
SELECT 'Threshold' instance_name,TO_DATE(snap_time,'DD/MM/YYYY HH24:MI') snap_time,
  90 value
FROM t7
WHERE rn > 1
and value > 0
ORDER BY 2;

----------------------------------------------------------------------------------------------------------
                                        -- SHARED POOL
----------------------------------------------------------------------------------------------------------
with
  t1 as (select a.snap_id, b.snap_time snap_time,
                a.instance_number, a.name, a.value
           from stats$sysstat a, stats$snapshot b
          where a.dbid = b.dbid
            and a.instance_number = b.instance_number
            and a.snap_id = b.snap_id
            and b.snap_time >= to_date('20160801','yyyymmdd')
            and b.snap_time <= to_date('20160816','yyyymmdd')
            and name in ('parse count (total)','parse count (hard)','session cursor cache hits')),
  t2 as (select snap_id, snap_time, instance_number, name, value from t1 where name = 'parse count (total)'),
  t3 as (select snap_id, snap_time, instance_number, name, value from t1 where name = 'parse count (hard)'),
  t4 as (select snap_id, snap_time, instance_number, name, value from t1 where name = 'session cursor cache hits'),
  t5 as (select t2.snap_id, t2.snap_time, t2.instance_number, t2.value total_parses, t3.value hard_parses, t4.value session_cursor_cache_hit
           from t2, t3, t4
          where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id
            and t2.instance_number = t3.instance_number and t3.instance_number = t4.instance_number),
  t6 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           lag(total_parses,1,0) over (PARTITION BY instance_number order by snap_id) total_parses_prev,
           lag(hard_parses,1,0) over (PARTITION BY instance_number order by snap_id) hard_parses_prev,
           lag(session_cursor_cache_hit,1,0) over (PARTITION BY instance_number order by snap_id) sess_cur_cache_hit_prev
         from t5),
  t7 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           case when (total_parses < total_parses_prev) then total_parses else total_parses - total_parses_prev end total_parses_delta,
           case when (hard_parses < hard_parses_prev) then hard_parses else hard_parses - hard_parses_prev end hard_parses_delta,
           case when (session_cursor_cache_hit < sess_cur_cache_hit_prev) then session_cursor_cache_hit else session_cursor_cache_hit - sess_cur_cache_hit_prev end session_cursor_cache_hit_delta
         from t6),
  t8 as (select rownum rn, t7.*,
           round(session_cursor_cache_hit_delta / total_parses_delta * 100,2) perc_cursor_cache_hits,
           round(((total_parses_delta - session_cursor_cache_hit_delta - hard_parses_delta) / total_parses_delta) * 100,2) perc_soft_parses,
           round(hard_parses_delta / total_parses_delta * 100,2) perc_hard_parses
         from t7 order by snap_time, instance_number)
select 'PARSE_DATE;INSTANCE;AVG_CACHE;AVG_SOFT;AVG_HARD' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,'mi'),'dd/mm/yyyy hh24:mi')||';'||i.instance_name||';'||
       replace(trim(to_char(avg(perc_cursor_cache_hits),'990.00')),'.',',')||';'||
       replace(trim(to_char(avg(perc_soft_parses),'990.00')),'.',',')||';'||
       replace(trim(to_char(avg(perc_hard_parses),'990.00')),'.',',')
from t8 join gv$instance i on t8.instance_number=i.instance_number
where rn > 1 and not (perc_cursor_cache_hits < 0 or perc_soft_parses < 0 or perc_hard_parses < 0)
group by trunc(snap_time,'mi'), instance_name
order by trunc(snap_time,'mi'), instance_name);



----------------------------------------------------------------------------------------------------------
                                        -- PGA AGGREGATE TARGET
----------------------------------------------------------------------------------------------------------

variable unit varchar2(10)
exec :unit := 'BLOCKS'

variable convert varchar2(10)
exec :convert := 'MB'


WITH t_raw AS
  (SELECT d.instance_name,
    b.snap_time,
    a.name,
    CASE
      WHEN :unit = '#'
      THEN a.value
      WHEN :unit   = 'BLOCKS'
      AND :convert = 'X'
      THEN a.value
      WHEN :unit   = 'BLOCKS'
      AND :convert = 'MB'
      THEN ROUND((a.value * c.value) / 1024 / 1024)
      WHEN :unit   ='BLOCKS'
      AND :convert = 'GB'
      THEN ROUND((a.value * c.value) / 1024 / 1024 / 1024)
      WHEN :unit   = 'BLOCKS'
      AND :convert = 'TB'
      THEN ROUND((a.value * c.value) / 1024 / 1024 / 1024 /1024)
      WHEN :unit   = 'BYTES'
      AND :convert = 'X'
      THEN a.value
      WHEN :unit   = 'BYTES'
      AND :convert = 'MB'
      THEN ROUND(a.value / 1024 / 1024)
      WHEN :unit   = 'BYTES'
      AND :convert = 'GB'
      THEN ROUND(a.value / 1024 / 1024 / 1024)
      WHEN :unit   = 'BYTES'
      AND :convert = 'TB'
      THEN ROUND(a.value / 1024 / 1024 / 1024 / 1024)
      WHEN :unit   = 'TIME'
      AND :convert = 'X'
      THEN a.value
      WHEN :unit   = 'TIME'
      AND :convert = 'S'
      THEN ROUND(a.value / 1000000)
      WHEN :unit   = 'TIME'
      AND :convert = 'M'
      THEN ROUND(a.value / 1000000 / 60)
      WHEN :unit   = 'TIME'
      AND :convert = 'H'
      THEN ROUND(a.value / 1000000 / 60 / 60)
      WHEN :unit = '%'
      THEN a.value
      ELSE a.value
    END value,
    DECODE(b.startup_time,LAG(b.startup_time) OVER (PARTITION BY b.instance_number ORDER BY b.snap_id),NULL,'X') restart
  FROM stats$pgastat a,
    stats$snapshot b,
    gv$parameter c,
    Gv$instance d
  WHERE a.instance_number = 1
  AND TRUNC(b.snap_time) >= to_date('20160801','yyyymmdd')
  AND TRUNC(b.snap_time) <= to_date('20160816','yyyymmdd')
  AND a.name            = 'total PGA allocated'
  AND a.instance_number = b.instance_number
  AND a.snap_id         = b.snap_id
  AND a.dbid            = b.dbid
  AND a.instance_number = c.inst_id
  AND d.instance_number   = a.instance_number
  AND d.instance_number = b.instance_number
  AND d.instance_number = c.inst_id
  AND c.name            = 'db_block_size'
  ORDER BY a.snap_id
  )
SELECT snap_time,
  instance_name,
  value pga_allocated_mb,
  400 pga_aggregate_target
FROM
  (SELECT
    instance_name,
    TO_CHAR(snap_time,'DD/MM/YYYY HH24:MI') snap_time,
    name,
    value,
    DECODE(restart,'X',value,value -LAG(value,1) OVER (ORDER BY snap_time)) delta,
    restart FROM t_raw
  )
ORDER BY TO_DATE(snap_time,'DD/MM/YYYY HH24:MI');



----------------------------------------------------------------------------------------------------------
                                          -- WAIT EVENTS
----------------------------------------------------------------------------------------------------------

WITH t1 AS
  (SELECT i.instance_name, s.snap_id,
    TO_CHAR(s.snap_time,'dd/mm/yyyy hh24:mi') snap_time,
    e.event,
    NVL(e.time_waited_micro,0)/1000000 TIME,
    e.total_waits,
    s.startup_time
  FROM stats$snapshot s,
    stats$system_event e,
    gv$instance i
  WHERE s.snap_id       = e.snap_id
  AND s.instance_number = e.instance_number
  AND s.dbid            = e.dbid
  AND i.instance_number = s.instance_number
  AND e.instance_number = i.instance_number
  AND e.event NOT in    (SELECT event FROM stats$idle_event   )
  AND TRUNC(s.snap_time) >= to_date('20160801','yyyymmdd')
  AND TRUNC(s.snap_time) <= to_date('20160816','yyyymmdd')
  UNION ALL
  SELECT i.instance_name, s.snap_id,
    TO_CHAR(s.snap_time,'dd/mm/yyyy hh24:mi') snap_time,
    'CPU' event,
    NVL(c.value,0)/100 TIME,
    0 total_waits,
    s.startup_time
  FROM stats$snapshot s,
    stats$sysstat c,
    gv$instance i
  WHERE s.snap_id       = c.snap_id
  AND s.instance_number = c.instance_number
  AND s.dbid            = c.dbid
  AND i.instance_number = c.instance_number
  AND i.instance_number = s.instance_number
  AND c.name            = 'CPU used by this session'
  AND TRUNC(s.snap_time) >= to_date('20160801','yyyymmdd')
  AND TRUNC(s.snap_time) <= to_date('20160816','yyyymmdd')
  ORDER BY snap_id
  ),
  t2 AS
  (SELECT instance_name,
    snap_id,
    snap_time,
    event,
    time time_s,
    lag(TIME,1) over (partition BY instance_name,event order by snap_id) pre_time_s,
    DECODE(startup_time,lag(startup_time,1) over (partition BY instance_name,event order by snap_id), TIME - (lag(TIME,1) over (partition BY instance_name,event order by snap_id)), TIME) delta_s,
    startup_time
  FROM t1
  ORDER BY snap_id,
    event
  ),
  t3 AS
  (SELECT instance_name,snap_id,
    snap_time,
    event,
    time_s,
    delta_s,
    startup_time,
    rank() over (partition BY instance_name,snap_id order by delta_s DESC) rank
  FROM t2
  ORDER BY snap_id ASC,
    delta_s DESC
  )
SELECT
  /*snap_id, */
  instance_name,
  snap_time,
  event,
  /*time_s,*/
  CASE
    WHEN rownum <= :top_events
    THEN NULL
    ELSE
      CASE
        WHEN TO_CHAR(to_date(snap_time,'dd/mm/yyyy hh24:mi'),'hh24') IN ('00', '01', '02', '03', '04', '05', '06', '07''08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23')
        THEN delta_s
        ELSE 0
      END
  END delta_s
  /*rank,*/
FROM t3
WHERE rank <= :top_events
ORDER BY to_date(snap_time,'dd/mm/yyyy hh24:mi') ASC,
  rank ASC;

----------------------------------------------------------------------------------------------------------
                           -- DRILL DOWN QUERIES P90 DE METRICA NA LINHA DO TEMPO
----------------------------------------------------------------------------------------------------------


select
  to_char(trunc(snap_time, 'dd'), 'dd/mm/yyyy hh24:mi:ss') snap_time,
  instance_number, hash_value, module,
  percentile_disc(0.9) within group (order by buffer_gets_delta asc) buffer_gets,
  percentile_disc(0.9) within group (order by disk_reads_delta asc) disk_reads,
  percentile_disc(0.9) within group (order by cpu_time_delta asc) cpu_time,
  percentile_disc(0.9) within group (order by elapsed_time_delta asc) elapsed_time,
  percentile_disc(0.9) within group (order by parse_calls_delta asc) parse_calls,
  percentile_disc(0.9) within group (order by executions_delta asc) executions,
  percentile_disc(0.9) within group (order by rows_processed_delta asc) rows_processed
from (
  select snap.snap_time,
         summ.instance_number,
         summ.hash_value,
         summ.module,
         greatest(summ.buffer_gets    - lag(summ.buffer_gets,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) buffer_gets_delta,
         greatest(summ.disk_reads     - lag(summ.disk_reads,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) disk_reads_delta,
         greatest(summ.cpu_time       - lag(summ.cpu_time,1)       over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) cpu_time_delta,
         greatest(summ.elapsed_time   - lag(summ.elapsed_time,1)   over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) elapsed_time_delta,
         greatest(summ.parse_calls    - lag(summ.parse_calls,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) parse_calls_delta,
         greatest(summ.executions     - lag(summ.executions,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) executions_delta,
         greatest(summ.rows_processed - lag(summ.rows_processed,1) over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) rows_processed_delta
    from stats$sql_summary summ, stats$snapshot snap
   where snap.snap_time >= to_date('01/08/2016', 'dd/mm/yyyy')
     and snap.snap_time < to_date('16/08/2016', 'dd/mm/yyyy')
     and snap.snap_id = summ.snap_id
     and snap.dbid = summ.dbid
     and snap.instance_number = summ.instance_number
)
group by trunc(snap_time, 'dd'), instance_number, hash_value, module;


----------------------------------------------------------------------------------------------------------
                           -- TOP QUERIES BY METRIC
----------------------------------------------------------------------------------------------------------
select * from (
select
      ratio_to_report(buffer_gets)  over ()*100 buffer_gets_ratio,
      ratio_to_report(disk_reads)   over ()*100 disk_reads_ratio,
      ratio_to_report(cpu_time)     over ()*100 cpu_time_ratio,
      ratio_to_report(elapsed_time) over ()*100 elapsed_time_ratio,
      ratio_to_report(parses)       over ()*100 parses_ratio,
      ratio_to_report(execs)        over ()*100 execs_ratio,
      t.* from (
select
       i.instance_name
      ,st.HASH_VALUE
      ,round(Sum(e.BUFFER_GETS) / Sum(e.executions),2) BUFFER_GETS
      ,round(sum(e.DISK_READS) / Sum(e.executions),2) disk_reads
      ,round(sum(e.cpu_time) / Sum(e.executions),2) cpu_time
      ,round(sum(e.elapsed_time) / Sum(e.executions),2) elapsed_time
      ,round(sum(e.rows_processed)/ Sum(e.executions),2) rows_processed
      ,sum(e.parse_calls) parses
      ,sum(e.executions) execs
      ,substr(trim(st.sql_text),1,64) sql_text
  from stats$sql_summary e,
       stats$snapshot b,
       stats$sqltext st,
       gv$instance i
 where b.snap_time     >= to_date('20160801','yyyymmdd')
   and b.snap_time     <= to_date('20160816','yyyymmdd')
   AND e.instance_number = b.instance_number
   AND e.snap_id         = b.snap_id
   AND e.dbid            = b.dbid
   and e.hash_value         = st.hash_value
   and e.text_subset        = st.text_subset
   AND i.instance_number    = b.instance_number
   AND i.instance_number    = e.instance_number
   and st.command_type <> 47
   AND e.executions > 0
   and st.piece = 0    -- garante apenas uma linha da sqltext por hash
   GROUP BY i.instance_name, st.hash_value,substr(trim(st.sql_text),1,64)
  ) t
  order by
      buffer_gets_ratio desc,
      disk_reads_ratio desc,
      cpu_time_ratio desc,
      elapsed_time_ratio desc,
      parses_ratio desc,
      execs_ratio desc
) where (buffer_gets_ratio >5 OR disk_reads_ratio > 5 OR cpu_time_ratio > 5 OR elapsed_time_ratio > 5 OR parses_ratio >5);


---------------------------------------------------------------------------------------------------------
                                   -- DATAFILE P90 READ TIME
---------------------------------------------------------------------------------------------------------

SELECT to_date(DATA) as data,
  NVL (MAX (DECODE (INSTANCE_NUMBER,1, read_time_ms)), NULL) BSCS62P1,
  MAX(20) THRESHOLD
  FROM
    (SELECT to_char(snap_date,'dd/mm/yyyy hh24:mi') as data,
      instance_number,
      PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY TRUNC((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10,2) ASC) read_time_ms
    FROM
      (SELECT s.snap_time snap_date,
        s.instance_number,
        f.filename,
        f.readtim,
        lag(f.readtim,1) over (partition BY s.instance_number, f.filename order by to_date(s.snap_time,'dd/mm/yyyy hh24:mi')) readtim_lag,
        f.phyrds,
        lag(f.phyrds,1) over (partition BY s.instance_number, f.filename order by to_date(s.snap_time,'dd/mm/yyyy hh24:mi')) phyrds_lag
      FROM stats$filestatxs f,
        stats$snapshot s
      WHERE f.snap_id            = s.snap_id
      AND f.instance_number      = s.instance_number
      and trunc(s.snap_time) >= to_date('20160801','yyyymmdd')
      and trunc(s.snap_time) <= to_date('20160816','yyyymmdd')
      )
    WHERE readtim_lag        IS NOT NULL
    AND phyrds_lag           IS NOT NULL
    AND (phyrds - phyrds_lag) > 0
    GROUP BY to_char(snap_date,'dd/mm/yyyy hh24:mi'),
      instance_number,
      filename
    )
  GROUP BY to_date(DATA)
  ORDER BY DATA;

---------------------------------------------------------------------------------------------------------
                                   -- DATAFILES DRILL DOWN TOP 10
---------------------------------------------------------------------------------------------------------
 with
  t0 as (
    select s.instance_number, s.snap_id, s.snap_time snap_time, t.contents, f.filename, startup_time,
           decode(startup_time,lag(startup_time,1) over (partition by s.instance_number, f.filename order by s.snap_time),
           f.readtim - lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.snap_time), f.readtim) delta_readtim,
           decode(startup_time,lag(startup_time,1) over (partition by s.instance_number, f.filename order by s.snap_time),
           f.phyrds - lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.snap_time), f.phyrds) delta_phyrds
      from stats$filestatxs f, stats$snapshot s, DBA_TABLESPACES t
     where f.snap_id = s.snap_id
       and f.instance_number = s.instance_number
       and f.dbid = s.dbid
       and f.TSNAME = t.tablespace_name
       and s.snap_time >= to_date('20160801','yyyymmdd')
       and s.snap_time <= to_date('20160816','yyyymmdd')),
  t1 as (
    select instance_number, snap_id, snap_time, contents, filename,
           delta_readtim / delta_phyrds * 10 avg_read_time_ms
      from t0
     where delta_phyrds > 0),
  t2 as (
  select instance_number, snap_id, snap_time, contents, filename, avg_read_time_ms,
         rank() over (partition by instance_number, snap_id, contents order by avg_read_time_ms desc) rank
    from t1),
  t3 as (
    select instance_number, snap_time, contents, filename, avg_read_time_ms from t2 where rank <= 10)
select 'DATAFILE_DATE;INSTANCE;TYPE;FILENAME;MIN_MS;AVG_MS;P90_MS;P95_MS;P99_MS;MAX_MS;THRESHOLD' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,'mi'),'dd/mm/yyyy hh24:mi')||';'||instance_number||';'||contents||';'||replace(filename,'+','')||';'||
       replace(trim(to_char(min(avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(avg(avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(max(avg_read_time_ms),'999999999990.00')),'.',',')||';'||
       replace(trim(to_char(20,'990.00')),'.',',')
from t3
     group by trunc(snap_time,'mi'), instance_number, contents, filename
     order by trunc(snap_time,'mi'), instance_number, contents, filename);

---------------------------------------------------------------------------------------------------------
                                   -- RATIO THRESHOLD REDO LOG SWICTH
---------------------------------------------------------------------------------------------------------
WITH t1 AS
  (SELECT a.first_time date_time,
    ROUND((a.first_time - LAG(a.first_time,1) OVER (PARTITION BY a.thread# ORDER BY a.sequence#))*24*60) interval_min
  FROM v$loghist a, gv$instance i
  WHERE a.thread# = i.instance_number
  AND a.first_time BETWEEN TO_DATE('01/10/2014','DD/MM/YYYY') AND TO_DATE('15/10/2014','DD/MM/YYYY')+1
  ORDER BY a.sequence#
  ),
  t2 AS
  ( SELECT CASE WHEN interval_min <= 5 THEN 1 ELSE 0 END x FROM t1
  )
SELECT 'Switches below minimum recommended: '
  || ROUND(
  (SELECT COUNT(*) FROM t2 WHERE x=1
  ) /
  (SELECT COUNT(*) FROM t2
  )*100)
  || '%' perc
FROM dual;

---------------------------------------------------------------------------------------------------------
                                   -- REDO LOG FILE SWITCH TIME LINE
---------------------------------------------------------------------------------------------------------
SELECT a.first_time date_time,
    ROUND((a.first_time - LAG(a.first_time,1) OVER (PARTITION BY a.thread# ORDER BY a.sequence#))*24*60) interval_min
  FROM v$loghist a, gv$instance i
  WHERE a.thread# = i.instance_number
  AND a.first_time BETWEEN TO_DATE('01/10/2014','DD/MM/YYYY') AND TO_DATE('15/10/2014','DD/MM/YYYY')+1
  ORDER BY a.sequence#;

----------------------------------------------------------------------------------------------------------
                                          -- SGA DRILL DOWN
----------------------------------------------------------------------------------------------------------

select to_char(snap.snap_time,'dd/mm/yyyy hh24:mi:ss')DATA
,instance_name
,nvl2(sgas.pool,sgas.pool, sgas.name)POOL,
round(sum(case when sgas.name like '%free memory%' then 0 else sgas.bytes end)/1024/1024) UTILIZADO_MB,
round(sum(case when sgas.name like '%free memory%' then sgas.bytes else 0 end)/1024/1024) LIVRE_MB
from stats$sgastat sgas, stats$snapshot snap, gv$instance i
where sgas.snap_id = snap.snap_id
AND   sgas.instance_number = i.instance_number
and  snap.instance_number = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
group by snap.snap_time,instance_name,nvl2(sgas.pool,sgas.pool, sgas.name);

----------------------------------------------------------------------------------------------------------
                                          -- PGA ADVISOR
----------------------------------------------------------------------------------------------------------
spool pga.log

select 'mes;instancia;tamanho;fator;minimo_overallocation;maximo_overallocation' pga_extract from dual;
SELECT TO_CHAR(snap.snap_time, 'mon/yyyy')
  ||';'
  ||i.instance_name
  ||';'
  ||trim(TO_CHAR(TRUNC(MAX(pga.pga_target_for_estimate)/1024/1024,2),'999990.00'))
  ||';'
  || trim(TO_CHAR(pga.pga_target_factor,'999990.00'))
  ||';'
  ||MIN(pga.estd_overalloc_count)
  ||';'
  ||MAX(pga.estd_overalloc_count)
FROM stats$pga_target_advice pga,
  stats$snapshot snap,
  gv$instance i
WHERE pga.dbid             = snap.dbid
AND pga.snap_id            = snap.snap_id
AND pga.instance_number    = snap.instance_number
AND pga.instance_number    = i.instance_number
and snap.instance_number   = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
GROUP BY TO_CHAR(snap.snap_time, 'mon/yyyy'),
  i.instance_name,
  pga.pga_target_factor;

spool off;

SELECT TO_CHAR(snap.snap_time, 'mon/yyyy') data,
  i.instance_name,
  TRUNC(MAX(pga.pga_target_for_estimate)/1024/1024,2) SIZE_FOR_ESTIMATE,
  pga.pga_target_factor,
  MIN(pga.estd_overalloc_count) MIN_OVER_ALLOC,
  MAX(pga.estd_overalloc_count) MAX_OVER_ALLOC
FROM stats$pga_target_advice pga,
  stats$snapshot snap,
  gv$instance i
WHERE pga.dbid             = snap.dbid
AND pga.snap_id            = snap.snap_id
AND pga.instance_number    = snap.instance_number
AND pga.instance_number    = i.instance_number
and snap.instance_number   = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
GROUP BY TO_CHAR(snap.snap_time, 'mon/yyyy'),
  i.instance_name,
  pga.pga_target_factor
  ORDER BY to_date(data,'mm/yyyy'),4;

----------------------------------------------------------------------------------------------------------
                                          -- DB CACHE
----------------------------------------------------------------------------------------------------------
spool db_cache.log

select 'mes;instancia;tamanho;fator;minimo_leituras_fisicas;maximo_leituras_fisicas' sga_extract from dual;
SELECT TO_CHAR(snap.snap_time, 'mon/yyyy') data,
  i.instance_name,
  name buffer_pool,
  TRUNC(MAX(db.size_for_estimate)) size_for_estimate,
  TRUNC(db.size_factor,1)size_factor,
  MIN(db.estd_physical_reads) min_physical_reads,
  MAX(db.estd_physical_reads) max_physical_reads
FROM stats$db_cache_advice db,
  stats$snapshot snap,
  gv$instance i
WHERE db.dbid              = snap.dbid
AND db.snap_id             = snap.snap_id
AND db.instance_number     = snap.instance_number
and db.instance_number     = i.instance_number
and snap.instance_number     = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
GROUP BY TO_CHAR(snap.snap_time, 'mon/yyyy'),
  i.instance_name,
  name,
  TRUNC(db.size_factor,1)
  order by to_date(data,'mm/yyyy'),3,5;
----------------------------------------------------------------------------------------------------------
                                          -- SHARED POOL
----------------------------------------------------------------------------------------------------------
spool shared_pool.log

select 'mes;instancia;tamanho;fator;minimo_memory_object_hits;maximo_memory_object_hits' sga_extract from dual;
SELECT TO_CHAR(snap.snap_time, 'mon/yyyy')
  ||';'
  ||i.instance_name
  ||';'
  ||MAX(shared.shared_pool_size_for_estimate)
  ||';'
  || trim(TO_CHAR(TRUNC(shared.shared_pool_size_factor,1),'999990.00'))
  ||';'
  ||MIN(shared.estd_lc_memory_object_hits)
  ||';'
  ||MAX(shared.estd_lc_memory_object_hits)
FROM stats$shared_pool_advice shared,
  stats$snapshot snap,
  gv$instance i
WHERE shared.dbid          = snap.dbid
AND shared.snap_id         = snap.snap_id
AND shared.instance_number = snap.instance_number
and shared.instance_number = i.instance_number
and snap.instance_number   = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
GROUP BY TO_CHAR(snap.snap_time, 'mon/yyyy'),
  i.instance_name,
  TRUNC(shared.shared_pool_size_factor,1);

spool off;

SELECT TO_CHAR(snap.snap_time, 'mon/yyyy') data,
  i.instance_name,
  MAX(shared.shared_pool_size_for_estimate) size_for_estimate,
  trim(TO_CHAR(TRUNC(shared.shared_pool_size_factor,1),'999990.00')) size_factor,
  MIN(shared.estd_lc_memory_object_hits) min_object_hits,
  MAX(shared.estd_lc_memory_object_hits)max_object_hits
FROM stats$shared_pool_advice shared,
  stats$snapshot snap,
  gv$instance i
WHERE shared.dbid          = snap.dbid
AND shared.snap_id         = snap.snap_id
AND shared.instance_number = snap.instance_number
and shared.instance_number = i.instance_number
and snap.instance_number   = i.instance_number
AND TRUNC(snap.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(snap.snap_time) <= to_date('20160816','yyyymmdd')
GROUP BY TO_CHAR(snap.snap_time, 'mon/yyyy'),
  i.instance_name,
  TRUNC(shared.shared_pool_size_factor,1)
  order by to_date(data,'mm/yyyy'),4;


----------------------------------------------------------------------------------------------------------
                                          -- SORT AREA SIZE
----------------------------------------------------------------------------------------------------------

select snap_time,
memory - lag(memory,1,0) over (order by snap_time) AS memory,
disk - lag(disk,1,0) over (order by disk) AS memory
from (
SELECT SNAP_TIME,
  instance_number,
  NVL(MAX(DECODE(NAME,'sorts (memory)',VALUE)),NULL) MEMORY,
  NVL(MAX(DECODE(NAME,'sorts (disk)',VALUE)),NULL) DISK
FROM (SELECT a.instance_number,
  SNAP_TIME,
  A.NAME,
  a.value
FROM stats$sysstat a,
  stats$snapshot b
WHERE a.dbid                    = b.dbid
AND a.instance_number           = b.instance_number
AND a.snap_id                   = b.snap_id
AND TRUNC(snap_time) >= to_date('20150215','yyyymmdd')
AND TRUNC(snap_time) <= to_date('20150316','yyyymmdd')
AND name                  IN ('sorts (memory)','sorts (disk)')
)
GROUP BY SNAP_TIME
)
ORDER BY SNAP_TIME;

----------------------------------------------------------------------------------------------------------
                                          -- LOG_BUFFER
----------------------------------------------------------------------------------------------------------

SELECT TRUNC(snap.snap_time,'mi') data,
  ROUND((t.value- s.value)/t.value,5) "Hit Ratio",
  ROUND(s.value /t.value,5) "Full Times Ratio" ,
  t.value chamadas_total,
  s.value log_buffer_full_times
FROM stats$sysstat s,
  stats$sysstat t ,
  stats$snapshot snap
WHERE s.snap_id                    =t.snap_id
AND snap.snap_id                   =s.snap_id
AND snap.snap_id                   =t.snap_id
AND snap.dbid = T.Dbid
and T.Dbid =S.Dbid
AND s.instance_number              =t.instance_number
AND s.name                    = 'redo log space requests'
AND TRUNC(SNAP.snap_time) >= to_date('20160801','yyyymmdd')
AND TRUNC(SNAP.snap_time) <= to_date('20160816','yyyymmdd')
AND t.name= 'redo entries'
order by 1;