accept snap_start number prompt 'Snap inicial: '
accept snap_fim   number prompt 'Snap final: '



WITH t1 AS 
( 
       SELECT s.snap_id, 
              To_char(s.end_interval_time,'dd/mm/yyyy hh24:mi') snap_time, 
              e.event_name                                      event, 
              Nvl(e.time_waited_micro,0)/1000000                time, 
              e.total_waits, 
              startup_time 
       FROM   dba_hist_snapshot s, 
              dba_hist_system_event e 
       WHERE  s.snap_id = e.snap_id 
       AND    s.instance_number = e.instance_number 
       AND    s.dbid = e.dbid 
       AND    e.wait_class NOT IN ('Idle') 
       AND    s.snap_id BETWEEN :snap_start AND    :snap_end 
       AND    (( 
                            s.instance_number= :inst_id) 
              OR     ( 
                            :inst_id = 0)) 
       UNION ALL 
                 selects.snap_id, 
                 to_char(s.end_interval_time,'dd/mm/yyyy hh24:mi') snap_time, 
                 'CPU' event, 
                 nvl(c.value,0)/1000000 time, 
                 0 total_waits, 
                 startup_time 
       FROM      dba_hist_snapshot s, 
                 dba_hist_sys_time_model c 
       WHERE     s.snap_id = c.snap_id 
       AND       s.instance_number = c.instance_number 
       AND       s.dbid = c.dbid 
       AND       c.stat_name = 'DB CPU' 
       AND       s.snap_id BETWEEN :snap_start AND       :snap_end 
       AND       (( 
                                     s.instance_number = :inst_id) 
                 OR        ( 
                                     :inst_id = 0)) 
       ORDER BY  snap_id), t2 AS 
( 
         SELECT   snap_id, 
                  snap_time, 
                  event, 
                  time                                                                                                                                                       time_s,
                  lag(                                                                                time,1) OVER (partition BY event ORDER BY snap_id)                     pre_time_s,
                  decode(startup_time,lag(startup_time,1) OVER (partition BY event ORDER BY snap_id), time - (lag(time,1) OVER (partition BY event ORDER BY snap_id)), time) delta_s,
                  startup_time 
         FROM     t1 
         ORDER BY snap_id, 
                  event), t3 AS 
( 
         SELECT   snap_id, 
                  snap_time, 
                  event, 
                  time_s, 
                  delta_s, 
                  startup_time, 
                  rank() OVER (partition BY snap_id ORDER BY delta_s DESC) rank 
         FROM     t2 
         ORDER BY snap_id ASC, 
                  delta_s DESC), t4 AS 
( 
         SELECT 
                  /*snap_id, */ 
                  snap_time, 
                  event, 
                  /*time_s,*/ 
                  CASE 
                           WHEN rownum <= :top_events THEN NULL 
                           ELSE 
                                    CASE 
                                             WHEN to_char(to_date(snap_time,'dd/mm/yyyy hh24:mi'),'hh24') IN ('00',
                                                                                                              '01',
                                                                                                              '02',
                                                                                                              '03',
                                                                                                              '04',
                                                                                                              '05',
                                                                                                              '06',
                                                                                                              '07',
                                                                                                              '08',
                                                                                                              '09',
                                                                                                              '10',
                                                                                                              '11',
                                                                                                              '12',
                                                                                                              '13',
                                                                                                              '14',
                                                                                                              '15',
                                                                                                              '16',
                                                                                                              '17',
                                                                                                              '18',
                                                                                                              '19',
                                                                                                              '20',
                                                                                                              '21',
                                                                                                              '22',
                                                                                                              '23')THEN delta_s
                                             ELSE 0 
                                    END 
                  END delta_s, 
                  /*rank,*/ 
                  decode(startup_time,lag(startup_time,1) OVER (ORDER BY snap_id),NULL,'X') startup
         FROM     t3where rank <= :top_events 
         ORDER BY snap_id ASC, 
                  rank ASC) 
SELECT   event, 
         sum(delta_s) delta_s 
FROM     t4 
GROUP BY event 
ORDER BY 2 DESC nulls last