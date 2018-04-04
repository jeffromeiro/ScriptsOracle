--------------------------------------------------------------------------------
-- File name:   10g_snaps.sql
-- Purpose:     Get the minimum and maximum snapshots ids for a given interval
-- Author:      Thiago Maciel
-- Usage:       Run @10g_snaps and provide the start and end date for the interval.
--              The format for the date is 'dd/mm/yyyy hh24:mi'
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
column begin_interval_time format A25
column end_interval_time format A25

--PROMPT The format for the dates is "dd/mm/rr hh24:mi"

define data_inicial="&1"
define data_final="&2"

select s.snap_id, s.begin_interval_time, s.end_interval_time
from dba_hist_snapshot s
where s.snap_id in
 ( select min(snap_id)
   from dba_hist_snapshot
   where begin_interval_time >= to_date('&data_inicial','dd/mm/yyyy hh24:mi')
   UNION ALL
   select max(snap_id)
   from dba_hist_snapshot
   where end_interval_time   <= to_date('&data_final'  ,'dd/mm/yyyy hh24:mi')
  )
order by s.snap_id
/

undefine data_inicial
undefine data_final
