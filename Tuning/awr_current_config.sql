--SPOOL awr_current_config.log
Set lines 300 pages 50
Col name for a30
Col value for a20

select l.dbid,extract(day from retention) Retention_in_days, ( (extract(hour from l.snap_interval)* 60 * 60 ) + (extract(minute from l.snap_interval)* 60 ) + (extract(second from l.snap_interval)))/ 60 interval_in_mins from dba_hist_wr_control l;