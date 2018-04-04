select trunc(sample_time,'hh24') +
(trunc(to_char(sample_time,'mi')/15)*15)/24/60, count(*)/30/3
     from dba_hist_active_sess_history, dba_hist_snapshot--gv$active_session_history
         where dba_hist_active_sess_history.snap_id = dba_hist_snapshot.snap_id and
        begin_interval_time between SYSDATE - &days and sysdate
    group by  trunc(sample_time,'hh24') + (trunc(to_char(sample_time,'mi')/15)*15)/24/60
        order by 1;
