set lines 120
set pages 9999
col EVENT_NAME for a70

accept snap_inicial number prompt 'Snapshot ID inicial: '
accept snap_final   number prompt '  Snapshot ID final: '

SELECT EVENT_NAME,
       DELTA_SECS,
       trunc(100 * ratio_to_report(DELTA_SECS) over(partition by TOTAL), 2) as "Ratio"
  FROM (select 'Total' AS "TOTAL",
               event_name,
               TRUNC(sum(DELTA_EVENT) / 1000000, 2) "DELTA_SECS"
          FROM (select ev.snap_id,
                       EV.event_name,
                       ev.time_waited_micro -
                       (lag(ev.time_waited_micro)
                        over(partition by null order by ev.snap_id)) as "DELTA_EVENT"
                  from dba_hist_system_event ev, dba_hist_snapshot sn
                 where ev.snap_id = sn.snap_id
                   and ev.wait_class <> 'Idle'
		           and sn.INSTANCE_NUMBER = &instance_id
                   /*and to_CHAR(sn.end_interval_time, 'DD/MM/YYYY HH24:MI') between
                       '08/03/2012 00:00' AND '09/03/2012 23:00:00'*/
				   and sn.snap_id between &snap_inicial and &snap_final					   
				)
         GROUP BY EVENT_NAME
         having TRUNC(sum(DELTA_EVENT) / 1000000, 2) > 0)
 order by 3 desc;

undef snap_inicial snap_final