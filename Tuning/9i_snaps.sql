--------------------------------------------------------------------------------
-- File name:   9i_snaps.sql
-- Purpose:     Get the minimum and maximum snapshots ids for a given interval
-- Author:      Thiago Maciel
-- Usage:       Run @9i_snaps and provide the start and end date for the interval.
--              The format for the date is 'dd/mm/yyyy hh24:mi'
--------------------------------------------------------------------------------
SET lines 170
SET pages 10000
set trimspool on
set verify off
set heading on
column begin_snap_id format A35
column end_snap_id format A35

PROMPT The format for the dates is "dd/mm/rr hh24:mi"

select min(s.snap_id || ' (' || to_char(s.snap_time,'dd/mm/rr HH24:MI') || ')' ) begin_snap_id, 
       max(s.snap_id || ' (' || to_char(s.snap_time,'dd/mm/rr HH24:MI') || ')' ) end_snap_id
  from stats$snapshot s
 where s.snap_time between to_date('&data_inicial','dd/mm/rr hh24:mi') and to_date('&data_final','dd/mm/rr hh24:mi')
/